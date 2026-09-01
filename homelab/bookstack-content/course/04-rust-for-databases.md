# Phase 4 — Rust for Databases and Systems

By this phase you have enough Rust from Phase 2 and enough database concepts from Phase 3 to start applying one to the other. This phase is about the specific Rust patterns that appear in database and systems code — the ones you will encounter constantly when reading DataFusion and Arrow source.

## The Volcano Model as the Iterator Trait

The Volcano model is the classic database query execution model. Every operator in the query plan has a `next()` method. Calling `next()` on a sort operator causes it to call `next()` on its input, get a row, accumulate it, and eventually return the first sorted row. This pull-based model maps exactly to Rust's `Iterator` trait.

```rust
// Classic Volcano model — one tuple at a time
// Every database operator you implement in 15-445 Project 3 has this shape
trait Operator {
    type Tuple;
    fn next(&mut self) -> Option<Self::Tuple>;
}

// Rust's built-in Iterator is the same interface
// DataFusion's vectorized version returns a batch of rows (RecordBatch) rather
// than one row at a time — that is the Stream trait (the async version of Iterator)
```

When you implement the sequential scan operator in 15-445 Project 3, you are implementing the database version of `Iterator`. When you later read DataFusion's `FilterExec` or `SortExec`, you are reading the production async-vectorized version of the same idea.

## Shared State with Arc and Locks

The buffer pool manager from Project 1 requires multiple threads to access pages simultaneously. Some threads want to read a page. One thread at a time may write. This is the readers-writer problem, and in Rust it is solved with `RwLock`.

```rust
use std::sync::{Arc, RwLock};
use std::collections::HashMap;

// A page is 4096 bytes of raw data
type PageId = u32;

struct Frame {
    data: [u8; 4096],
    dirty: bool,   // has this page been modified since it was read from disk?
    pin_count: u32, // how many threads are currently using this page?
}

// Arc allows this to be shared across threads.
// RwLock allows many concurrent readers, or one writer.
struct BufferPool {
    frames: Arc<RwLock<HashMap<PageId, Frame>>>,
}

impl BufferPool {
    // Many threads can call fetch_page simultaneously
    fn fetch_page(&self, page_id: PageId) -> bool {
        let frames = self.frames.read().unwrap(); // acquire shared read lock
        frames.contains_key(&page_id)
    } // read lock released here

    // Only one thread can call this at a time
    fn evict_page(&self, page_id: PageId) {
        let mut frames = self.frames.write().unwrap(); // acquire exclusive write lock
        frames.remove(&page_id);
    } // write lock released here
}
```

In DataFusion, the `CatalogProviderList` (the registry of databases and tables) uses this same pattern. Joe's catalog and RBAC work at Materialize was building exactly this structure at production scale.

## Trait Objects for Query Operator Trees

In DataFusion, a query plan is a tree of operators. A sort operator has a filter operator as its input, which has a scan operator as its input. Each operator implements the `ExecutionPlan` trait. The tree is built from `Arc<dyn ExecutionPlan>` nodes — trait objects behind reference-counted pointers.

Why `Arc<dyn ExecutionPlan>` and not just `Box<dyn ExecutionPlan>`? Because the execution engine needs to share operator nodes across multiple threads when executing partitioned queries. `Box` gives single ownership. `Arc` gives shared ownership.

```rust
// This is a simplified version of DataFusion's core trait
// Every operator — FilterExec, SortExec, HashJoinExec, AggregateExec — implements this
trait ExecutionPlan {
    // Returns the schema of the output (column names and types)
    fn schema(&self) -> Arc<Schema>;

    // Returns the operator's inputs (what it reads from)
    fn children(&self) -> Vec<Arc<dyn ExecutionPlan>>;

    // Begins executing this partition of the query
    // Returns a stream of RecordBatches
    fn execute(&self, partition: usize) -> SendableRecordBatchStream;
}

// A SendableRecordBatchStream is:
// Pin<Box<dyn Stream<Item = Result<RecordBatch>> + Send>>
//
// Breaking it down:
// - Stream<Item = Result<RecordBatch>>: an async iterator over batches of rows
// - Send: can be sent across threads
// - Box<dyn ...>: heap-allocated trait object
// - Pin<...>: cannot be moved in memory once polling starts (required by async)
```

## Async Streams for Vectorized Execution

The return type of `ExecutionPlan::execute()` is a stream of `RecordBatch` values. A `RecordBatch` is a table of data — some number of rows, all with the same schema. The stream produces batches one at a time as execution progresses.

```rust
use futures::stream::StreamExt;

// How you consume a DataFusion query result
async fn consume_results(mut stream: SendableRecordBatchStream) {
    while let Some(batch_result) = stream.next().await {
        match batch_result {
            Ok(batch) => {
                // batch is an Arrow RecordBatch
                // batch.num_rows() tells you how many rows are in this batch
                // batch.column(0) gives you the first column as an Arc<dyn Array>
                println!("{} rows in this batch", batch.num_rows());
            }
            Err(e) => {
                eprintln!("Error during execution: {}", e);
            }
        }
    }
}
```

The `while let Some(...) = stream.next().await` pattern is the async equivalent of `while let Some(...) = iterator.next()`.

## Atomics for Database Counters

Database systems need to increment counters from multiple threads without taking a lock. The most important example is the Log Sequence Number (LSN) — every write to a write-ahead log gets a unique, monotonically increasing LSN.

```rust
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::Arc;

struct WriteAheadLog {
    // AtomicU64 can be incremented from multiple threads simultaneously
    // without a Mutex — the CPU handles the synchronization in hardware
    next_lsn: Arc<AtomicU64>,
}

impl WriteAheadLog {
    fn allocate_lsn(&self) -> u64 {
        // fetch_add returns the old value and increments atomically
        // If two threads call this simultaneously, they get different LSNs
        self.next_lsn.fetch_add(1, Ordering::SeqCst)
    }
}
```

## Error Propagation Through Multiple Layers

DataFusion functions return `Result<T, DataFusionError>` where the error can originate from I/O, Arrow type mismatches, SQL parsing, or execution failures. The `?` operator converts these errors into the function's return type automatically.

```rust
use datafusion::prelude::*;
use datafusion::error::Result;

// This function can fail for several different reasons:
// - the file might not exist (I/O error)
// - the SQL might be invalid (parse error)
// - execution might fail (runtime error)
// The ? operator converts each error to DataFusionError and returns it
async fn count_rows(path: &str) -> Result<usize> {
    let ctx = SessionContext::new();
    ctx.register_csv("data", path, CsvReadOptions::new()).await?;
    let df = ctx.sql("SELECT COUNT(*) FROM data").await?;
    let batches = df.collect().await?;
    let count = batches[0]
        .column(0)
        .as_any()
        .downcast_ref::<arrow::array::Int64Array>()
        .unwrap()
        .value(0) as usize;
    Ok(count)
}
```

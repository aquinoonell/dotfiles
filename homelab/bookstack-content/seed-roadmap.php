<?php
/**
 * Seed BookStack with Rust Database Developer curriculum.
 * Run: docker exec -w /app/www bookstack php /tmp/seed-roadmap.php
 */
require '/app/www/vendor/autoload.php';
$app = require '/app/www/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use Illuminate\Support\Facades\Auth;
use BookStack\Entities\Models\Book;
use BookStack\Entities\Models\Page;
use BookStack\Entities\Models\Bookshelf;
use BookStack\Entities\Models\Chapter;

Auth::loginUsingId(1);

function md($text) {
    return (new \League\CommonMark\CommonMarkConverter())->convert($text)->getContent();
}

function upsertBook($slug, $name, $desc) {
    $book = Book::where('slug', $slug)->first();
    if (!$book) {
        $book = new Book();
        $book->name = $name;
        $book->slug = $slug;
        $book->description = $desc;
        $book->created_by = 1;
        $book->updated_by = 1;
        $book->save();
        echo "Created book: $name\n";
    }
    return $book;
}

function upsertPage($book, $slug, $name, $markdown, $priority = 0) {
    $page = Page::where('book_id', $book->id)->where('slug', $slug)->first();
    if (!$page) {
        $page = new Page();
        $page->book_id = $book->id;
        $page->name = $name;
        $page->slug = $slug;
        $page->created_by = 1;
        $page->priority = $priority;
    }
    $page->markdown = $markdown;
    $page->html = md($markdown);
    $page->updated_by = 1;
    $page->save();
    echo "  Page: $name\n";
    return $page;
}

// === SHELF ===
$shelf = Bookshelf::where('slug', 'rust-database-developer')->first();
if (!$shelf) {
    $shelf = new Bookshelf();
    $shelf->name = 'Rust Database Developer';
    $shelf->slug = 'rust-database-developer';
    $shelf->description = 'Roadmap to becoming a Rust database developer — Arrow, DataFusion, Postgres internals';
    $shelf->created_by = 1;
    $shelf->updated_by = 1;
    $shelf->save();
    echo "Created shelf: Rust Database Developer\n";
}

// === BOOK 1: Roadmap Overview ===
$roadmap = upsertBook('rust-db-roadmap', 'Rust DB Developer Roadmap', 'Your path from CS student to Rust database engineer');
upsertPage($roadmap, 'overview', 'Overview', <<<'MD'
# Rust Database Developer Roadmap

**Goal:** Become a software developer specializing in databases, distributed systems, and open source — expressed in Rust.

**Model:** [Joe Koshakow](https://joekoshakow.com) — Postgres committer, DataFusion contributor, Materialize engineer.

## Where You Are

| You Now | Target |
|---------|--------|
| Rust projects with gaps in fundamentals | Deep Rust for production DB systems |
| No database internals background | Understand storage engines, query execution |
| No DataFusion/Arrow experience | Contributor to Apache DataFusion |
| secure-chat + tuxedo contribution | Years of OSS contributions |

## Phase Timeline

| Phase | Topic | When |
|-------|-------|------|
| 0 | Environment setup | Week 1 |
| 1 | CS Foundations (B+Tree, OS) | Months 1-3 |
| 2 | Learn Rust properly | Months 1-6 |
| 3 | Database Internals (CMU 15-445) | Months 2-12 |
| 4 | Rust for Databases | Overlaps Phase 3 |
| 5 | Apache Arrow | After Rust + DB foundation |
| 6 | Apache DataFusion | After Arrow |
| 7 | Distributed Systems (6.824) | Year 1+ |
| 8 | Open Source Contributions | Month 6+ |

## Repos to Maintain

- `databases-scratch` — every experiment, B+Tree attempt, buffer pool
- `parq-tool` — Parquet + DataFusion + Postgres CLI
- `secure-chat` — crypto/TUI skills

## Offline Resources

- **Kiwix:** Rust DevDocs, DBA Stack Exchange, Software Engineering SE
- **BookStack:** This shelf
- **Database Dev Docs:** http://192.168.1.175:8090
MD, 1);

upsertPage($roadmap, 'phase-0-setup', 'Phase 0 — Setup', <<<'MD'
# Phase 0 — Environment Setup

## Install Tools

```bash
# Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env

# PostgreSQL via Docker
docker run --name pg -e POSTGRES_PASSWORD=password -p 5432:5432 -d postgres
psql -h localhost -U postgres -W

# DataFusion CLI
cargo install datafusion-cli
datafusion-cli
# SELECT 1 + 1;
```

## GitHub Cleanup

- Bio: "CS student at John Jay (CUNY). Interested in databases, distributed systems, and open source."
- Rename `ratatui-` → `secure-chat`
- Add topics: `rust`, `tui`, `cryptography`, `end-to-end-encryption`

## Create Repos

- `aquinoonell.github.io` — personal site
- `databases-scratch` — learning experiments
MD, 2);

upsertPage($roadmap, 'phase-2-rust', 'Phase 2 — Learn Rust', <<<'MD'
# Phase 2 — Learn Rust

Treat this as starting from zero even if you have projects.

## Reading Order

1. **The Rust Book** — https://doc.rust-lang.org/book/
   - Ch 4 (ownership) — read twice
   - Ch 10 (traits) — essential for DataFusion
   - Ch 13 (iterators) — maps to Volcano model
   - Ch 15-17 (smart pointers, concurrency, async)

2. **Rustlings** — https://github.com/rust-lang/rustlings

3. **Programming Rust** (O'Reilly) — deeper ownership, traits

4. **Async Book** — https://rust-lang.github.io/async-book/

5. **Tokio Tutorial** — build a TCP echo server

6. **Joe's posts:**
   - Generics vs Dynamic Dispatch
   - Rust Async Runtimes Explained

## Rust Concepts for Databases

| Concept | Why It Matters |
|---------|----------------|
| Ownership/borrowing | Buffer pool page lifetimes |
| Traits | ExecutionPlan, TableProvider APIs |
| `Arc<RwLock<T>>` | Shared catalog, buffer pool |
| `Iterator` | Volcano query execution model |
| `async/await` | DataFusion execution engine |
| `Result` + `?` | Error propagation everywhere |

## Crates to Know

| Crate | When |
|-------|------|
| `tokio` | Async runtime |
| `serde` | Serialization |
| `arrow`, `parquet` | Phase 5 |
| `datafusion` | Phase 6 |
| `tokio-postgres` | Postgres client |
| `pgrx` | Postgres extensions in Rust |
MD, 3);

// === BOOK 2: Database Internals ===
$internals = upsertBook('database-internals', 'Database Internals', 'Storage engines, indexes, transactions — CMU 15-445 concepts');
upsertPage($internals, 'storage-models', 'Storage Models', <<<'MD'
# Storage Models

## Row-Oriented (NSM)

Store entire rows together. Used by Postgres, MySQL, SQLite.

```
Row 1: [id=1, name="alice", price=10.0]
Row 2: [id=2, name="bob", price=20.0]
```

**Best for:** OLTP — point lookups, inserts, updates.

## Column-Oriented (DSM)

Store each column separately. Used by Arrow, Parquet, DataFusion.

```
ids:    [1, 2, 3]
names:  ["alice", "bob", "carol"]
prices: [10.0, 20.0, 15.0]
```

**Best for:** Analytics — scan few columns across many rows.

## Why Columnar Wins for Analytics

`SELECT AVG(price) FROM sales` on 1M rows:
- Row store: reads ALL columns for ALL rows
- Column store: reads ONLY the price column

Benefits: better compression, SIMD vectorization, projection pushdown.
MD, 1);

upsertPage($internals, 'btree', 'B+Tree Indexes', <<<'MD'
# B+Tree Indexes

The index structure behind Postgres `CREATE INDEX`, RocksDB, most storage engines.

## Structure

- Internal nodes: keys only (no data)
- Leaf nodes: keys + data pointers
- All data in leaves → efficient range scans
- Balanced tree → O(log n) lookups

## Operations

| Operation | What Happens |
|-----------|--------------|
| Insert | Find leaf, insert key. If full → **split** node |
| Delete | Remove key. If underfull → **merge** with sibling |
| Range scan | Walk leaf nodes left-to-right via linked list |

## B-Tree vs B+Tree

| | B-Tree | B+Tree |
|---|--------|--------|
| Data in internal nodes | Yes | No (keys only) |
| Range scans | Slower | Faster (leaf links) |
| Used by databases | Rarely | Postgres, MySQL, RocksDB |

## Project

Implement in Rust in `databases-scratch`:
- Insert, delete, range scan
- Node splitting and merging
- Tests for each operation

This is the most important project on the roadmap.
MD, 2);

upsertPage($internals, 'buffer-pool', 'Buffer Pool Manager', <<<'MD'
# Buffer Pool Manager

How databases manage memory — the foundation of CMU 15-445 Project 1.

## Concept

Database pages (4KB-16KB) are cached in memory. The buffer pool decides which pages stay in RAM and which get evicted to disk.

Postgres equivalent: `shared_buffers` setting.

## Components

| Component | Purpose |
|-----------|---------|
| Frame | Fixed-size memory slot for one page |
| Page table | Maps page IDs → frames |
| Replacement policy | LRU or clock — which frame to evict |
| Pin count | Pages in use cannot be evicted |

## Rust Pattern

```rust
use std::sync::{Arc, RwLock};
use std::collections::HashMap;

struct BufferPool {
    frames: Arc<RwLock<HashMap<PageId, Frame>>>,
}

impl BufferPool {
    fn fetch_page(&self, id: PageId) -> bool {
        self.frames.read().unwrap().contains_key(&id)
    }
    fn evict_page(&self, id: PageId) {
        self.frames.write().unwrap().remove(&id);
    }
}
```

## Key Insight

The OS has its own page cache. Databases often bypass it with `O_DIRECT` and manage caching themselves for predictable performance.
MD, 3);

upsertPage($internals, 'wal-mvcc', 'WAL & MVCC', <<<'MD'
# Write-Ahead Log & MVCC

## Write-Ahead Log (WAL)

Every change is logged to disk BEFORE being applied to data pages.

```
1. BEGIN transaction
2. Write change to WAL log (fsync)
3. Apply change to data page in buffer pool
4. COMMIT
```

**Crash recovery:** Replay WAL from last checkpoint. The ARIES algorithm (1992 paper) is what Postgres uses.

**LSN (Log Sequence Number):** Monotonically increasing counter. In Rust: `AtomicU64` with `fetch_add`.

## MVCC (Multi-Version Concurrency Control)

Keep multiple versions of each row. Readers see a snapshot; writers create new versions.

- Readers never block writers
- Writers never block readers
- Postgres uses MVCC
- Materialize (Joe's employer) implemented isolation levels on top of MVCC

## Isolation Levels

| Level | Guarantees |
|-------|------------|
| Read Uncommitted | See uncommitted changes (dirty reads) |
| Read Committed | See only committed changes |
| Repeatable Read | Same snapshot throughout transaction |
| Serializable | Transactions appear to run one at a time |

## Two-Phase Locking (2PL)

- Growing phase: acquire locks, never release
- Shrinking phase: release locks, never acquire
- Used by Postgres for row-level locking
MD, 4);

upsertPage($internals, 'query-execution', 'Query Execution', <<<'MD'
# Query Execution Models

## Volcano Model (Iterator)

Each operator has a `next()` method returning one row at a time.

```
Sort.next() → calls Filter.next() → calls Scan.next()
```

Maps directly to Rust's `Iterator` trait. CMU 15-445 Project 3 uses this.

## Vectorized Execution

Each operator returns a **batch** of rows (Arrow RecordBatch) instead of one row.

- Better CPU cache utilization
- SIMD operations on contiguous memory
- DataFusion uses this model

```rust
// Volcano: Iterator<Item = Row>
// Vectorized: Stream<Item = Result<RecordBatch>>
```

## Key Operators

| Operator | What It Does |
|----------|--------------|
| Sequential Scan | Read all rows from table |
| Index Scan | Use B+Tree to find rows |
| Filter | Apply WHERE predicate |
| Hash Join | Build hash table on one side, probe with other |
| Sort Merge Join | Sort both sides, merge |
| Hash Aggregate | Build hash table, compute GROUP BY |
| Sort | External sort with spill to disk |

## Query Optimization

Logical optimizer rewrites plans without changing results:
- **Predicate pushdown** — move filters close to data
- **Projection pushdown** — read only needed columns
- **Constant folding** — evaluate `1 + 1` at compile time
MD, 5);

upsertPage($internals, 'courses-papers', 'Courses & Papers', <<<'MD'
# Courses & Essential Papers

## Courses (Free)

| Course | Focus | Link |
|--------|-------|------|
| CMU 15-445 | Database Systems | 15445.courses.cs.cmu.edu |
| CMU 15-721 | Advanced DB Systems | 15721.courses.cs.cmu.edu |
| MIT 6.824 | Distributed Systems | pdos.csail.mit.edu/6.824/ |
| OSTEP | Operating Systems | pages.cs.wisc.edu/~remzi/OSTEP/ |

## CMU 15-445 Projects

Do in C++ (BusTub), then rewrite in Rust:

1. Buffer Pool Manager
2. B+Tree Index
3. Query Execution (Volcano model)
4. Concurrency Control (2PL)

## Essential Papers

| Paper | Why |
|-------|-----|
| Codd (1970) — Relational Model | Origin of SQL |
| ARIES (1992) — WAL Recovery | Postgres crash recovery |
| MonetDB/X100 (2005) | Vectorized execution — DataFusion's model |
| Column-Oriented DB Systems (2012) | Arrow's theoretical foundation |
| Raft (2014) | Consensus for distributed DBs |
| MVCC Survey (CMU 2017) | Isolation levels |

## PostgreSQL Internals Books

- _The Internals of PostgreSQL_ — interdb.jp/pg/ (free)
- _PostgreSQL 14 Internals_ — postgrespro.com (free PDF)
MD, 6);

// === BOOK 3: Apache Arrow Deep Dive ===
$arrow = upsertBook('apache-arrow-deep-dive', 'Apache Arrow Deep Dive', 'Columnar memory format — types, arrays, RecordBatch');
upsertPage($arrow, 'arrow-overview', 'What is Arrow?', <<<'MD'
# Apache Arrow

Columnar in-memory format for analytics. Language-agnostic standard with implementations in Rust, C++, Python, Java.

## Why Arrow Exists

1. **Analytics performance** — columnar layout for scan-heavy queries
2. **Zero-copy sharing** — pass data between Rust/Python/Java without copying
3. **Common format** — one schema for DataFusion, Polars, DuckDB, Spark

## Arrow vs Parquet

| | Arrow | Parquet |
|---|-------|---------|
| Where | In-memory | On-disk |
| Purpose | Computation | Storage |
| Speed | Fast access | Compressed storage |

They work together: read Parquet → Arrow RecordBatch → compute → write Parquet.

## Setup

```toml
[dependencies]
arrow = "55"
```

Import through DataFusion when using both:
```rust
use datafusion::arrow::array::Int64Array;  // RIGHT
// use arrow::array::Int64Array;           // WRONG — version mismatch
```
MD, 1);

upsertPage($arrow, 'arrow-types', 'Types & Schema', <<<'MD'
# Arrow Type System

## Core Types

| Type | Rust Type | Example Values |
|------|-----------|----------------|
| Int32 | `Int32Array` | `[1, 2, 3]` |
| Int64 | `Int64Array` | `[100, 200]` |
| Float64 | `Float64Array` | `[1.5, 2.7]` |
| Utf8 (string) | `StringArray` | `["alice", "bob"]` |
| Boolean | `BooleanArray` | `[true, false]` |
| Timestamp | `TimestampNanosecondArray` | epoch nanos |

## Schema

```rust
use arrow::datatypes::{Schema, Field, DataType};

let schema = Schema::new(vec![
    Field::new("id", DataType::Int32, false),      // non-nullable
    Field::new("name", DataType::Utf8, true),       // nullable
    Field::new("price", DataType::Float64, false),
]);
```

## Field Properties

- `name` — column name
- `data_type` — Arrow DataType enum
- `nullable` — can values be null?
- `metadata` — optional key-value pairs

Joe's Substrait contributions added `Duration`, `Time`, and `Dictionary` type support.
MD, 2);

upsertPage($arrow, 'arrow-arrays', 'Arrays & RecordBatch', <<<'MD'
# Arrays and RecordBatch

## Creating Arrays

```rust
use arrow::array::{Int32Array, StringArray};
use std::sync::Arc;

let ids = Int32Array::from(vec![1, 2, 3]);
let names = StringArray::from(vec![
    Some("alice"),
    None,           // null value
    Some("charol"),
]);
```

## RecordBatch

The unit of execution in DataFusion. All arrays have the same length.

```rust
use arrow::record_batch::RecordBatch;

let batch = RecordBatch::try_new(
    Arc::new(schema),
    vec![
        Arc::new(ids) as ArrayRef,
        Arc::new(names) as ArrayRef,
    ],
)?;

println!("{} rows, {} cols", batch.num_rows(), batch.num_columns());
```

## Accessing Columns

```rust
// By index
let col = batch.column(0);

// By name
let idx = batch.schema().index_of("price")?;
let col = batch.column(idx);

// Downcast to concrete type
let prices = col.as_any().downcast_ref::<Float64Array>().unwrap();
for i in 0..prices.len() {
    if prices.is_valid(i) {
        println!("{}", prices.value(i));
    }
}
```

## Null Handling

Arrow iterates as `Option<T>`. Never use `.unwrap()` on values — use `.unwrap_or_default()` for nulls.
MD, 3);

upsertPage($arrow, 'arrow-exercises', 'Arrow Exercises', <<<'MD'
# Arrow Exercises

Build these in `databases-scratch`:

## Exercise 1: CSV to Parquet

Read a CSV file, infer schema, build RecordBatches, write to Parquet. Use only `arrow` and `parquet` crates.

## Exercise 2: Column Statistics

Read a Parquet file, iterate RecordBatches, compute min/max/mean/null-count for a numeric column. This is what DataFusion's `SumAccumulator` does internally.

## Exercise 3: array_slice Edge Cases

Find Joe Koshakow's `array_slice` fix in DataFusion. Write the same test cases against `arrow-rs` directly.

## Docs to Read

- Arrow Rust: arrow.apache.org/rust/arrow/
- Arrow Cookbook: arrow.apache.org/cookbook/
- Columnar Format Spec: arrow.apache.org/docs/format/Columnar.html
MD, 4);

// === BOOK 4: DataFusion Deep Dive ===
$df = upsertBook('datafusion-deep-dive', 'DataFusion Deep Dive', 'Query engine architecture, SQL, UDFs, contributions');
upsertPage($df, 'df-architecture', 'Architecture', <<<'MD'
# DataFusion Architecture

## Query Pipeline

```
SQL → AST → LogicalPlan → Optimizer → PhysicalPlan → Stream → Results
```

| Stage | Component | What It Does |
|-------|-----------|--------------|
| Parse | sqlparser-rs | SQL text → AST |
| Plan | datafusion-sql | AST → LogicalPlan |
| Optimize | LogicalOptimizer | Predicate/projection pushdown |
| Execute | PhysicalPlanner | LogicalPlan → ExecutionPlan tree |
| Run | tokio | Parallel async execution |

## Key Traits

| Trait | Purpose |
|-------|---------|
| `ExecutionPlan` | Physical operator (Filter, Sort, Join) |
| `TableProvider` | Data source (Parquet, CSV, custom) |
| `ScalarUDF` | User-defined function |
| `Accumulator` | Aggregate function state |

## Source Code Map

```
datafusion/
  core/src/execution/     SessionContext
  optimizer/src/          rewrite rules
  physical-plan/src/      FilterExec, SortExec, joins
  functions/src/          built-in functions
  sql/src/                SQL → LogicalPlan
```
MD, 1);

upsertPage($df, 'df-sql-api', 'SQL & DataFrame API', <<<'MD'
# DataFusion SQL & DataFrame API

## SQL

```rust
use datafusion::prelude::*;

#[tokio::main]
async fn main() -> datafusion::error::Result<()> {
    let ctx = SessionContext::new();
    ctx.register_parquet("taxi", "data.parquet",
        ParquetReadOptions::default()).await?;

    let df = ctx.sql("
        SELECT passenger_count, AVG(tip_amount) as avg_tip
        FROM taxi
        WHERE trip_distance > 1.0
        GROUP BY passenger_count
        ORDER BY avg_tip DESC
    ").await?;

    df.show().await?;
    Ok(())
}
```

## DataFrame API

```rust
let df = ctx.read_parquet("data.parquet", ParquetReadOptions::default()).await?;

let result = df
    .filter(col("price").gt(lit(10.0)))?
    .select(vec![col("name"), col("price")])?
    .aggregate(vec![col("category")], vec![
        sum(col("price")).alias("total"),
        count(col("id")).alias("count"),
    ])?
    .sort(vec![col("total").sort(false, true)])?;

result.show().await?;
```

## EXPLAIN

```rust
df.clone().explain(false, false)?.show().await?;
```

Shows the physical plan — which operators run, in what order, with what predicates pushed down.
MD, 2);

upsertPage($df, 'df-udfs', 'User Defined Functions', <<<'MD'
# Writing UDFs in DataFusion

The most direct path from user to contributor.

## Scalar UDF

```rust
use datafusion::logical_expr::{create_udf, Volatility};
use datafusion::arrow::array::{ArrayRef, StringArray};

let shout = create_udf(
    "shout",
    vec![DataType::Utf8],
    DataType::Utf8,
    Volatility::Immutable,
    Arc::new(|args: &[ArrayRef]| {
        let input = args[0].as_any().downcast_ref::<StringArray>().unwrap();
        let output: StringArray = input.iter()
            .map(|s| s.map(|v| v.to_uppercase()))  // preserves nulls
            .collect();
        Ok(Arc::new(output) as ArrayRef)
    }),
);
```

## NULL Handling

The `.map(|s| s.map(...))` pattern preserves nulls. Compare your UDF to the built-in `upper()` in `datafusion/functions/src/string/upper.rs`.

## Contribution Targets

1. NULL handling edge cases in scalar functions
2. Missing type support (search for `todo!()`)
3. `array_slice` edge cases
4. Substrait serialization for new types

Browse: github.com/apache/datafusion/issues?q=label%3A%22good+first+issue%22
MD, 3);

upsertPage($df, 'df-contributing', 'Contributing to DataFusion', <<<'MD'
# Contributing to DataFusion

## Setup

```bash
git clone https://github.com/apache/datafusion
cd datafusion
cargo test   # all must pass before changes
```

## Contribution Ladder

| Level | What | Example |
|-------|------|---------|
| 1 | Docs, tests, typos | Fix a doc example |
| 2 | Good first issues | Small bug fix |
| 3 | Edge cases | NULL handling in functions |
| 4 | Type system | Substrait Duration/Time support |
| 5 | New features | Custom TableProvider |
| 6 | Committer | Sustained contributions |

## Joe Koshakow's PRs (Style Reference)

https://github.com/apache/datafusion/pulls?q=is%3Apr+is%3Amerged+author%3Ajkosh44

## PR Checklist

1. `cargo test` passes
2. Add test that reproduces the bug
3. Clear commit message
4. Link to issue if one exists
5. Keep scope small — one fix per PR

## Also Consider

- **arrow-rs** — github.com/apache/arrow-rs
- **rust-postgres** — add new Postgres type support
- **pgrx** — Postgres extensions in Rust (like Joe's pg_duration)
MD, 4);

// === BOOK 5: parq-tool Guide ===
$parq = upsertBook('parq-tool-guide', 'parq-tool Build Guide', 'Build a Parquet + DataFusion + Postgres CLI tool');
upsertPage($parq, 'parq-overview', 'Overview', <<<'MD'
# parq-tool Build Guide

CLI tool: read Parquet → run SQL via DataFusion → write to Parquet or Postgres.

## Project Layers

| Layer | Binary | Teaches |
|-------|--------|---------|
| 1 | `main.rs` | Read Parquet, inspect schema |
| 2 | `query.rs` | DataFusion SQL queries |
| 3 | `write.rs` | Write results to Parquet |
| 4 | `pg.rs` | Write results to Postgres |

## Cargo.toml

```toml
[dependencies]
datafusion = "44"
tokio = { version = "1", features = ["full"] }
parquet = { version = "55", features = ["arrow"] }
tokio-postgres = "0.7"
clap = { version = "4", features = ["derive"] }
```

## Version Rule

Always import Arrow through DataFusion:
```rust
use datafusion::arrow::array::Int64Array;  // RIGHT
```

## Three Questions Before Any API

1. **Where does it come from?** — full import path
2. **What does it accept?** — read the signature
3. **What does it return?** — handle Result/Option
MD, 1);

upsertPage($parq, 'parq-layer1', 'Layer 1 — Read Parquet', <<<'MD'
# Layer 1 — Read Parquet

## Docs to Read First

1. parquet crate: arrow.apache.org/rust/parquet/
2. parquet::arrow module: arrow.apache.org/rust/parquet/arrow/
3. ParquetRecordBatchReaderBuilder docs

## Implementation

```rust
use std::fs::File;
use parquet::arrow::arrow_reader::ParquetRecordBatchReaderBuilder;

fn main() {
    let file = File::open("data.parquet").expect("open file");
    let builder = ParquetRecordBatchReaderBuilder::try_new(file)
        .expect("create builder");

    println!("Row groups: {}", builder.metadata().num_row_groups());
    println!("Schema: {}", builder.schema());

    let mut reader = builder.build().expect("build reader");
    while let Some(batch) = reader.next() {
        let batch = batch.expect("read batch");
        println!("{} rows, {} cols", batch.num_rows(), batch.num_columns());
    }
}
```

## Next: Sum a Column

Find column by name, downcast to `Float64Array`, sum with null handling via `.unwrap_or_default()`.
MD, 2);

upsertPage($parq, 'parq-layer2', 'Layer 2 — SQL with DataFusion', <<<'MD'
# Layer 2 — SQL with DataFusion

```rust
use datafusion::prelude::*;

#[tokio::main]
async fn main() -> datafusion::error::Result<()> {
    let ctx = SessionContext::new();
    ctx.register_parquet("data", "input.parquet",
        ParquetReadOptions::default()).await?;

    let df = ctx.sql("SELECT * FROM data WHERE id > 1").await?;
    df.show().await?;
    Ok(())
}
```

## Column Name Gotchas

NYC taxi data has mixed-case columns:
```rust
// Preserve case with quotes
.filter(col("\"passenger_count\"").gt(lit(0)))?

// Or use ident for direct reference
.aggregate(vec![ident("passenger_count")], vec![min(col("tip_amount"))])?
```
MD, 3);

upsertPage($parq, 'parq-layer3-4', 'Layers 3-4 — Write Output', <<<'MD'
# Layers 3-4 — Write to Parquet & Postgres

## Layer 3: Write Parquet

```rust
use parquet::arrow::ArrowWriter;

let batches = df.collect().await?;
let file = File::create("output.parquet")?;
let mut writer = ArrowWriter::try_new(file, batches[0].schema(), None)?;
for batch in &batches {
    writer.write(batch)?;
}
writer.close()?;
```

## Layer 4: Write to Postgres

```rust
use tokio_postgres::NoTls;

let (client, connection) = tokio_postgres::connect(
    "host=localhost user=postgres password=password", NoTls
).await?;

tokio::spawn(async move {
    if let Err(e) = connection.await { eprintln!("{}", e); }
});

for batch in &batches {
    for row_idx in 0..batch.num_rows() {
        // Extract values from each column, INSERT into Postgres
    }
}
```

## How Types Connect

```
Parquet file → RecordBatch → DataFusion SQL → RecordBatch → Parquet/Postgres
```
MD, 4);

// === Attach books to shelf ===
$bookIds = [$roadmap->id, $internals->id, $arrow->id, $df->id, $parq->id];
foreach ($bookIds as $id) {
    if (!$shelf->books()->where('id', $id)->exists()) {
        $shelf->appendBook(Book::find($id));
    }
}

echo "Done! Shelf: Rust Database Developer with " . count($bookIds) . " books.\n";

# Master Resource Index

## Books

| Title | Author | Domain | Link |
|---|---|---|---|
| The Rust Programming Language | Klabnik and Nichols | Rust | https://doc.rust-lang.org/book/ |
| Programming Rust | Blandy, Orendorff, Tindall | Rust | O'Reilly |
| Rust for Rustaceans | Gjengset | Rust (advanced) | https://nostarch.com/rust-rustaceans |
| Async Programming in Rust | Rust team | Rust async | https://rust-lang.github.io/async-book/ |
| The Internals of PostgreSQL | Suzuki | Databases | https://www.interdb.jp/pg/ |
| PostgreSQL 14 Internals | Rogov | Databases | https://postgrespro.com/community/books/internals |
| Designing Data-Intensive Applications | Kleppmann | Systems | https://dataintensive.net/ |
| Operating Systems: Three Easy Pieces | Arpaci-Dusseau | OS | https://pages.cs.wisc.edu/~remzi/OSTEP/ |
| Introduction to Algorithms (CLRS) | Cormen et al. | Algorithms | https://mitpress.mit.edu/9780262046305/ |

## Courses

| Course | Institution | Link |
|---|---|---|
| 15-445: Database Systems | CMU (Pavlo) | https://15445.courses.cs.cmu.edu/ |
| 6.824: Distributed Systems | MIT | https://pdos.csail.mit.edu/6.824/ |
| 15-721: Advanced Database Systems | CMU (Pavlo) | https://15721.courses.cs.cmu.edu/ |
| 6.006: Introduction to Algorithms | MIT | https://ocw.mit.edu/courses/6-006-introduction-to-algorithms-fall-2011/ |
| CS:APP / 15-213 | CMU | https://www.cs.cmu.edu/~213/ |

## Official Documentation

| Resource | URL |
|---|---|
| Arrow Rust crate | https://arrow.apache.org/rust/arrow/index.html |
| Arrow datatypes module | https://arrow.apache.org/rust/arrow/datatypes/index.html |
| Arrow array module | https://arrow.apache.org/rust/arrow/array/index.html |
| Parquet crate | https://arrow.apache.org/rust/parquet/index.html |
| Parquet/Arrow bridge | https://arrow.apache.org/rust/parquet/arrow/index.html |
| Arrow Cookbook | https://arrow.apache.org/cookbook/ |
| Arrow Columnar Format Spec | https://arrow.apache.org/docs/format/Columnar.html |
| DataFusion User Guide | https://datafusion.apache.org/user-guide/introduction.html |
| DataFusion Arrow Introduction | https://datafusion.apache.org/user-guide/arrow-introduction.html |
| DataFusion Library User Guide | https://datafusion.apache.org/library-user-guide/index.html |
| DataFusion Adding UDFs | https://datafusion.apache.org/library-user-guide/functions/adding-udfs.html |
| DataFusion Contributor Guide | https://datafusion.apache.org/contributor-guide/ |
| DataFusion Architecture | https://datafusion.apache.org/contributor-guide/architecture.html |
| DataFusion API Reference | https://docs.rs/datafusion/latest/datafusion/ |

## Key Repositories

| Repo | Why |
|---|---|
| https://github.com/apache/datafusion | Primary contribution target |
| https://github.com/apache/arrow-rs | Secondary contribution target |
| https://github.com/postgres/postgres | Long-term goal (Year 2+) |
| https://github.com/MaterializeInc/materialize | Production Rust database — read the source |
| https://github.com/databendlabs/openraft | Raft in Rust (Joe contributed) |
| https://github.com/tokio-rs/tokio | Async runtime |
| https://github.com/pgcentralfoundation/pgrx | Postgres extensions in Rust |
| https://github.com/sfackler/rust-postgres | Rust Postgres client (Joe contributed) |
| https://github.com/apache/fluo | Distributed transactions (Joe is PMC) |
| https://github.com/cmu-db/bustub | 15-445 teaching database (C++) |
| https://github.com/jkosh44/pg_duration | Joe's Postgres extension — template for yours |
| https://github.com/rust-lang/rustlings | Rust exercises |

## People to Follow

| Person | Why | Link |
|---|---|---|
| Joe Koshakow | Your direct model | https://joekoshakow.com |
| Andy Pavlo | CMU DB professor | https://www.cs.cmu.edu/~pavlo/ |
| Jon Gjengset | Advanced Rust, live-codes systems projects | https://www.youtube.com/@jonhoo |
| Andrew Lamb | DataFusion and Arrow PMC | https://github.com/alamb |
| Martin Kleppmann | DDIA author | https://martin.kleppmann.com/ |

## Joe's Posts — Read All of These

| Post | Link |
|---|---|
| Generics and Dynamic Dispatch in Rust | https://joekoshakow.com/blogs/2025-04-06-rust-generics-vs-dynamic-dispatch.html |
| Rust Async Runtimes Explained | https://joekoshakow.com/blogs/2025-04-06-rust-async-runctimes.html |
| PostgreSQL Intervals are Confusing | https://joekoshakow.com/blogs/2025-03-03-postgresql-intervals-are-confusing.html |
| Role Based Access Control | https://materialize.com/blog/rbac/ |
| The Four ACID Questions | https://materialize.com/blog/the-four-acid-questions/ |

---

# Rust Translation Guide

For every concept from database textbooks and courses, this is the Rust equivalent.

## Storage Engine Concepts

| Concept | What It Is | Rust |
|---|---|---|
| Page / Frame | Fixed-size unit of storage (4KB–16KB) | `Box<[u8; PAGE_SIZE]>` or `bytes::Bytes` |
| Buffer pool table | Map from page IDs to in-memory frames | `HashMap<PageId, Frame>` |
| Shared page access | Multiple threads reading one page | `Arc<RwLock<Page>>` |
| LRU replacement | Evict the least recently used page | `linked_hash_map::LinkedHashMap` |
| File I/O (sync) | Read and write pages to disk | `std::fs::File` |
| File I/O (async) | Async disk access | `tokio::fs::File` |
| Memory-mapped file | Map a file into the process address space | `memmap2::Mmap` |
| WAL record | An entry in the write-ahead log | `struct WalRecord { lsn: u64, data: Vec<u8> }` |
| Free list | Which frames are currently unused | `VecDeque<FrameId>` |
| Page latch | Short-term lock on a page during an operation | `std::sync::RwLock` or `tokio::sync::RwLock` |
| Log Sequence Number | Monotonically increasing counter for WAL | `Arc<AtomicU64>` with `fetch_add` |

## Query Engine Concepts

| Concept | What It Is | Rust |
|---|---|---|
| Volcano iterator | Operator returns one row at a time | `Iterator` trait — `fn next(&mut self) -> Option<Row>` |
| Vectorized execution | Operator returns one batch of rows at a time | `Stream<Item = Result<RecordBatch>>` |
| Physical operator | A node in the execution plan tree | A struct that implements `ExecutionPlan` |
| Operator tree | The tree of operators that executes a query | `Arc<dyn ExecutionPlan>` for each node |
| Logical expression | `a + b` or `x > 5` in the query plan | `datafusion::logical_expr::Expr` enum |
| Physical expression | How to evaluate an `Expr` at runtime | `Arc<dyn datafusion::physical_expr::PhysicalExpr>` |
| Schema | Column names and types | `Arc<arrow::datatypes::Schema>` |
| Column | An array of values for one column | `Arc<dyn arrow::array::Array>` (also called `ArrayRef`) |
| Null value | A missing or unknown value | Arrow null bitmask; `Option<T>` when iterating |
| Session context | Configuration and state for one user session | `datafusion::prelude::SessionContext` |

## Concurrency Concepts

| Concept | What It Is | Rust |
|---|---|---|
| Readers-writer lock | Many concurrent readers OR one writer | `Arc<RwLock<T>>` |
| Mutex | One thread at a time, exclusive access | `Arc<Mutex<T>>` |
| Atomic counter | Increment from many threads without locking | `Arc<AtomicU64>` with `fetch_add(1, Ordering::SeqCst)` |
| Message passing | Send data between threads | `tokio::sync::mpsc` for async, `std::sync::mpsc` for sync |
| Thread pool | Run many tasks in parallel | `tokio::task::spawn` for async tasks, `rayon` for CPU work |
| Concurrent hash map | Hash map with concurrent read and write | `dashmap::DashMap` |
| Condition variable | Wake a waiting thread when something changes | `tokio::sync::Notify` or `std::sync::Condvar` |

## Distributed Systems Concepts

| Concept | What It Is | Rust |
|---|---|---|
| Raft log entry | One command in the replicated log | `openraft::Entry<T>` |
| RPC | Call a function on a remote machine | `tonic` (gRPC) + `prost` (Protocol Buffers) |
| Serialization | Convert a struct to bytes to send over the network | `serde` + `bincode` or `serde_json` |
| TCP server | Accept connections and handle requests | `tokio::net::TcpListener` |
| Heartbeat | Periodic ping to show a node is alive | `tokio::time::interval` |
| Distributed tracing | Track a request as it moves across nodes | `tracing` crate + `opentelemetry` |
| State machine | Apply committed Raft log entries | `openraft::RaftStateMachine` trait |

## PostgreSQL Extension Concepts (via pgrx)

| Concept | C (standard Postgres extensions) | Rust via pgrx |
|---|---|---|
| Define a new type | `PG_FUNCTION_INFO_V1(type_in)` and `type_out` | `#[pg_extern] fn type_in(...)` |
| Postgres universal value | `Datum` — everything Postgres passes around | `PgDatum<T>` |
| Memory allocation | `palloc()` / `pfree()` | pgrx manages this automatically |
| Run SQL from extension | `SPI_execute()` | `Spi::run("SELECT ...")` |
| Custom operator | `CREATE OPERATOR` SQL statement | `#[pg_operator]` attribute macro |
| Aggregate function | `CREATE AGGREGATE` SQL statement | `#[pg_aggregate]` attribute macro |

# Phase 2 — Learn Rust

This is a full phase, not a footnote. Even if you have projects in Rust, treat this as starting from zero. The goal is not to be able to write Rust — it's to understand why Rust works the way it does, because that understanding is what lets you read and contribute to production codebases like DataFusion.

## The Right Order

### Step 1: The Rust Programming Language (the official book)

Read every chapter. Do not skip the ownership chapters. They are the point.

- https://doc.rust-lang.org/book/

Work through it in this order:

- **Chapters 1–3:** installation, basic syntax, variables, functions — get this done quickly.
- **Chapter 4:** ownership, borrowing, slices. Read this twice. This is what makes Rust different from every other language you've used. If anything in this chapter is unclear, stop and work through it until it's clear before moving on. The rest of the language is built on top of this.
- **Chapters 5–9:** structs, enums, pattern matching, error handling with `Result` and `?`. This is the day-to-day Rust you'll write constantly.
- **Chapter 10:** generics, traits, and lifetimes. Traits are how Rust does abstraction — every major API in DataFusion and Arrow is a trait. Read this carefully.
- **Chapters 11–12:** testing and a command line project. Do the project.
- **Chapter 13:** iterators and closures. Iterators are one of the most important patterns in Rust. The Volcano model in databases (each operator has a `next()` method that returns one row at a time) maps directly to Rust's `Iterator` trait. Read this chapter with that connection in mind.
- **Chapter 15:** smart pointers — `Box<T>`, `Rc<T>`, `Arc<T>`, `RefCell<T>`. You will use `Arc` constantly when building anything concurrent. `Box` is how you put things on the heap. `RefCell` is interior mutability.
- **Chapter 16:** concurrency — threads, `Mutex`, `RwLock`, message passing with channels. This chapter directly prepares you for the concurrency patterns in database code.
- **Chapter 17:** async/await. DataFusion's entire execution engine is async. You need this.
- **Chapters 18–20:** pattern matching depth, advanced features, final project. Work through all of it.

### Step 2: Rustlings

Do this while reading the book, not after. Rustlings is a series of small exercises that fail to compile until you fix them. They are the fastest way to get muscle memory for Rust syntax.

- https://github.com/rust-lang/rustlings

```bash
cargo install rustlings
rustlings init
cd rustlings
rustlings watch
```

### Step 3: Rust By Example

Use this as a reference while working through the book. When you encounter a concept and want to see more examples, come here.

- https://doc.rust-lang.org/rust-by-example/

### Step 4: Programming Rust (O'Reilly)

Read this after finishing the official book. It goes deeper on every topic — especially ownership semantics, lifetimes, and concurrency. The chapters on traits and generics are essential for understanding Arrow's type system.

### Step 5: Async Programming in Rust

DataFusion is fully async. Every query execution call returns an async stream of results. You need to understand how async/await works in Rust — not just the syntax, but what the runtime is actually doing.

- The async book: https://rust-lang.github.io/async-book/
- Tokio tutorial: https://tokio.rs/tokio/tutorial

After the tokio tutorial, build a simple TCP server: it listens for connections, reads a line of text, and sends it back uppercased. This is small but teaches you the async I/O patterns you'll use later.

### Step 6: Rust for Rustaceans

Read this after you've built a few projects in Rust and the language feels familiar. It covers advanced ownership semantics, trait objects, interior mutability patterns, and the things that trip people up when reading production Rust code.

- https://nostarch.com/rust-rustaceans

Jon Gjengset, the author, also has a YouTube channel where he live-codes Rust, including database-adjacent projects. Watch the streams: https://www.youtube.com/@jonhoo

### Step 7: Joe's Two Rust Blog Posts

Read these before moving into DataFusion. They explain two Rust concepts that appear everywhere in DataFusion's source code:

- **Generics and Dynamic Dispatch in Rust:** https://joekoshakow.com/blogs/2025-04-06-rust-generics-vs-dynamic-dispatch.html — DataFusion uses `Arc<dyn ExecutionPlan>` (dynamic dispatch through a trait object) for operator trees. Joe explains when to use static dispatch (generics) versus dynamic dispatch (trait objects) and why the choice matters for performance and flexibility.

- **Rust Async Runtimes Explained:** https://joekoshakow.com/blogs/2025-04-06-rust-async-runctimes.html — DataFusion runs on tokio. This post explains what an async runtime actually does — it demystifies why `async fn` requires a runtime to work and how that runtime schedules tasks across threads.

---

## What Rust Concepts You Actually Need for This Goal

Not every Rust feature matters equally for databases and systems work. Here is a prioritized map of what you need and why.

**Ownership and borrowing** — the most important thing to understand deeply. In database code, you are constantly managing the lifetime of pages, buffers, and intermediate query results. Rust's ownership system is what lets you do this without garbage collection pauses — which matter enormously for database latency.

**Traits** — the mechanism for abstraction in Rust, and the primary API surface in DataFusion and Arrow. The `ExecutionPlan` trait is the interface every query operator implements. The `TableProvider` trait is how you add a new data source. The `ArrowPrimitiveType` trait is how Arrow's type system works.

**`Arc<T>` and `Arc<Mutex<T>>`** — in database code, data is shared across threads constantly. A buffer pool has frames that multiple threads want to read simultaneously. A query engine has a catalog that every session reads at the same time. `Arc<T>` gives you shared ownership with reference counting. `Arc<Mutex<T>>` gives you shared mutable access.

**`Arc<RwLock<T>>`** — a refinement of the above. `RwLock` allows multiple concurrent readers or one writer, but not both at once. This is the right tool when reads are far more common than writes.

**Iterators and closures** — the Volcano model of query execution has each operator implement `next()` to produce one row at a time. This is exactly Rust's `Iterator` trait.

**Async/await and `Pin<Box<dyn Stream>>`** — DataFusion's execution engine is async. Each operator's `execute()` method returns a `SendableRecordBatchStream`, which is `Pin<Box<dyn Stream<Item = Result<RecordBatch>> + Send>>`.

**Error handling with `Result<T, E>` and `?`** — DataFusion uses `datafusion::error::Result<T>` throughout. The `?` operator propagates errors up the call stack.

**Generics and associated types** — Arrow's type system uses generics extensively. `PrimitiveArray<T>` is a generic array where `T` implements `ArrowPrimitiveType`.

---

## Rust Crates to Know in This Domain

| Crate | What It Is | When You Need It |
|---|---|---|
| `tokio` | Async runtime — DataFusion's execution engine runs on this | Phase 2, when you get to async |
| `futures` | Traits and utilities for working with async streams and futures | Phase 2, with async |
| `serde` | Serialization and deserialization — convert structs to/from JSON, binary, etc. | Phase 2, early |
| `criterion` | Benchmarking — measure how fast your code is | Every project |
| `tracing` | Structured logging and spans | Phase 3 onward |
| `arrow` | The columnar data format — DataFusion's data layer | Phase 5 |
| `parquet` | Parquet file format — how columnar data is stored on disk | Phase 5 |
| `datafusion` | The query engine — your primary contribution target | Phase 6 |
| `sqlparser` | SQL parsing — how DataFusion turns SQL text into a structured AST | Phase 6 |
| `bytes` | Zero-copy byte buffers — used in networking and storage layers | Phase 4 |
| `rayon` | Data parallelism — parallel iterators for CPU-bound work | Phase 4 |
| `dashmap` | A concurrent hash map that does not require a Mutex for reads | Phase 7 |
| `prost` | Protocol Buffers — serialization format used in distributed systems | Phase 7 |
| `tonic` | gRPC — the RPC framework used in distributed systems | Phase 7 |
| `openraft` | Raft consensus algorithm — Joe contributed to this | Phase 7 |
| `tokio-postgres` | Postgres client in Rust — Joe contributed to this | Phase 8 |
| `pgrx` | Write Postgres extensions in Rust instead of C | Phase 8 |
| `memmap2` | Memory-mapped files — used in storage engine experiments | Phase 3 |

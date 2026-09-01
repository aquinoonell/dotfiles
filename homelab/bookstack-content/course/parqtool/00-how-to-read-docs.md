# parq-tool: Complete Build Guide

> Build a CLI tool that reads Parquet files, runs SQL via DataFusion, and writes results to Parquet or Postgres. Every resource in this file links to official documentation. Every snippet comes directly from those docs. The goal is that you can build this alone, using these resources, without generated code.

## How to Read Documentation

This is the skill that makes everything else possible. Before you write a single line of code for any layer, spend time reading the docs for what you are about to use. Here is the exact process.

### The three questions to answer before using anything

Every time you encounter a type, function, or method you have not used before, answer these three questions by looking at its docs page before writing any code.

**Where does it come from?** What crate, what module, what path do you need to import it from? The import path is always shown at the top of the docs page as the full path — for example `parquet::arrow::arrow_reader::ParquetRecordBatchReaderBuilder`.

**What does it accept as input?** Look at the function signature on the docs page. `try_new(file: T) -> Result<Self>` tells you it accepts any `T` that implements `ChunkReader`, and that it returns a `Result` that you must handle.

**What does it return?** If it returns `Result<T, E>`, every call site needs `.expect("message")` or `?` to handle the error case. If it returns `Option<T>`, you need `if let Some(x) = ...` or `.unwrap()`.

### How to navigate the docs

Every Rust crate has two documentation homes. The module-level docs at `docs.rs/crate-name` explain the overall design, show worked examples, and link to the main types. The type-level docs show every method, its signature, and a short example. Always read the module page first, then the type page, then the method page.

The URL pattern for docs.rs is always:

```
https://docs.rs/CRATE/latest/CRATE_NAME/path/to/Type.html
```

For Apache Arrow specifically, the docs live at `arrow.apache.org/rust/` instead of `docs.rs`:

```
https://arrow.apache.org/rust/arrow/path/to/Type.html
```

## Project Structure

```
parq-tool/
    Cargo.toml
    src/
        main.rs          <- Layer 1 (Parquet reader, runs first)
        bin/
            query.rs     <- Layer 2 (DataFusion SQL)
            write.rs     <- Layer 3 (write to Parquet)
            pg.rs        <- Layer 4 (write to Postgres)
```

Build and run each binary separately:

```bash
cargo run                        # runs src/main.rs
cargo run --bin query            # runs src/bin/query.rs
cargo run --bin write            # runs src/bin/write.rs
cargo run --bin pg               # runs src/bin/pg.rs
```

## Cargo.toml

```toml
[package]
name = "parq-tool"
version = "0.1.0"
edition = "2021"

[[bin]]
name = "query"
path = "src/bin/query.rs"

[[bin]]
name = "write"
path = "src/bin/write.rs"

[[bin]]
name = "pg"
path = "src/bin/pg.rs"

[dependencies]
# DataFusion re-exports Arrow and Parquet — use those re-exports everywhere
datafusion = "44"

# Tokio is the async runtime DataFusion runs on
tokio = { version = "1", features = ["full"] }

# Parquet crate for reading/writing Parquet files directly
parquet = { version = "55", features = ["arrow"] }

# Postgres async client — the crate Joe contributed to
tokio-postgres = "0.7"

# CLI argument parsing
clap = { version = "4", features = ["derive"] }
```

**Important:** Before writing any code, check the latest versions at crates.io. The versions above may be outdated.

## What to Do When You Are Stuck

### Compile error: "cannot find type X in this scope"

You are missing an import or the type is in a different module than you think. Go to the docs page for that type — the full path is shown at the top.

### Compile error: "mismatched types — two versions of arrow_schema"

You have a version mismatch. Remove any standalone `arrow` dependency from Cargo.toml and use `datafusion::arrow::...` for all Arrow types instead.

### Compile error: "the trait ToSql is not implemented for X"

The type you are trying to pass to `tokio-postgres` does not implement `ToSql`. Convert it to a type that does (`i64`, `f64`, `String`, `bool`, `Option<T>`).

### Runtime panic on a downcast

You tried to downcast an `ArrayRef` to the wrong concrete type. Print `column.data_type()` before the downcast to see what type the column actually is.

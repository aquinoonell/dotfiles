# Rust Data Engineering Stack

Offline learning path for **Apache Arrow**, **Parquet**, and **DataFusion** in Rust.

## How the pieces fit

| Layer | Crate | Role |
|-------|-------|------|
| **Memory** | `arrow` | Columnar in-memory format — `RecordBatch`, arrays, schemas |
| **Storage** | `parquet` | Columnar files on disk — read/write via `ArrowWriter` |
| **Query** | `datafusion` | SQL engine on Arrow — `SessionContext`, `ExecutionPlan` |

```
Parquet file on disk
    → parquet crate reads into RecordBatch (Arrow)
    → datafusion registers as table, runs SQL
    → results stream as RecordBatch batches
    → parquet crate writes output files
```

## Reading order

1. [Rust for Databases](patterns.html) — `Arc`, `RwLock`, iterators, async streams
2. [Apache Arrow](arrow.html) — `RecordBatch`, downcasting, null handling
3. [Parquet](parquet.html) — read/write files, compression, version pitfalls
4. [DataFusion](datafusion.html) — SQL pipeline, UDFs, contributing
5. [Database Internals](database-internals.html) — B+Tree, WAL, MVCC context
6. [PostgreSQL](../db/postgres.html) — client–server, WAL, homelab CT 110
7. [DuckDB](../db/duckdb.html) — embedded OLAP on Parquet (Mac CLI, no CT)

## Cargo.toml starter

```toml
[dependencies]
datafusion = "44"
tokio = { version = "1", features = ["full"] }

# Import Arrow THROUGH datafusion to avoid version mismatch:
# use datafusion::arrow::array::Int64Array;
```

## CLI tools

```bash
cargo install datafusion-cli
datafusion-cli
# CREATE EXTERNAL TABLE t STORED AS PARQUET LOCATION 'data.parquet';
# SELECT * FROM t LIMIT 10;
```

## More reading

The curated pages in this guide cover Arrow, Parquet, and DataFusion in Rust with code examples.

**Postgres and DuckDB** (how they work, vs this stack): [start here](../db/index.html). API reference ZIMs: [PostgreSQL DevDocs](http://kiwix.lan/content/devdocs_en_postgresql_2026-05), [DuckDB DevDocs](http://kiwix.lan/content/devdocs_en_duckdb_2026-04). Homelab ops: `~/dotfiles/homelab/POSTGRES.md`.

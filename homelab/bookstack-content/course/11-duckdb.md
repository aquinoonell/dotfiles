# How DuckDB Works

DuckDB is an **embedded analytical (OLAP)** database. There is no daemon and no port 5432. The engine runs **in your process**: the `duckdb` CLI, a Python session, or the Rust `duckdb` crate. Storage is either a single `.duckdb` file or — more often for this course — **Parquet/CSV files you already have**.

Install on the Mac (not on Proxmox):

```bash
brew install duckdb
duckdb
```

## Why it feels like Postgres but is not

SQL is close (types, `SELECT`/`JOIN`/`GROUP BY`, `EXPLAIN`). The engine is not:

| Postgres | DuckDB |
|----------|--------|
| Row-oriented pages, one tuple at a time in the executor (with some batching) | **Vectorized / columnar** — operate on batches of values in a column |
| Buffer pool + WAL for OLTP durability | Designed for scans and aggregations over files |
| Network protocol | Function calls in-process |
| `INSERT` one row from an app | `SELECT count(*) FROM 'huge.parquet'` in milliseconds |

If DataFusion is “a query engine you embed in Rust,” DuckDB is “a complete OLAP database you embed,” with a mature SQL parser, optimizer, and Parquet reader. Use DuckDB to **explore**; use DataFusion to **implement**.

## Execution model (the part that maps to internals)

DuckDB is in the MonetDB/X100 family: **vectorized execution**. Operators pull **vectors** (chunks of a column), not one row per `next()`. That is the same idea as DataFusion’s `RecordBatch` streams, with a different codebase.

```
Parquet file on disk
    → DuckDB scans only the columns the query needs
    → vectorized operators (filter, hash aggregate, join)
    → result printed or COPY to another file
```

Column pruning and predicate pushdown into Parquet are why `SELECT a FROM 'data.parquet' WHERE b > 10` does not read the whole file.

## SQL on files (no CREATE TABLE required)

```sql
-- inside duckdb CLI
SELECT count(*) FROM 'data.parquet';
SELECT col, avg(x) FROM 'data.parquet' GROUP BY 1;
EXPLAIN SELECT * FROM 'data.parquet' WHERE x > 10;
COPY (SELECT * FROM 'data.parquet' WHERE x > 10) TO 'out.parquet' (FORMAT PARQUET);
```

A persistent catalog is optional:

```sql
duckdb analytics.duckdb
-- then:
CREATE TABLE t AS SELECT * FROM 'data.parquet';
```

That `.duckdb` file is still just a file. Copy it, delete it, Syncthing it. No CT.

## Talking to homelab Postgres (optional)

DuckDB can **scan** Postgres when you want OLAP SQL over OLTP tables:

```sql
INSTALL postgres;
LOAD postgres;
ATTACH 'host=postgres.lan user=postgres password=password dbname=parq' AS pg (TYPE postgres);
SELECT * FROM pg.public.some_table LIMIT 10;
```

That is the triangle on one prompt: files (DuckDB) + server (Postgres). Do this after CT 110 is up.

## Versus DataFusion in Rust

```sql
-- DuckDB: engine is the product
SELECT * FROM 'data.parquet' LIMIT 10;
```

```rust
// DataFusion: you own SessionContext, plans, RecordBatches
ctx.register_parquet("data", "data.parquet", Default::default()).await?;
ctx.sql("SELECT * FROM data LIMIT 10").await?;
```

Same files, different job. If a DuckDB query is fast and a DataFusion query is slow, that is a learning signal (plan, batch size, predicates) — not a reason to delete DataFusion.

## Reference

- [DuckDB docs](https://duckdb.org/docs/)
- [DevDocs](https://devdocs.io/duckdb/)
- Curated stack: [Arrow](../rust/arrow.html) · [Parquet](../rust/parquet.html) · [DataFusion](../rust/datafusion.html)

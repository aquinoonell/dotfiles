# Postgres, DuckDB, and DataFusion

Three ways to run SQL on data. They are not interchangeable — that is the point.

| | PostgreSQL | DuckDB | DataFusion |
|--|------------|--------|------------|
| Kind | Client–server **OLTP** | Embedded **OLAP** | Embedded **query engine** (you use it as a library) |
| Process | Always-on daemon, port 5432 | In-process (CLI or crate) | In-process (`SessionContext`) |
| Storage | Its own data directory (row pages, WAL) | `.duckdb` file **or** Parquet/CSV in place | You bring files (Parquet); it does not own a catalog by default |
| On this homelab | **CT 110** · `postgres.lan` | Install on the Mac — no CT | `parq-tool` / Rust labs |

```
Parquet files (columnar, on disk)
    ├─ DuckDB        SELECT … FROM 'data.parquet'
    ├─ DataFusion    register table, run SQL, get RecordBatches
    └─ Postgres      COPY/INSERT results into tables (parq-tool Layer 4)
```

## When to use which

- **DuckDB** — explore a file in seconds. No server. Same SQL mental model as Postgres, columnar engine underneath.
- **DataFusion** — you are *building* or embedding a query engine in Rust (Arrow in, Arrow out).
- **Postgres** — a real networked database: users, transactions, WAL, indexes that survive reboot. This is what `tokio-postgres` talks to.

## Reading order

1. [How PostgreSQL works](postgres.html) — processes, WAL, MVCC, then the homelab CT
2. [How DuckDB works](duckdb.html) — vectorized execution, Parquet, CLI
3. [Database internals](../rust/database-internals.html) — B+Tree, buffer pool, why WAL exists
4. DevDocs ZIMs (API reference): [PostgreSQL](http://kiwix.lan/content/devdocs_en_postgresql_2026-05) · [DuckDB](http://kiwix.lan/content/devdocs_en_duckdb_2026-04)

Ops (connect, backup, `parq-tool`): see `~/dotfiles/homelab/POSTGRES.md` on the Mac.

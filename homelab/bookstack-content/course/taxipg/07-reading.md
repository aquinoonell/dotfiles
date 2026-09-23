# Reading list (concepts → pages)

Read **in this order** while you type the crate. Official docs win over blog posts.

## Connection and Postgres as a server

| Concept | Read |
|---------|------|
| What a postmaster/backend is | [How PostgreSQL works](../db/postgres.html) |
| Connection string | [libpq](https://www.postgresql.org/docs/16/libpq-connect.html#LIBPQ-CONNSTRING) |
| `psql` | [psql](https://www.postgresql.org/docs/16/app-psql.html) |
| SQL reference (offline) | [DevDocs PostgreSQL](http://kiwix.lan/content/devdocs_en_postgresql_2026-05) |
| Homelab CT | `~/dotfiles/homelab/POSTGRES.md` |
| WAL / why not a library | [Database internals](../rust/database-internals.html) (WAL, MVCC) |

## Schema and SQL on the server

| Concept | Read |
|---------|------|
| CREATE TABLE | https://www.postgresql.org/docs/16/sql-createtable.html |
| ON CONFLICT | https://www.postgresql.org/docs/16/sql-insert.html |
| EXPLAIN | https://www.postgresql.org/docs/16/sql-explain.html |
| Dates | https://www.postgresql.org/docs/16/datatype-datetime.html |

## DataFusion (job)

| Concept | Read |
|---------|------|
| `SessionContext` | https://docs.rs/datafusion/54.1.0/datafusion/execution/context/struct.SessionContext.html |
| `collect` | https://docs.rs/datafusion/54.1.0/datafusion/dataframe/struct.DataFrame.html#method.collect |
| SQL | https://datafusion.apache.org/user-guide/sql/index.html |
| Architecture | [DataFusion guide](../rust/datafusion.html) + https://datafusion.apache.org/contributor-guide/architecture.html |
| Tokio | https://docs.rs/tokio/latest/tokio/attr.main.html |

## Arrow (values)

| Concept | Read |
|---------|------|
| RecordBatch | https://docs.rs/arrow/latest/arrow/array/struct.RecordBatch.html |
| Downcast | Int64Array / Float64Array / Date32Array on docs.rs/arrow |
| Columnar vs row | [Arrow](../rust/arrow.html), [Parquet](../rust/parquet.html) |

## Rust client

| Concept | Read |
|---------|------|
| connect + spawn | https://docs.rs/tokio-postgres/latest/tokio_postgres/fn.connect.html |
| Client | https://docs.rs/tokio-postgres/latest/tokio_postgres/struct.Client.html |
| Layer 4 notes | `~/dotfiles/homelab/bookstack-content/course/parqtool/04-layer4-postgres.md` |
| Cargo.toml | https://doc.rust-lang.org/cargo/reference/specifying-dependencies.html |

## Optional contrast

- [DuckDB](../db/duckdb.html) — same Parquet, no server; can `ATTACH` Postgres later
- [DuckDB DevDocs](http://kiwix.lan/content/devdocs_en_duckdb_2026-04)

## ZIM library

Full offline catalog: [http://kiwix.lan](http://kiwix.lan)

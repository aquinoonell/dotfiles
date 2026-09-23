# Lake → job → Postgres

A lab course for **your** homelab: NYC yellow taxi Parquet on the Mac, DataFusion as the job, PostgreSQL on **CT 110** (`postgres.lan`) as the serving database.

You **write the Rust crate yourself** (`cargo new taxi-pg`). These pages are the textbook: concepts, commented snippets, and what to read.

## The story (why this shape is “real”)

Finance wants January 2026 **how people paid** and **how busy each day was**. Millions of trip rows stay in a **file** (a stand-in for a data lake / S3). A **job** scans and aggregates. Postgres only stores **small marts** a dashboard would query — plus a **run log**.

``` {.text data-file="diagram" data-do="the pipeline"}
Parquet on disk (lake)
    → DataFusion SQL (job, in-process on the Mac)
    → INSERT into parq.payment_mix + parq.trips_daily
    → etl_runs records success/failure
    → you SELECT / EXPLAIN in psql (dashboard user)
```

That is congruent with **analytics → serving**, not with writing Postgres internals. You are *using* two engines.

## What you need on the homelab

| Piece | Where |
|-------|--------|
| Postgres 16 | CT 110 · `postgres.lan:5432` · db `parq` |
| HTML guides | [this site](index.html) · also [Rust stack](../rust/index.html) · [Postgres/DuckDB](../db/index.html) |
| ZIM API docs | [kiwix.lan PostgreSQL](http://kiwix.lan/content/devdocs_en_postgresql_2026-05) |
| Taxi file | `/Users/onell/Downloads/yellow_tripdata_2026-01.parquet` (~61 MB) |

Do **not** load the whole Parquet file into Postgres. The CT is 16 GB; the lesson is **scan in DataFusion, store the answer**.

## Pages

1. [Connect](connect.html) — `psql`, DNS, Docker `172.18.0.2`
2. [Schema](schema.html) — `CREATE TABLE`, primary keys
3. [DataFusion](datafusion.html) — `register_parquet`, `sql`, `collect`
4. [Arrow batches](arrow.html) — downcast columns
5. [tokio-postgres](client.html) — `connect` + spawn
6. [The job](job.html) — upsert + `etl_runs`
7. [Reading list](reading.html) — docs mapped to each idea

## Docs to read first (overview)

- [How PostgreSQL works](../db/postgres.html) — process model, WAL (why it is a server)
- [DataFusion in Rust](../rust/datafusion.html) — logical vs physical plan
- [Apache Arrow](../rust/arrow.html) — `RecordBatch`

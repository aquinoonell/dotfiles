# Schema: serving tables, not the lake

## Docs to read first

- [CREATE TABLE](https://www.postgresql.org/docs/16/sql-createtable.html)
- [INSERT … ON CONFLICT](https://www.postgresql.org/docs/16/sql-insert.html) (you will use this in the job)
- [DATE / TIMESTAMPTZ](https://www.postgresql.org/docs/16/datatype-datetime.html)
- DevDocs: [PostgreSQL](http://kiwix.lan/content/devdocs_en_postgresql_2026-05)

## Why three tables

| Table | Role in a real team |
|-------|---------------------|
| `etl_runs` | Job observability: did last night’s load succeed? |
| `payment_mix` | Mart: payment_type × month |
| `trips_daily` | Mart: one row per calendar day |

Raw trips **stay in Parquet**. These tables are what a dashboard would hit.

## SQL to run in `psql` (type this)

``` {.sql data-file="psql" data-do="type this — creates the three tables"}
-- Job log: one row per cargo run
CREATE TABLE IF NOT EXISTS etl_runs (
  id           SERIAL PRIMARY KEY,           -- auto-increment run id
  job          TEXT NOT NULL,                -- name, e.g. taxi_january_marts
  period       DATE NOT NULL,                -- month grain: 2026-01-01
  started_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  finished_at  TIMESTAMPTZ,                  -- null while running
  rows_written INT,
  status       TEXT NOT NULL                 -- running | success | failed
);

-- Serving mart: how people paid (TLC codes 1=card, 2=cash, …)
CREATE TABLE IF NOT EXISTS payment_mix (
  period        DATE NOT NULL,               -- first of month
  payment_type  INT NOT NULL,
  trips         BIGINT NOT NULL,
  revenue       DOUBLE PRECISION NOT NULL,
  loaded_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  -- re-running the job updates the same month, does not duplicate
  PRIMARY KEY (period, payment_type)
);

-- Serving mart: volume by day (~31 rows for January, not millions)
CREATE TABLE IF NOT EXISTS trips_daily (
  day         DATE PRIMARY KEY,
  trips       BIGINT NOT NULL,
  revenue     DOUBLE PRECISION NOT NULL,
  avg_miles   DOUBLE PRECISION,
  loaded_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

Check:

``` {.sql data-file="psql" data-do="confirm the tables exist"}
\d payment_mix
\d trips_daily
\d etl_runs
```

`DOUBLE PRECISION` is easier from Rust `f64` than `NUMERIC` (which needs extra crates). Fine for a lab.

## Concept: primary key = upsert target

`ON CONFLICT (period, payment_type)` only works if that uniqueness exists. The PK **is** the conflict target. Read the INSERT page section **ON CONFLICT**.

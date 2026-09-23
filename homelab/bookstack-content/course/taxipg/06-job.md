# The job: upsert marts and log the run

## Docs to read first

- [INSERT ON CONFLICT](https://www.postgresql.org/docs/16/sql-insert.html)
- [EXPLAIN](https://www.postgresql.org/docs/16/sql-explain.html)
- Previous pages: [schema](schema.html), [DataFusion](datafusion.html), [Arrow](arrow.html), [client](client.html)

## Order of operations in `main`

1. `connect` + spawn `connection`
2. `INSERT INTO etl_runs … status = 'running' RETURNING id`
3. DataFusion: mix query + daily query → `collect`
4. For each mix row: `INSERT … ON CONFLICT DO UPDATE`
5. For each daily row: same
6. `UPDATE etl_runs SET status = 'success', rows_written = $1, finished_at = now() WHERE id = $2`  
   On error: `status = 'failed'`

Re-running `cargo run` **replaces** January; it must not duplicate. That is a nightly job.

## Upsert (payment mix)

``` {.rust data-file="src/main.rs" data-do="upsert payment_mix"}
use chrono::NaiveDate;

let period = NaiveDate::from_ymd_opt(2026, 1, 1).unwrap();

client
    .execute(
        // EXCLUDED = the row we tried to insert
        "INSERT INTO payment_mix (period, payment_type, trips, revenue) \
         VALUES ($1, $2, $3, $4) \
         ON CONFLICT (period, payment_type) DO UPDATE SET \
           trips = EXCLUDED.trips, \
           revenue = EXCLUDED.revenue, \
           loaded_at = now()",
        &[&period, &payment_type, &trips, &revenue],
    )
    .await?;
```

`trips_daily` uses `ON CONFLICT (day)` the same way.

## Dashboard checks (psql)

``` {.sql data-file="psql" data-do="run after cargo run"}
SELECT * FROM etl_runs ORDER BY id DESC LIMIT 5;

SELECT payment_type, trips, revenue,
       round(100.0 * trips / sum(trips) OVER (), 1) AS pct
FROM payment_mix
WHERE period = DATE '2026-01-01'
ORDER BY trips DESC;

SELECT day, trips FROM trips_daily ORDER BY trips DESC LIMIT 7;

-- PK should allow an index lookup
EXPLAIN SELECT * FROM payment_mix
WHERE period = DATE '2026-01-01' AND payment_type = 1;
```

TLC `payment_type`: 1 credit, 2 cash, 3 no charge, 4 dispute, 5 unknown, 6 voided.

## New crate reminder

``` {.bash data-file="terminal" data-do="create the crate (once)"}
cd ~/Desktop/dev
cargo new taxi-pg
cd taxi-pg
```

Do not add a third binary to `~/Desktop/dev/datafusion`. One `src/main.rs`.

## What you practiced vs production

| Lab | Production analog |
|-----|-------------------|
| Parquet in Downloads | Object storage |
| `cargo run` | Cron / Airflow |
| DataFusion | Spark / DuckDB / BigQuery job |
| Three tables | Serving marts + run history |
| `psql` | Metabase / API |

Still toy: no TLS, password in the DSN, no pool, no S3. The **pipeline roles** are the real part.

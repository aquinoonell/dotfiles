# DataFusion: SQL on the Parquet file

## Docs to read first

- [`SessionContext`](https://docs.rs/datafusion/54.1.0/datafusion/execution/context/struct.SessionContext.html) — `register_parquet`, `sql`
- [`DataFrame::collect`](https://docs.rs/datafusion/54.1.0/datafusion/dataframe/struct.DataFrame.html#method.collect)
- SQL: https://datafusion.apache.org/user-guide/sql/index.html
- Intro: https://datafusion.apache.org/user-guide/introduction.html
- This homelab: [DataFusion guide](../rust/datafusion.html)
- Your old experiment: `~/Desktop/dev/datafusion/datafusion/src/bin/query.rs`

Match **datafusion 54.x** in `Cargo.toml` (same major as that crate). If docs.rs 404s, `cargo tree -p datafusion` and pick that version on docs.rs.

## What DataFusion is doing

You are **not** sending this SQL to Postgres. `SessionContext` parses SQL, plans it, and **executes on Arrow batches read from Parquet** (column pruning, filters). Postgres is later.

``` {.text data-file="diagram" data-do="DataFusion, not Postgres"}
SQL string
  → logical plan → optimized plan → physical plan
  → RecordBatch stream
  → collect() = Vec<RecordBatch> in memory
```

## Cargo

``` {.toml data-file="Cargo.toml" data-do="add these dependencies"}
[dependencies]
tokio = { version = "1", features = ["full"] }
datafusion = "54"
```

`prelude` already has `SessionContext` and `ParquetReadOptions`. You do not need `datasource::file_format::parquet` for this lab.

## Correct Step-2 program

``` {.rust data-file="src/main.rs" data-do="replace the whole file"}
use datafusion::prelude::*;

#[tokio::main]
async fn main() -> datafusion::error::Result<()> {
    // Path on YOUR Mac — this is the "lake"
    let parquet_path = "/Users/onell/Downloads/yellow_tripdata_2026-01.parquet";

    let ctx = SessionContext::new();

    // register_parquet is a METHOD on ctx, not a free function.
    // Arg 1 = SQL table name (use this in FROM …)
    // Arg 2 = file path
    // Arg 3 = options — default() is sync; .await belongs on register_parquet
    ctx.register_parquet("trips", parquet_path, ParquetReadOptions::default())
        .await?;

    // sql() returns a DataFrame — THAT is what you collect, not register_parquet
    let df = ctx
        .sql(
            "SELECT payment_type, count(*) AS trips, sum(total_amount) AS revenue \
             FROM trips \
             WHERE payment_type IS NOT NULL \
             GROUP BY payment_type",
        )
        .await?;

    let batches = df.collect().await?;
    for batch in &batches {
        // There is no batch_schema() function — schema() is on RecordBatch
        println!("{}", batch.schema());
    }
    Ok(())
}
```

## Mistakes this page exists to kill

| Wrong | Why it fails |
|-------|----------------|
| `register_parquet(...)` without `ctx.` | It is not a free function |
| `ParquetReadOptions::default().await` | `default()` is not async |
| Using `df` from register and never assigning `sql()` | Mixes two APIs |
| `print!("{}", batch_schema())` | Use `batch.schema()` after `collect` |

## Second query (daily mart)

After the mix works, same `ctx`, new `sql`:

``` {.sql data-file="src/main.rs" data-do="second ctx.sql(...) string"}
SELECT
  CAST(tpep_pickup_datetime AS DATE) AS day,
  count(*) AS trips,
  sum(total_amount) AS revenue,
  avg(trip_distance) AS avg_miles
FROM trips
GROUP BY 1
ORDER BY 1
```

Print **that** schema too. `day` may be `Date32` or a `Timestamp` — you need the real type for downcasting.

**Done when:** `cargo run` prints schemas. Write the `DataType`s down for the Arrow page.

# Layer 2 — Run SQL with DataFusion

## What you are building

`src/bin/query.rs` — registers the Parquet file as a DataFusion table, runs a SQL query, and prints results.

## Documentation to read first

**DataFusion example usage — start here:**
https://datafusion.apache.org/user-guide/example-usage.html

This page has the simplest working DataFusion program:

```rust
use datafusion::prelude::*;

#[tokio::main]
async fn main() -> datafusion::error::Result<()> {
  // register the table
  let ctx = SessionContext::new();
  ctx.register_csv("example", "tests/data/example.csv", CsvReadOptions::new()).await?;

  // create a plan to run a SQL query
  let df = ctx.sql("SELECT a, MIN(b) FROM example WHERE a <= b GROUP BY a LIMIT 100").await?;

  // execute and print results
  df.show().await?;
  Ok(())
}
```

For Parquet, replace `register_csv` with `register_parquet` and `CsvReadOptions::new()` with `ParquetReadOptions::default()`. The rest is identical.

**SessionContext API docs:**
https://docs.rs/datafusion/latest/datafusion/execution/context/struct.SessionContext.html

Look for `register_parquet`, `sql`, `read_parquet` on this page.

**DataFusion's Arrow introduction:**
https://datafusion.apache.org/user-guide/arrow-introduction.html

This page explains exactly how to downcast `ArrayRef` values from a DataFusion result.

## The architecture you need to understand

DataFusion processes a query in this order:

```
SQL string
    -> sqlparser parses to an AST
    -> SessionContext converts to a LogicalPlan
    -> LogicalOptimizer rewrites the plan
    -> PhysicalPlanner converts to an ExecutionPlan tree
    -> ExecutionPlan::execute() runs per partition on tokio
    -> Returns a stream of RecordBatches
    -> df.collect().await? gathers all batches into Vec<RecordBatch>
    -> df.show().await? prints them as a table
```

The physical plan is what `EXPLAIN` shows you.

## What to implement

Build `src/bin/query.rs` to:

1. Create a `SessionContext`
2. Call `ctx.register_parquet("trips", "path/to/file.parquet", ParquetReadOptions::default()).await?`
3. Call `ctx.sql("SELECT ...").await?` to get a `DataFrame`
4. Call `df.clone().explain(false, false)?.show().await?` to print the execution plan
5. Call `df.show().await?` to print results

## Imports for Layer 2

```rust
use datafusion::prelude::*;
// datafusion::prelude re-exports SessionContext, ParquetReadOptions,
// col, lit, and everything you need for basic usage
```

## Example Query

```rust
use datafusion::prelude::*;
use datafusion::error::Result;

#[tokio::main]
async fn main() -> Result<()> {
    let ctx = SessionContext::new();
    
    ctx.register_parquet(
        "trips",
        "yellow_tripdata_2024-01.parquet",
        ParquetReadOptions::default(),
    ).await?;
    
    let df = ctx.sql("
        SELECT 
            passenger_count,
            COUNT(*) as trip_count,
            AVG(fare_amount) as avg_fare,
            SUM(tip_amount) as total_tips
        FROM trips
        WHERE fare_amount > 0
        GROUP BY passenger_count
        ORDER BY trip_count DESC
        LIMIT 10
    ").await?;
    
    // Print the execution plan
    df.clone().explain(false, false)?.show().await?;
    
    // Execute and print results
    df.show().await?;
    
    Ok(())
}
```

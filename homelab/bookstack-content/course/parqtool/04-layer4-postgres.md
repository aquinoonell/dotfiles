# Layer 4 — Write Results to Postgres

## What you are building

`src/bin/pg.rs` — takes DataFusion query results and writes them to a Postgres table, creating the table from the Arrow schema.

This is the hardest layer. You have to map Arrow types to Postgres types, generate a `CREATE TABLE` statement from a schema you have never seen before, and insert rows from Arrow batches. Do not skip Layers 1–3 before attempting this.

## Documentation to read first

**tokio-postgres crate docs:**
https://docs.rs/tokio-postgres/latest/tokio_postgres/

```rust
use tokio_postgres::{NoTls, Error};

#[tokio::main]
async fn main() -> Result<(), Error> {
    // Connect to the database.
    let (client, connection) =
        tokio_postgres::connect("host=localhost user=postgres", NoTls).await?;

    // The connection object performs the actual communication with the database,
    // so spawn it off to run on its own.
    tokio::spawn(async move {
        if let Err(e) = connection.await {
            eprintln!("connection error: {}", e);
        }
    });

    // Now we can execute a simple statement
    let rows = client
        .query("SELECT $1::TEXT", &[&"hello world"])
        .await?;

    let value: &str = rows[0].get(0);
    assert_eq!(value, "hello world");

    Ok(())
}
```

**The connection pattern:** `tokio_postgres::connect` returns a `(Client, Connection)` tuple. The `Connection` is a future that drives the actual I/O — it must be kept running, so you spawn it as a separate tokio task.

**Client struct:**
https://docs.rs/tokio-postgres/latest/tokio_postgres/struct.Client.html

Methods you need:
- `batch_execute(&str)` — run multiple SQL statements, no parameters. Use for `CREATE TABLE`.
- `prepare(&str)` — create a prepared statement. Returns a `Statement`.
- `execute(&Statement, &[&dyn ToSql])` — run a prepared statement with parameters.
- `transaction()` — start a transaction.

## Arrow Type to Postgres Type Mapping

```rust
use datafusion::arrow::datatypes::DataType;

fn arrow_type_to_pg(dt: &DataType) -> &'static str {
    match dt {
        DataType::Int8  | DataType::Int16 => "SMALLINT",
        DataType::Int32 => "INTEGER",
        DataType::Int64 => "BIGINT",
        DataType::Float32 => "REAL",
        DataType::Float64 => "DOUBLE PRECISION",
        DataType::Utf8 | DataType::LargeUtf8 => "TEXT",
        DataType::Boolean => "BOOLEAN",
        DataType::Date32 => "DATE",
        DataType::Timestamp(_, _) => "TIMESTAMPTZ",
        _ => "TEXT",  // fallback — cast unknowns to text
    }
}
```

## The Three Steps

### Step 1: Generate and run CREATE TABLE

Build a SQL string from the Arrow schema:

```sql
CREATE TABLE IF NOT EXISTS trips (
    vendor_id TEXT,
    tpep_pickup_datetime TIMESTAMPTZ,
    passenger_count BIGINT,
    trip_distance DOUBLE PRECISION,
    fare_amount DOUBLE PRECISION
)
```

### Step 2: Prepare an INSERT statement

```rust
// Example with 3 columns
let insert_sql = "INSERT INTO trips (col1, col2, col3) VALUES ($1, $2, $3)";
let stmt = client.prepare(insert_sql).await?;
```

### Step 3: Insert rows from RecordBatches inside a transaction

```rust
let txn = client.transaction().await?;

for batch in &batches {
    for row_idx in 0..batch.num_rows() {
        // Build params for this row
        let params: Vec<&(dyn tokio_postgres::types::ToSql + Sync)> = vec![
            // extract values from each column
        ];
        txn.execute(&stmt, &params).await?;
    }
}

txn.commit().await?;
```

**Why transactions matter:** Without a transaction, each `INSERT` is committed individually, which means one disk flush per row. With a transaction, all inserts are committed at once.

## Extracting Values from Arrow Arrays

```rust
use datafusion::arrow::array::Int64Array;

let col = batch.column(col_index);
let arr = col.as_any().downcast_ref::<Int64Array>().unwrap();

let value: Option<i64> = if arr.is_null(row_index) {
    None
} else {
    Some(arr.value(row_index))
};
// pass `&value` as a ToSql parameter — Option<i64> implements ToSql
```

## Imports for Layer 4

```rust
use tokio_postgres::{NoTls, Error};
use datafusion::prelude::*;
use datafusion::arrow::datatypes::DataType;
use datafusion::arrow::array::{Int64Array, Float64Array, StringArray, BooleanArray};
```

## Complete Example

```rust
use tokio_postgres::NoTls;
use datafusion::prelude::*;
use datafusion::arrow::datatypes::DataType;
use datafusion::arrow::array::{Int64Array, Float64Array, StringArray};

fn arrow_type_to_pg(dt: &DataType) -> &'static str {
    match dt {
        DataType::Int64 => "BIGINT",
        DataType::Float64 => "DOUBLE PRECISION",
        DataType::Utf8 => "TEXT",
        _ => "TEXT",
    }
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Connect to Postgres
    let (client, connection) = tokio_postgres::connect(
        "host=localhost user=postgres password=password dbname=postgres",
        NoTls,
    ).await?;
    
    tokio::spawn(async move {
        if let Err(e) = connection.await {
            eprintln!("connection error: {}", e);
        }
    });
    
    // Run DataFusion query
    let ctx = SessionContext::new();
    ctx.register_parquet("trips", "yellow_tripdata_2024-01.parquet", ParquetReadOptions::default()).await?;
    
    let df = ctx.sql("SELECT passenger_count, fare_amount FROM trips LIMIT 100").await?;
    let batches = df.collect().await?;
    
    if batches.is_empty() {
        return Ok(());
    }
    
    let schema = batches[0].schema();
    
    // Build CREATE TABLE
    let mut create_sql = "CREATE TABLE IF NOT EXISTS trips (".to_string();
    for (i, field) in schema.fields().iter().enumerate() {
        if i > 0 { create_sql.push_str(", "); }
        create_sql.push_str(field.name());
        create_sql.push(' ');
        create_sql.push_str(arrow_type_to_pg(field.data_type()));
    }
    create_sql.push_str(")");
    
    client.batch_execute(&create_sql).await?;
    println!("Created table");
    
    // Prepare INSERT
    let col_names: Vec<_> = schema.fields().iter().map(|f| f.name().as_str()).collect();
    let placeholders: Vec<_> = (1..=schema.fields().len()).map(|i| format!("${}", i)).collect();
    let insert_sql = format!(
        "INSERT INTO trips ({}) VALUES ({})",
        col_names.join(", "),
        placeholders.join(", ")
    );
    let stmt = client.prepare(&insert_sql).await?;
    
    // Insert rows in a transaction
    let txn = client.transaction().await?;
    let mut total_rows = 0;
    
    for batch in &batches {
        for row_idx in 0..batch.num_rows() {
            // For this example, assume passenger_count (Int64) and fare_amount (Float64)
            let pc = batch.column(0).as_any().downcast_ref::<Int64Array>().unwrap();
            let fa = batch.column(1).as_any().downcast_ref::<Float64Array>().unwrap();
            
            let pc_val: Option<i64> = if pc.is_null(row_idx) { None } else { Some(pc.value(row_idx)) };
            let fa_val: Option<f64> = if fa.is_null(row_idx) { None } else { Some(fa.value(row_idx)) };
            
            txn.execute(&stmt, &[&pc_val, &fa_val]).await?;
            total_rows += 1;
        }
    }
    
    txn.commit().await?;
    println!("Inserted {} rows", total_rows);
    
    Ok(())
}
```

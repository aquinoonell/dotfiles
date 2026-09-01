# Layer 3 — Write Results to Parquet

## What you are building

`src/bin/write.rs` — takes DataFusion query results and writes them to a new Parquet file.

## Documentation to read first

**The parquet::arrow module — has the complete write example:**
https://arrow.apache.org/rust/parquet/arrow/index.html

```rust
use std::sync::Arc;
use arrow::array::{Int32Array, ArrayRef};
use arrow::record_batch::RecordBatch;
use parquet::arrow::ArrowWriter;
use parquet::file::properties::WriterProperties;
use parquet::basic::Compression;

let ids = Int32Array::from(vec![1, 2, 3, 4]);
let vals = Int32Array::from(vec![5, 6, 7, 8]);
let batch = RecordBatch::try_from_iter(vec![
    ("id", Arc::new(ids) as ArrayRef),
    ("val", Arc::new(vals) as ArrayRef),
]).unwrap();

let file = tempfile().unwrap();

// WriterProperties can be used to set Parquet file options
let props = WriterProperties::builder()
    .set_compression(Compression::SNAPPY)
    .build();

let mut writer = ArrowWriter::try_new(file, batch.schema(), Some(props)).unwrap();
writer.write(&batch).expect("Writing batch");

// writer must be closed to write footer
writer.close().unwrap();
```

**Critical:** `writer.close()` is mandatory. It writes the Parquet file footer. If you drop the writer without calling `close()`, you get a corrupted file.

**ArrowWriter:**
https://docs.rs/parquet/latest/parquet/arrow/arrow_writer/struct.ArrowWriter.html

From the docs, the `try_new` signature:

```
ArrowWriter::try_new(writer: W, arrow_schema: SchemaRef, props: Option<WriterProperties>) -> Result<Self>
```

`writer` is anything that implements `Write` — `std::fs::File` works. `arrow_schema` is the schema of the batches you will write.

## The connection between Layer 2 and Layer 3

DataFusion's `df.collect().await?` returns `Vec<RecordBatch>`. Each `RecordBatch` has a schema accessible via `.schema()`. You create an `ArrowWriter` using that schema, then call `writer.write(&batch)` for each batch, then `writer.close()`.

## What to implement

Build `src/bin/write.rs` to:

1. Run a DataFusion query and collect results into `Vec<RecordBatch>`
2. Get the schema from the first batch or from `df.schema()`
3. Open an output file with `std::fs::File::create("output.parquet")`
4. Create `ArrowWriter::try_new(output_file, schema, None)`
5. Loop over batches calling `writer.write(&batch)?`
6. Call `writer.close()?`
7. Verify the output by running Layer 1 against the output file

## Imports for Layer 3

```rust
use std::fs::File;
use std::sync::Arc;
use parquet::arrow::ArrowWriter;
use parquet::file::properties::WriterProperties;
use datafusion::prelude::*;
use datafusion::arrow::record_batch::RecordBatch;
```

## Complete Example

```rust
use std::fs::File;
use parquet::arrow::ArrowWriter;
use parquet::file::properties::WriterProperties;
use parquet::basic::Compression;
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
        SELECT passenger_count, fare_amount, tip_amount
        FROM trips
        WHERE fare_amount > 50
        LIMIT 1000
    ").await?;
    
    // Collect results
    let batches = df.collect().await?;
    
    if batches.is_empty() {
        println!("No results to write");
        return Ok(());
    }
    
    // Get schema from first batch
    let schema = batches[0].schema();
    
    // Create output file
    let output = File::create("high_fares.parquet")?;
    
    // Create writer with compression
    let props = WriterProperties::builder()
        .set_compression(Compression::SNAPPY)
        .build();
    
    let mut writer = ArrowWriter::try_new(output, schema, Some(props))?;
    
    // Write all batches
    for batch in &batches {
        writer.write(batch)?;
    }
    
    // Close writes the footer
    writer.close()?;
    
    println!("Wrote {} batches to high_fares.parquet", batches.len());
    
    Ok(())
}
```

# Parquet Deep Dive

Parquet is a columnar file format. Arrow is the in-memory columnar format. They are complementary: Parquet for storage, Arrow for computation.

## The Parquet Crate

**parquet crate overview:** https://arrow.apache.org/rust/parquet/index.html

From the docs:

> Most users will use ArrowWriter for writing and ParquetRecordBatchReaderBuilder for reading from synchronous IO sources such as files or in-memory buffers.

**The parquet::arrow module — the bridge between Parquet and Arrow:**
https://arrow.apache.org/rust/parquet/arrow/index.html

## Reading a Parquet File

```rust
use std::fs::File;
use parquet::arrow::arrow_reader::ParquetRecordBatchReaderBuilder;

let file = File::open("data.parquet").unwrap();
let builder = ParquetRecordBatchReaderBuilder::try_new(file).unwrap();
println!("Converted arrow schema is: {}", builder.schema());

let mut reader = builder.build().unwrap();
let record_batch = reader.next().unwrap().unwrap();
println!("Read {} records.", record_batch.num_rows());
```

Reading all batches:

```rust
let mut builder = ParquetRecordBatchReaderBuilder::try_new(file).unwrap();

// The builder has access to ParquetMetaData such
// as the number and layout of row groups
assert_eq!(builder.metadata().num_row_groups(), 1);

// Call build to create the reader
let mut reader: ParquetRecordBatchReader = builder.build().unwrap();

// Read data
while let Some(batch) = reader.next().transpose()? {
    println!("Read {} rows", batch.num_rows());
}
```

## Writing a Parquet File

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

let file = std::fs::File::create("output.parquet").unwrap();

// WriterProperties can be used to set Parquet file options
let props = WriterProperties::builder()
    .set_compression(Compression::SNAPPY)
    .build();

let mut writer = ArrowWriter::try_new(file, batch.schema(), Some(props)).unwrap();
writer.write(&batch).expect("Writing batch");

// writer must be closed to write footer
writer.close().unwrap();
```

**Critical:** `writer.close()` is mandatory. It writes the Parquet file footer. If you drop the writer without calling `close()`, you get a corrupted file with no readable metadata.

## Key APIs

**ParquetRecordBatchReaderBuilder:**
https://arrow.apache.org/rust/parquet/arrow/arrow_reader/type.ParquetRecordBatchReaderBuilder.html

**ArrowWriter:**
https://docs.rs/parquet/latest/parquet/arrow/arrow_writer/struct.ArrowWriter.html

**WriterProperties:**
https://docs.rs/parquet/latest/parquet/file/properties/struct.WriterProperties.html

## The Version Problem

DataFusion, Arrow, and Parquet must all use the same version of Arrow internally. If you add `arrow = "55"` separately from `datafusion = "44"` and DataFusion uses Arrow 53 internally, you will get compile errors like:

```
mismatched types [E0308] expected `Schema`, found `arrow_schema::Schema`
Note: perhaps two different versions of crate `arrow_schema` are being used?
```

**The fix:** always import Arrow types through DataFusion, not through a separate Arrow dependency.

```rust
// WRONG — may cause version mismatch
use arrow::array::Int64Array;

// RIGHT — always use the Arrow re-exported by DataFusion
use datafusion::arrow::array::Int64Array;
```

## NYC Taxi Data Example

Download one month of Yellow Taxi data from https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page

It is a Parquet file with real columnar data, real nulls, and millions of rows — everything you need to exercise all layers.

```rust
use std::fs::File;
use parquet::arrow::arrow_reader::ParquetRecordBatchReaderBuilder;
use datafusion::arrow::array::Float64Array;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let file = File::open("yellow_tripdata_2024-01.parquet")?;
    let builder = ParquetRecordBatchReaderBuilder::try_new(file)?;
    
    println!("Schema: {}", builder.schema());
    println!("Row groups: {}", builder.metadata().num_row_groups());
    
    let mut reader = builder.build()?;
    let mut total_fare: f64 = 0.0;
    let mut row_count: usize = 0;
    
    while let Some(batch) = reader.next() {
        let batch = batch?;
        row_count += batch.num_rows();
        
        // Find fare_amount column
        let schema = batch.schema();
        if let Ok(idx) = schema.index_of("fare_amount") {
            let col = batch.column(idx);
            if let Some(arr) = col.as_any().downcast_ref::<Float64Array>() {
                for i in 0..arr.len() {
                    if !arr.is_null(i) {
                        total_fare += arr.value(i);
                    }
                }
            }
        }
    }
    
    println!("Total rows: {}", row_count);
    println!("Total fare: ${:.2}", total_fare);
    
    Ok(())
}
```

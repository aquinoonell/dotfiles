# Layer 1 — Read a Parquet File

## What you are building

A `main.rs` that opens a Parquet file, prints its schema, and prints the row count of each batch.

## Documentation to read first

**The parquet crate overview:**
https://arrow.apache.org/rust/parquet/index.html

This page explains the overall structure: what a "row group" is, what a "batch" is, and why the crate exists. It also explains feature flags — you need `features = ["arrow"]` in Cargo.toml.

**The parquet::arrow module:**
https://arrow.apache.org/rust/parquet/arrow/index.html

This page has the complete working read-and-write example that comes directly from the docs:

```rust
let file = File::open("data.parquet").unwrap();
let builder = ParquetRecordBatchReaderBuilder::try_new(file).unwrap();
println!("Converted arrow schema is: {}", builder.schema());
let mut reader = builder.build().unwrap();
let record_batch = reader.next().unwrap().unwrap();
println!("Read {} records.", record_batch.num_rows());
```

**ParquetRecordBatchReaderBuilder:**
https://arrow.apache.org/rust/parquet/arrow/arrow_reader/type.ParquetRecordBatchReaderBuilder.html

The pattern for reading all batches:

```rust
let mut builder = ParquetRecordBatchReaderBuilder::try_new(file).unwrap();

// The builder has access to ParquetMetaData
assert_eq!(builder.metadata().num_row_groups(), 1);

// Call build to create the reader
let mut reader: ParquetRecordBatchReader = builder.build().unwrap();

// Read data
while let Some(batch) = reader.next().transpose()? {
    println!("Read {} rows", batch.num_rows());
}
```

## What to implement

Build `src/main.rs` to:

1. Open the file with `std::fs::File::open`
2. Create a `ParquetRecordBatchReaderBuilder` with `try_new`
3. Print `builder.metadata().num_row_groups()` and `builder.schema()`
4. Call `builder.build()` to get the reader
5. Loop with `while let Some(batch) = reader.next()` — handle the `Result` inside with `.expect` or `?`
6. Print row and column counts per batch
7. After the loop works, pick one numeric column by name, downcast it, and sum the values across all batches

**The column access pattern from the docs:**

```rust
// Getting a column by index
let column = batch.column(0);  // returns &ArrayRef

// Getting a column by name requires finding the index first
let schema = batch.schema();
let index = schema.index_of("fare_amount").unwrap();
let column = batch.column(index);
```

## Imports for Layer 1

```rust
use std::fs::File;
use parquet::arrow::arrow_reader::ParquetRecordBatchReaderBuilder;
use parquet::arrow::arrow_reader::ParquetRecordBatchReader;
```

## Downcasting Arrays

From the Arrow docs, how to downcast an `ArrayRef` to a concrete type:

```rust
use datafusion::arrow::array::{Array, Int64Array};
use datafusion::arrow::datatypes::DataType;

fn process_column(array: &dyn Array) {
    match array.data_type() {
        DataType::Int64 => {
            let arr = array.as_any().downcast_ref::<Int64Array>().unwrap();
            let sum: i64 = arr.iter()
                .filter_map(|v| v)  // filter out nulls
                .sum();
            println!("Sum: {}", sum);
        }
        _ => println!("Unhandled type: {:?}", array.data_type())
    }
}
```

## Generic Functions Over Numeric Types

```rust
use std::iter::Sum;
use datafusion::arrow::array::PrimitiveArray;
use datafusion::arrow::datatypes::ArrowPrimitiveType;

fn sum<T: ArrowPrimitiveType>(array: &PrimitiveArray<T>) -> T::Native
where
    T::Native: Sum
{
    array.iter().map(|v| v.unwrap_or_default()).sum()
}
```

# Phase 5 — Apache Arrow in Rust

Arrow is the columnar memory format that DataFusion uses to represent data during query execution. Before you can contribute to DataFusion, you need to understand what Arrow is and how it works in Rust. Think of Arrow as the data layer and DataFusion as the query engine built on top of it.

## What Arrow Is

Arrow defines a language-agnostic standard for storing tabular data in memory. The key idea: instead of storing data row by row, Arrow stores data column by column. A table with one million rows and ten columns is represented as ten arrays of one million values each.

Why does this matter for databases? Because analytical queries typically scan a few columns across many rows. If you want to sum a single column across a million rows, row-oriented storage forces you to skip over nine irrelevant columns for every row. Column-oriented storage lets you read just the one column you need, sequentially, which is both cache-friendly and I/O-efficient.

Arrow is also designed for zero-copy sharing between processes and languages — a Python process can share an Arrow buffer with a Rust process without copying the data.

## The Official Arrow Rust Docs

Start with the top-level crate documentation. This is where the overall structure is explained and where all sub-crates are re-exported.

- https://arrow.apache.org/rust/arrow/index.html

### Key Modules

**`arrow::datatypes`** — the type system.

- https://arrow.apache.org/rust/arrow/datatypes/index.html
- `DataType` is an enum of all possible column types: `Int32`, `Int64`, `Float64`, `Utf8` (string), `Boolean`, `List`, `Struct`, `Dictionary`, `Duration`, `Timestamp`, and many more.
- `Field` describes one column: its name, its `DataType`, and whether it can contain null values.
- `Schema` is a list of `Field`s describing all the columns in a `RecordBatch`.

**`arrow::array`** — the data structures.

- https://arrow.apache.org/rust/arrow/array/index.html
- `PrimitiveArray<T>` — a typed array of primitive values. `Int32Array`, `Float64Array`, `TimestampNanosecondArray` are all `PrimitiveArray<T>` for different values of `T`.
- `StringArray` — an array of UTF-8 strings.
- `ListArray` — an array where each element is itself a list.
- `NullArray` — an array where every element is null.
- `ArrayRef = Arc<dyn Array>` — the type you will see everywhere in DataFusion. Every column in a `RecordBatch` is an `ArrayRef`.

## RecordBatch — the unit of execution

```rust
use arrow::record_batch::RecordBatch;
use arrow::array::{Int32Array, StringArray};
use arrow::datatypes::{DataType, Field, Schema};
use std::sync::Arc;

// A RecordBatch is: a Schema describing columns, plus one Array per column
// All arrays in a RecordBatch have the same length
// This is the type that DataFusion's execution engine produces and consumes

let schema = Arc::new(Schema::new(vec![
    Field::new("id", DataType::Int32, false),    // "id" column, Int32, non-nullable
    Field::new("name", DataType::Utf8, true),    // "name" column, string, nullable
]));

let batch = RecordBatch::try_new(
    schema,
    vec![
        Arc::new(Int32Array::from(vec![1, 2, 3])),
        // None means null — the "name" column has a null in the second position
        Arc::new(StringArray::from(vec![Some("alice"), None, Some("charlie")])),
    ],
).unwrap();

// Access data
println!("{} rows, {} columns", batch.num_rows(), batch.num_columns());

// To use column data, downcast the Arc<dyn Array> to the concrete type
let id_column = batch.column(0)
    .as_any()
    .downcast_ref::<Int32Array>()
    .unwrap();
println!("First id: {}", id_column.value(0));
```

## Downcasting Pattern

From the top-level Arrow docs, how to downcast an `ArrayRef` to a concrete type:

```rust
fn impl_string(array: &StringArray) {}
fn impl_f32(array: &Float32Array) {}

fn impl_dyn(array: &dyn Array) {
    match array.data_type() {
        // downcast `dyn Array` to concrete `StringArray`
        DataType::Utf8 => impl_string(array.as_any().downcast_ref().unwrap()),
        // downcast `dyn Array` to concrete `Float32Array`
        DataType::Float32 => impl_f32(array.as_any().downcast_ref().unwrap()),
        _ => unimplemented!()
    }
}
```

The cleaner version using `AsArray`:

```rust
fn impl_dyn(array: &dyn Array) {
    match array.data_type() {
        DataType::Utf8 => impl_string(array.as_string()),
        DataType::Float32 => impl_f32(array.as_primitive()),
        _ => unimplemented!()
    }
}
```

## Generic Functions Over Numeric Types

```rust
fn sum<T: ArrowPrimitiveType>(array: &PrimitiveArray<T>) -> T::Native
where
    T: ArrowPrimitiveType,
    T::Native: Sum
{
    array.iter().map(|v| v.unwrap_or_default()).sum()
}

assert_eq!(sum(&Float32Array::from(vec![1.1, 2.9, 3.])), 7.);
assert_eq!(sum(&TimestampNanosecondArray::from(vec![1, 2, 3])), 6);
```

Note `v.unwrap_or_default()` — this is how you handle nulls. Arrow iterates `Option<T>`, where `None` means the value is null.

## Further Reading

**The Arrow Cookbook** — practical examples for common operations.
- https://arrow.apache.org/cookbook/

**Arrow columnar format specification** — the binary layout.
- https://arrow.apache.org/docs/format/Columnar.html

Understanding the physical memory layout — how null bitmasks work, how variable-length data is stored, what dictionary encoding is — is what separates someone who calls Arrow APIs from someone who can contribute to Arrow itself.

## Exercises

Build these in your `databases-scratch` repo.

**Exercise 1:** Without using DataFusion, read a CSV file, infer its schema, build `RecordBatch`es from the data, and write them to a Parquet file. Use only the `arrow` and `parquet` crates.

**Exercise 2:** Read that Parquet file back, iterate the `RecordBatch`es, find a numeric column, downcast it to `Int64Array`, and compute its sum manually.

**Exercise 3:** Find the PR where Joe fixed `array_slice` edge cases in DataFusion. Read the test cases he added. Write those same tests yourself against `arrow-rs` directly.

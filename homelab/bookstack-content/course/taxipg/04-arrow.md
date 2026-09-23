# Arrow: reading values out of a RecordBatch

## Docs to read first

- [RecordBatch](https://docs.rs/arrow/latest/arrow/array/struct.RecordBatch.html) — `num_rows`, `column`, `schema`
- [Int64Array](https://docs.rs/arrow/latest/arrow/array/struct.Int64Array.html), [Float64Array](https://docs.rs/arrow/latest/arrow/array/struct.Float64Array.html), [Date32Array](https://docs.rs/arrow/latest/arrow/array/struct.Date32Array.html)
- [DataType](https://docs.rs/arrow/latest/arrow/datatypes/enum.DataType.html)
- Homelab: [Apache Arrow](../rust/arrow.html)

**Import from `datafusion::arrow::...`**, not a separate `arrow` crate, so versions match DataFusion 54.

## Why downcast

`collect()` gives **typed columns as trait objects** (`&dyn Array`). Rust needs a concrete array type to call `.value(i)`. The schema you printed tells you which struct to use.

`count(*)` is often **`UInt64`**, not `Int64`. `payment_type` in TLC Parquet is often **`Int64`** or **`Int32`**. If downcast returns `None`, you used the wrong type — look at `col.data_type()`.

## Pattern

``` {.rust data-file="src/main.rs" data-do="add these helpers"}
use datafusion::arrow::array::{Array, Float64Array, Int32Array, Int64Array, UInt64Array};

/// Integer-like column → i64 for Postgres BIGINT / INT
fn as_i64(col: &dyn Array, row: usize) -> i64 {
    if let Some(a) = col.as_any().downcast_ref::<Int64Array>() {
        a.value(row)
    } else if let Some(a) = col.as_any().downcast_ref::<UInt64Array>() {
        a.value(row) as i64
    } else if let Some(a) = col.as_any().downcast_ref::<Int32Array>() {
        a.value(row) as i64
    } else {
        panic!("not an integer column: {:?}", col.data_type());
    }
}

fn as_f64(col: &dyn Array, row: usize) -> f64 {
    col.as_any()
        .downcast_ref::<Float64Array>()
        .unwrap_or_else(|| panic!("expected Float64, got {:?}", col.data_type()))
        .value(row)
}

// After collect():
for batch in &batches {
    for i in 0..batch.num_rows() {
        let payment_type = as_i64(batch.column(0), i) as i32; // Postgres INT
        let trips = as_i64(batch.column(1), i);
        let revenue = as_f64(batch.column(2), i);
        println!("{payment_type} {trips} {revenue}");
    }
}
```

## Dates

`CAST(... AS DATE)` often yields **Date32** (days since Unix epoch):

``` {.rust data-file="src/main.rs" data-do="add after the helpers"}
use chrono::NaiveDate;
use datafusion::arrow::array::Date32Array;

fn as_date(col: &dyn Array, row: usize) -> NaiveDate {
    let days = col
        .as_any()
        .downcast_ref::<Date32Array>()
        .expect("expected Date32")
        .value(row);
    NaiveDate::from_ymd_opt(1970, 1, 1).unwrap() + chrono::Duration::days(days as i64)
}
```

If the schema says `Timestamp(...)`, downcast `TimestampMicrosecondArray` / `TimestampNanosecondArray` instead (see Arrow timestamp docs). **Always print schema first.**

## Concept

Arrow is **in-memory columnar**. Postgres insert is **row at a time** (`$1,$2,$3`). This loop is the boundary between the two models.

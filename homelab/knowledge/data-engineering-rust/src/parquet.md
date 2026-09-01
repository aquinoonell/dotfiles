# Parquet in Rust

```toml
parquet = "54"
arrow = "54"
```

Read a file:

```rust
use parquet::arrow::arrow_reader::ParquetRecordBatchReaderBuilder;
use std::fs::File;

let file = File::open("data/sample.parquet")?;
let builder = ParquetRecordBatchReaderBuilder::try_new(file)?;
let schema = builder.schema().clone();
let reader = builder.build()?;
```

See Lab 01.

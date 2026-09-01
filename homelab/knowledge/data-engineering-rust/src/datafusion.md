# DataFusion

SQL and DataFrame API over Arrow.

```toml
datafusion = "43"
```

```rust
use datafusion::prelude::*;

let ctx = SessionContext::new();
ctx.register_parquet("t", "data/sample.parquet", ParquetReadOptions::default()).await?;
let df = ctx.sql("SELECT * FROM t WHERE id > 1").await?;
df.show().await?;
```

See Lab 03.

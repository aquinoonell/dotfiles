# Apache Arrow in Rust

```toml
arrow = "54"
```

Key types: `Schema`, `RecordBatch`, `ArrayRef`.

```rust
use arrow::array::{Int32Array, StringArray};
use arrow::record_batch::RecordBatch;
use std::sync::Arc;

let ids = Int32Array::from(vec![1, 2, 3]);
let names = StringArray::from(vec!["alice", "bob", "carol"]);
let batch = RecordBatch::try_from_iter(vec![
    ("id", Arc::new(ids) as ArrayRef),
    ("name", Arc::new(names) as ArrayRef),
])?;
```

See Lab 02 for a full exercise.

# Columnar Concepts

Row stores (Postgres, CSV) read entire rows. Columnar formats (Parquet, Arrow) store values column-by-column.

**Why it matters:** analytics queries often touch few columns — columnar layout reads less data from disk.

| Format | Use case |
|--------|----------|
| Arrow  | In-memory analytics, zero-copy between libraries |
| Parquet | On-disk storage, compression, schema evolution |
| DataFusion | SQL/DataFrame engine over Arrow |

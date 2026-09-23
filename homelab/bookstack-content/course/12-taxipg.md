# Lake → job → Postgres

Scan NYC taxi Parquet with DataFusion, write **small marts** to homelab Postgres (CT 110). You write the crate (`cargo new taxi-pg`); these pages are the textbook.

The lab is HTML on this same site (not a Kiwix ZIM):

**[Start the lab](../taxi/index.html)**

| Page | What it covers |
|------|----------------|
| [Overview](../taxi/index.html) | Lake vs job vs serving DB |
| [Connect](../taxi/connect.html) | `psql`, `postgres.lan`, Docker `172.18.0.2` |
| [Schema](../taxi/schema.html) | `payment_mix`, `trips_daily`, `etl_runs` |
| [DataFusion](../taxi/datafusion.html) | `register_parquet`, `sql`, `collect` |
| [Arrow](../taxi/arrow.html) | Downcast columns for INSERT |
| [tokio-postgres](../taxi/client.html) | `connect` + spawn `Connection` |
| [The job](../taxi/job.html) | `ON CONFLICT` upsert + run log |
| [Reading list](../taxi/reading.html) | Crate docs + [Kiwix](http://kiwix.lan) DevDocs |

Do **not** load the full Parquet file into Postgres. The job aggregates; the server stores the answer.

Related: [PostgreSQL](10-postgres.md) · [DataFusion](07-datafusion.md) · [parq-tool Layer 4](parqtool/04-layer4-postgres.md)

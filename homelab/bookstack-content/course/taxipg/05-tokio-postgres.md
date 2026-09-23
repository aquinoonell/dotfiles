# tokio-postgres: the same protocol as psql

## Docs to read first

- [`connect`](https://docs.rs/tokio-postgres/latest/tokio_postgres/fn.connect.html) — **read the `(Client, Connection)` paragraph**
- [`NoTls`](https://docs.rs/tokio-postgres/latest/tokio_postgres/struct.NoTls.html)
- [`Client::execute`](https://docs.rs/tokio-postgres/latest/tokio_postgres/struct.Client.html#method.execute)
- [`Client::query_one`](https://docs.rs/tokio-postgres/latest/tokio_postgres/struct.Client.html#method.query_one)
- [`Row::get`](https://docs.rs/tokio-postgres/latest/tokio_postgres/struct.Row.html#method.get)
- [`ToSql`](https://docs.rs/tokio-postgres/latest/tokio_postgres/types/trait.ToSql.html)
- Course copy: `~/dotfiles/homelab/bookstack-content/course/parqtool/04-layer4-postgres.md`

This homelab has **no TLS** on 5432. `NoTls` is correct. Production would use rustls/native-tls.

## Cargo

``` {.toml data-file="Cargo.toml" data-do="add these dependencies"}
tokio-postgres = { version = "0.7", features = ["with-chrono-0_4"] }
chrono = { version = "0.4", default-features = false, features = ["std", "clock"] }
```

`with-chrono-0_4` lets you pass `chrono::NaiveDate` as Postgres `DATE`.

## Connect (do this as its own tiny program first)

``` {.rust data-file="src/main.rs" data-do="tiny program — prove connect first"}
use tokio_postgres::NoTls;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let dsn = "host=postgres.lan user=postgres password=password dbname=parq";

    // Client = API you call (execute, query)
    // Connection = TCP/state machine — MUST be polled or everything hangs
    let (client, connection) = tokio_postgres::connect(dsn, NoTls).await?;

    tokio::spawn(async move {
        if let Err(e) = connection.await {
            eprintln!("connection error: {e}");
        }
    });

    let row = client.query_one("SELECT 1 AS n", &[]).await?;
    let n: i32 = row.get("n");
    println!("postgres said {n}");
    Ok(())
}
```

If this hangs: you did not spawn `connection`. That is the #1 bug.

## Parameters

``` {.rust data-file="src/main.rs" data-do="INSERT with $1…$4"}
// $1, $2 must implement ToSql — i32, i64, f64, NaiveDate with the chrono feature
client
    .execute(
        "INSERT INTO payment_mix (period, payment_type, trips, revenue) \
         VALUES ($1, $2, $3, $4)",
        &[&period, &payment_type, &trips, &revenue],
    )
    .await?;
```

`&[]` is “no parameters.” Slice of **references** to values.

## RETURNING (etl_runs)

``` {.rust data-file="src/main.rs" data-do="start the job log"}
let row = client
    .query_one(
        "INSERT INTO etl_runs (job, period, status) \
         VALUES ($1, $2, 'running') RETURNING id",
        &[&"taxi_january_marts", &period],
    )
    .await?;
let run_id: i32 = row.get(0); // column 0 of RETURNING
```

## Concept

`psql` and `tokio-postgres` are the **same protocol**. If `psql` works and Rust hangs, the bug is almost always the un-spawned `Connection`, not DNS.

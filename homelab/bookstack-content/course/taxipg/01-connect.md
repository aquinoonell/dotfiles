# Connect to homelab Postgres

## Docs to read first

- Homelab ops: `~/dotfiles/homelab/POSTGRES.md` on the Mac
- [How PostgreSQL works](../db/postgres.html)
- `psql` connection strings: [libpq](https://www.postgresql.org/docs/16/libpq-connect.html#LIBPQ-CONNSTRING)
- Offline SQL reference: [PostgreSQL DevDocs](http://kiwix.lan/content/devdocs_en_postgresql_2026-05)

## What “connection” means

Postgres is a **network service**. Your Mac is a **client**. The wire protocol is **not HTTP**, so it does **not** go through Nginx Proxy Manager the way `kiwix.lan` pages do.

``` {.text data-file="diagram" data-do="where the packets go"}
Mac psql / tokio-postgres
    → DNS postgres.lan
    → 192.168.1.179:5432   (CT 110)
    → Docker publishes 5432
    → container IP 172.18.0.2  (only visible *inside* Docker)
```

`SELECT inet_server_addr();` returning `172.18.0.2` is **normal**. You never type that IP on the Mac.

## Prove it with psql

``` {.bash data-file="terminal" data-do="open a session"}
# same string you will put in Rust
psql "host=postgres.lan user=postgres password=password dbname=parq"
```

At the `parq=#` prompt:

``` {.sql data-file="psql" data-do="type this at parq=#"}
-- which engine and version
SELECT version();

-- you are in the serving database, not "postgres" default db
SELECT current_database();

-- LAN vs Docker: this is the container address
SELECT inet_server_addr();
```

If `postgres.lan` does not resolve (DNS not Pi-hole / Tailscale):

``` {.bash data-file="terminal" data-do="if postgres.lan does not resolve"}
psql "host=192.168.1.179 user=postgres password=password dbname=parq"
```

Lab password matches Phase 0 notes. LAN/Tailscale only — do not publish 5432 to the internet.

## Concepts to understand

| Term | Meaning |
|------|--------|
| Host | Machine running `postmaster` (here: LXC + Docker) |
| Port 5432 | Postgres default; clients speak the **Postgres protocol** |
| Database `parq` | Catalog name; `\l` lists databases, `\c parq` switches |
| Role `postgres` | Superuser in this lab image |

Read: [psql](https://www.postgresql.org/docs/16/app-psql.html) (`\d`, `\dt`, `\q`).

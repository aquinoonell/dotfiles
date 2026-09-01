# How PostgreSQL Works

Postgres is a **client–server** relational database. A daemon owns a data directory on disk. Your Mac (or `parq-tool`) is a **client**: it opens a TCP connection to port 5432 and speaks the Postgres wire protocol. That is different from DuckDB and DataFusion, which run *inside* your process.

This homelab runs Postgres on **CT 110** at `postgres.lan`. Full usage (connect, dump, `parq-tool`) is in `~/dotfiles/homelab/POSTGRES.md`.

## Process model

One **postmaster** process starts at boot. Each client connection is a **backend** (a forked process). Shared state lives in shared memory: buffer pool (`shared_buffers`), locks, WAL buffers.

```
psql / tokio-postgres  --TCP 5432-->  postmaster
                              forks --> backend (your session)
                              all backends share: buffers + WAL
```

That is why “the database is down” means the postmaster died, and why one runaway query is usually one backend, not the whole server.

## How a write becomes durable (WAL)

MVCC and crash recovery are why Postgres is a *server* you operate, not a library you import.

1. You `INSERT` / `UPDATE` / `COMMIT`.
2. Postgres writes the change to the **write-ahead log** (WAL) **before** it is considered committed.
3. Dirty pages in the buffer pool are flushed later (checkpoints).
4. After a crash, Postgres **replays WAL** from the last checkpoint. Committed transactions come back; uncommitted ones do not.

This is the ARIES-style recovery you read about in internals. You do not implement it here — you *use* a system that already does.

## How reads do not block writes (MVCC)

Postgres keeps **multiple versions** of a row. A reader sees a snapshot; a writer creates a new version. Vacuum later reclaims dead versions.

Practical consequence: `SELECT` does not take a lock that blocks `UPDATE` the way a naive two-phase-lock textbook example might. Isolation levels (`READ COMMITTED`, `REPEATABLE READ`, `SERIALIZABLE`) change *which* snapshot you see.

Inspect a live instance:

```sql
SHOW shared_buffers;
SHOW wal_level;
SELECT pid, usename, state, query FROM pg_stat_activity;
```

## SQL you should actually run

```sql
CREATE TABLE t (id BIGINT PRIMARY KEY, name TEXT);
INSERT INTO t VALUES (1, 'hello');
BEGIN;
UPDATE t SET name = 'x' WHERE id = 1;
ROLLBACK;   -- name is still 'hello'
EXPLAIN ANALYZE SELECT * FROM t WHERE id = 1;  -- look for Index Scan
```

`EXPLAIN ANALYZE` is how you see seq scans vs index scans. That is operating a database, not only storing rows.

## From Rust (`tokio-postgres`)

Layer 4 of `parq-tool` maps Arrow types to Postgres types, `CREATE TABLE`, then inserts batches. The connection string is the only homelab-specific part:

```
host=postgres.lan user=postgres password=password dbname=parq
```

Pattern from the crate: `connect` returns `(Client, Connection)` — spawn the `Connection` future or I/O stalls.

## What this CT will not teach

Replication, failover, and tuning for hundreds of GB. It **will** teach connect, SQL, indexes, `EXPLAIN`, dump/restore, and “the server is a process with a data directory.” That is the operator loop application developers use.

## Reference

- [PostgreSQL docs](https://www.postgresql.org/docs/current/)
- [DevDocs](https://devdocs.io/postgresql/)
- Internals reading (WAN): https://www.interdb.jp/pg/ (Suzuki)
- [DBA Stack Exchange](https://dba.stackexchange.com/)

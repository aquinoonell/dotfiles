# PostgreSQL on the homelab

CT **110** · `postgres.lan` · `192.168.1.179:5432`  
Docker `postgres:16` · database `parq` · user `postgres`

This is a **LAN/Tailscale-only** lab server. Password is the course default (`password`) so Layer 4 of `parq-tool` matches Phase 0 notes. Do not expose 5432 to the internet.

Docs: [PostgreSQL](https://www.postgresql.org/docs/current/) · [DuckDB](https://duckdb.org/docs/) · course notes in `bookstack-content/course/10-postgres.md` and `11-duckdb.md`

## Connect from the Mac

```bash
brew install libpq
echo 'export PATH="$(brew --prefix libpq)/bin:$PATH"' >> ~/.zshrc
# new shell, then:
psql "host=postgres.lan user=postgres password=password dbname=parq"
```

Smoke test:

```sql
SELECT version();
CREATE TABLE IF NOT EXISTS smoke (id int);
INSERT INTO smoke VALUES (1);
SELECT * FROM smoke;
```

Over Tailscale, use CT 110’s `100.x` address if `postgres.lan` does not resolve (Pi-hole is LAN DNS).

## parq-tool (Layer 4–5)

```bash
parq-tool data.parquet -q "SELECT * FROM data" \
  --postgres "host=postgres.lan user=postgres password=password dbname=parq"
```

## Backup and restore

```bash
# dump
ssh root@proxmox 'pct exec 110 -- docker exec postgres pg_dump -U postgres parq' > parq-$(date +%F).sql

# restore
psql "host=postgres.lan user=postgres password=password dbname=parq" < parq-YYYY-MM-DD.sql
```

Proxmox snapshot of CT 110 is a second backup layer.

## Operate the CT

```bash
ssh root@proxmox
pct exec 110 -- docker ps
pct exec 110 -- docker logs postgres --tail 50
pct exec 110 -- docker restart postgres
```

Data directory: `/root/postgres/data` on CT 110 (bind-mounted). Destroying the CT without a dump **deletes** the database.

Compose file in git: [`postgres/docker-compose.yml`](postgres/docker-compose.yml)

## DuckDB on the same data

```bash
brew install duckdb
duckdb
```

```sql
SELECT count(*) FROM 'data.parquet';
INSTALL postgres;
LOAD postgres;
ATTACH 'host=postgres.lan user=postgres password=password dbname=parq' AS pg (TYPE postgres);
```

## DNS

`postgres.lan` is a Pi-hole host record to **192.168.1.179** (the CT). Other `*.lan` names still point at NPM (`192.168.1.175`). Postgres is not HTTP — do not put it behind NPM.

# Phase 3 — Database Internals

This is the core of the entire roadmap. Rust gives you the language. This phase gives you the domain knowledge. Everything after this is application.

## CMU 15-445/645: Database Systems

Joe TA'd this course. It is free, it uses real database code, and it covers every major topic in storage and query engine internals. This is the single most important course on this roadmap.

- YouTube playlist: https://www.youtube.com/playlist?list=PLSE8ODhjZXjbj8BMuIrRcacnQh20hmY9g
- Course website (slides, notes, all materials): https://15445.courses.cs.cmu.edu/
- BusTub (the teaching database, written in C++): https://github.com/cmu-db/bustub

The course has four programming projects. They are in C++. Do them. Then, after completing each one in C++, attempt to rewrite the core of it in Rust in your `databases-scratch` repo.

| Project | What It Teaches |
|---|---|
| 1: Buffer Pool Manager | How a database manages memory — keeping hot pages in RAM, evicting cold ones to disk. LRU replacement policy. This is the foundation of everything else. |
| 2: B+Tree Index | How databases index data for fast lookup and range scan. Node splitting and merging. Concurrent access to the tree. |
| 3: Query Execution | The Volcano iterator model — each operator produces rows one at a time. Implementing sequential scan, join, aggregation. |
| 4: Concurrency Control | Two-phase locking. Deadlock detection. Isolation levels — what it means for transactions to be serializable. |

## Topic → Where You See It Again

| Topic | What It Is | Where You See It |
|---|---|---|
| Storage models | Row-oriented (NSM) versus column-oriented (DSM) storage | Arrow is columnar (DSM) — every RecordBatch is DSM |
| Buffer pool | Database-managed page cache | Postgres `shared_buffers` setting; your Project 1 |
| B+Tree | Most common index structure | Postgres index files; your Project 2 |
| External sort | Sort algorithm for data larger than memory | DataFusion's `SortExec` spills to disk and merges |
| Hash aggregation | Build a hash table, then aggregate | DataFusion's `AggregateExec` |
| Volcano model | Each operator returns one row at a time via `next()` | Maps to Rust's `Iterator` trait; DataFusion uses the vectorized version |
| Vectorized execution | Each operator returns a batch of rows at a time | DataFusion uses this — each batch is an Arrow RecordBatch |
| Query optimization | Rewrite query plans to be faster without changing results | DataFusion's `LogicalOptimizer` applies rule-based rewrites |
| Two-phase locking | Acquire locks in growing phase, release in shrinking phase | Postgres uses 2PL for row-level locking |
| MVCC | Keep multiple versions of rows so readers never block writers | Postgres uses MVCC; Joe implemented isolation levels at Materialize |
| WAL | Write-ahead log — write changes to a log before applying them | Postgres WAL; Joe's commits touch the interval arithmetic in timestamp.c |

## CMU 15-721: Advanced Database Systems

Take this after 15-445. It covers the modern analytical and in-memory database landscape, which is directly what DataFusion and Arrow are part of.

- YouTube: https://www.youtube.com/playlist?list=PLSE8ODhjZXjb9WsGmFBnP3hJ4BArL-mwI
- Course site: https://15721.courses.cs.cmu.edu/

Key topics: vectorized execution and SIMD, column compression, query compilation, modern join algorithms, in-memory storage.

## PostgreSQL Internals

Joe has over fifteen commits to the Postgres core codebase. The path into Postgres starts with understanding how it's built internally.

**The Internals of PostgreSQL** by Hironobu Suzuki. Free online. Short and precise. Read every chapter. https://www.interdb.jp/pg/

**PostgreSQL 14 Internals** by Egor Rogov. Free PDF. More detailed than Suzuki. https://postgrespro.com/community/books/internals

After reading, explore the source code. Joe's contribution areas:

- `src/backend/utils/adt/timestamp.c` — interval arithmetic, where Joe fixed overflow handling and `date_trunc()` with infinite values.
- `src/backend/commands/variable.c` — session variables, where Joe fixed privilege checks for `SET SESSION AUTHORIZATION`.

Postgres source on GitHub: https://github.com/postgres/postgres

Developer documentation: https://wiki.postgresql.org/wiki/Developer_FAQ

How patch review works: https://wiki.postgresql.org/wiki/Reviewing_a_Patch

## Essential Papers

Read these alongside 15-445. Most are available free from CMU's database paper library at https://db.cs.cmu.edu/papers/.

| Paper | Why |
|---|---|
| A Relational Model of Data for Large Shared Data Banks — Codd (1970) | The origin of relational databases — where SQL comes from |
| ARIES: A Transaction Recovery Method — Mohan et al. (1992) | WAL-based crash recovery; the algorithm Postgres uses |
| Bigtable: A Distributed Storage System for Structured Data — Chang et al. (2006) | The model for Apache Accumulo, which Apache Fluo (Joe is PMC) is built on |
| Dynamo: Amazon's Highly Available Key-Value Store — DeCandia et al. (2007) | The model for Cassandra; how eventual consistency works in practice |
| Spanner: Google's Globally Distributed Database — Corbett et al. (2012) | Distributed transactions with external consistency |
| MonetDB/X100: Hyper-Pipelining Query Execution (2005) | The vectorized execution model DataFusion uses |
| The Design and Implementation of Modern Column-Oriented Database Systems (2012) | The theoretical foundation for Arrow's columnar format |
| An Empirical Evaluation of In-Memory Multi-Version Concurrency Control — Wu et al., CMU (2017) | MVCC — what Joe's isolation level work at Materialize is based on |
| In Search of an Understandable Consensus Algorithm (Raft) — Ongaro and Ousterhout (2014) | The consensus algorithm behind most modern distributed databases. PDF: https://raft.github.io/raft.pdf |
| Large-scale Incremental Processing Using Distributed Transactions and Notifications (Percolator) — Google (2010) | The model for Apache Fluo, where Joe is a PMC member |

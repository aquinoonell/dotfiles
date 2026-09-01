# Phase 0 — Environment and Orientation

Do all of this before anything else. It takes one afternoon.

## Tools to Install

```bash
# Rust toolchain — the language and its package manager
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
rustc --version   # should print rustc 1.x.x

# PostgreSQL — homelab (preferred) or Docker on the Mac

The homelab CT is always on: `postgres.lan` (see `~/dotfiles/homelab/POSTGRES.md`).

```bash
psql "host=postgres.lan user=postgres password=password dbname=parq"
```

If you are not on the LAN and have no Tailscale, a throwaway local copy:

```bash
# PostgreSQL via Docker — a local database to experiment with
docker run --name pg \
  -e POSTGRES_PASSWORD=password \
  -e POSTGRES_DB=parq \
  -p 5432:5432 \
  -d postgres

# Connect to it
psql -h localhost -U postgres -W
# password: password
```

# DataFusion CLI — run SQL queries against local files
cargo install datafusion-cli
# Test it: datafusion-cli
# Then at the prompt: SELECT 1 + 1;
```

## GitHub Profile Cleanup

Your current profile bio is a joke. That's fine in private, but it communicates nothing to anyone who might hire you or review your contributions. Do these:

- Update the bio to something like: "CS student at John Jay (CUNY). Interested in databases, distributed systems, and open source."
- Rename the `ratatui-` repo to `secure-chat`. Go to the repo → Settings → Repository name.
- Add a description to `secure-chat`: "Terminal-based end-to-end encrypted chat. Ed25519 + X25519 + ChaCha20-Poly1305 + forward secrecy ratchet."
- Add topics to `secure-chat`: `rust`, `tui`, `cryptography`, `end-to-end-encryption`.

## Repos to Create Now

Create two repositories on GitHub:

`aquinoonell.github.io` — your personal site. Leave it empty for now. Phase 10 covers the full setup.

`databases-scratch` — a scratchpad for every experiment in this roadmap. Every B+Tree attempt, every file I/O benchmark, every half-finished buffer pool. Commit everything, even experiments that don't work. This repo is for learning, not for showing off.

---

# Phase 1 — CS Foundations

Run this in parallel with Phase 2. You don't need to finish it before moving forward.

## Data Structures You Need for Databases

These are not general data structure topics. These are the specific structures that appear inside the systems you will eventually contribute to.

**B+Tree** — the index structure used by Postgres, RocksDB, most storage engines. Every `CREATE INDEX` in Postgres creates a B+Tree. Understanding how it works — insert, delete, split, merge, range scan — is a prerequisite for reading Postgres source code.

**Hash table** — used in hash joins and hash aggregation in query engines like DataFusion. The `HashJoinExec` and `AggregateExec` operators build hash tables internally.

**Bloom filter** — used in LSM-tree storage engines (RocksDB, LevelDB, Cassandra) to avoid reading disk for keys that don't exist. You'll encounter these in distributed systems work.

**Skip list** — the memtable structure in LevelDB and RocksDB. An alternative to balanced trees with simpler concurrent access.

**Min-heap** — used in the merge phase of external sort algorithms. DataFusion's `SortExec` spills to disk and then merges runs using a heap.

## Resources

- Introduction to Algorithms (CLRS), 4th edition. Do not read cover to cover. Key chapters: 6 (heaps), 10 through 14 (data structures), 22 through 25 (graphs, for understanding query plan DAGs). https://mitpress.mit.edu/9780262046305/introduction-to-algorithms/
- MIT 6.006 Introduction to Algorithms, free on OCW: https://ocw.mit.edu/courses/6-006-introduction-to-algorithms-fall-2011/

## Project

Once you have enough Rust (around Phase 2, month three), implement a B+Tree from scratch. Insert, delete, range scan, node splitting and merging. This is the hardest beginner project in this roadmap and also the most useful — it teaches you more about databases than most introductory courses.

## Obsidian Notes to Write

- `[[B+Tree]]` — how insert triggers a split, how delete triggers a merge, what the difference between B-Tree and B+Tree is and why databases use B+Tree
- `[[Bloom Filter]]` — the false positive rate formula, why false negatives are impossible, where it appears in LSM trees
- `[[External Sort]]` — what happens when data doesn't fit in memory, how merge sort maps to this problem

## Operating Systems

Databases are I/O machines. Reading Postgres source code requires knowing what `fsync()`, `mmap()`, `O_DIRECT`, and page cache mean. You don't need deep OS expertise — you need the vocabulary and the mental model.

Focus on:

- Virtual memory and paging — how the OS decides what stays in RAM and what goes to disk. Relevant to buffer pool managers, which are databases doing the same thing themselves.
- File I/O system calls — `read()`, `write()`, `fsync()`, `mmap()`. Postgres uses all four in different contexts.
- The difference between buffered I/O (OS caches writes) and direct I/O (`O_DIRECT`, bypasses the OS cache). Some databases bypass the OS cache entirely and manage their own.
- Threads, mutexes, and condition variables — the foundation for understanding how databases handle concurrent access.

Resources:

- Operating Systems: Three Easy Pieces (OSTEP), free online. https://pages.cs.wisc.edu/~remzi/OSTEP/
- CMU 15-213 (free on YouTube): https://www.cs.cmu.edu/~213/

## Networking Basics

You do not need deep networking knowledge at this stage. What you do need:

- How TCP works at the connection level — the three-way handshake, what a socket is.
- The PostgreSQL wire protocol — how `psql` actually communicates with a running Postgres server. DataFusion has a Postgres-compatible frontend that speaks this protocol.
- What Substrait is — a cross-language query plan serialization format. Joe contributed Arrow Duration, Time, and Dictionary type support to DataFusion's Substrait plans. https://substrait.io/

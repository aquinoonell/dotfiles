# Phases 7-8 — Distributed Systems & Open Source

## Phase 7 — Distributed Systems

### MIT 6.824: Distributed Systems

The definitive course. Free online.

- YouTube: https://www.youtube.com/playlist?list=PLrw6a1wE39_tb2fErI4-WkMbsvGQk9_UB
- Course site (labs in Go): https://pdos.csail.mit.edu/6.824/

The labs are: MapReduce, Raft consensus, key/value service on Raft, sharded key/value service. Do the labs in Go (the course language), then translate the Raft implementation to Rust as a separate project.

### Core Papers

| Concept | Paper |
|---|---|
| Raft consensus | In Search of an Understandable Consensus Algorithm — https://raft.github.io/raft.pdf |
| Paxos | Paxos Made Simple — Lamport (2001) — https://lamport.azurewebsites.net/pubs/paxos-simple.pdf |
| Lamport clocks | Time, Clocks, and the Ordering of Events in a Distributed System — Lamport (1978) |
| Percolator | Large-scale Incremental Processing Using Distributed Transactions and Notifications — Google (2010) |

### Designing Data-Intensive Applications

_Designing Data-Intensive Applications_ by Martin Kleppmann. https://dataintensive.net/

This is the best single book on how modern data systems are designed and why they make the tradeoffs they do. Read it alongside the papers — every chapter connects to a system you have studied or will contribute to.

### Apache Fluo (Joe Is a Committer)

Fluo is a distributed processing system for incremental updates to large data sets, built on Apache Accumulo and modeled after Google Percolator. Joe is a PMC member.

- https://fluo.apache.org/
- Source: https://github.com/apache/fluo

### Materialize (Joe's Former Employer)

Materialize is a streaming SQL database that maintains query results incrementally. It is written entirely in Rust and is open source. Joe spent four years there building the SQL layer, RBAC, and isolation level implementations.

- Source: https://github.com/MaterializeInc/materialize
- Joe's RBAC post: https://materialize.com/blog/rbac/
- Joe's ACID post: https://materialize.com/blog/the-four-acid-questions/

---

## Phase 8 — Open Source Contributions

### The Contribution Ladder

```
Level 1 — Documentation fixes, test additions, typo corrections
    Gets you familiar with the review process, the repo structure,
    and the community norms before you touch any code

Level 2 — Good first issues, small bug fixes
    Your first real code merged into a production codebase

Level 3 — Edge case and correctness fixes
    Joe's pattern: NULL handling in array functions, interval overflow,
    array_slice edge cases

Level 4 — Type system and protocol additions
    Joe's pattern: adding Duration, Time, Dictionary type support
    to DataFusion's Substrait serialization

Level 5 — New features in your area of depth
    Joe's pg_duration extension, RBAC at Materialize

Level 6 — Committer / PMC member
    Joe's Apache Fluo membership
```

### Where to Start

**Apache DataFusion** is the right first target.

- Good first issues: https://github.com/apache/datafusion/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22
- Contribution guide: https://datafusion.apache.org/contributor-guide/
- Joe's merged PRs: https://github.com/apache/datafusion/pulls?q=is%3Apr+is%3Amerged+author%3Ajkosh44

**Apache Arrow** is the next natural step:
- Good first issues: https://github.com/apache/arrow-rs/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22

**rust-postgres** — Joe added Multirange type support:
https://github.com/sfackler/rust-postgres

**PostgreSQL core** (C, Year 2+):
- Commitfest: https://commitfest.postgresql.org/
- Hackers mailing list: https://www.postgresql.org/list/pgsql-hackers/

### Building Your Own Project: A Postgres Extension in Rust

Joe built `pg_duration` — a PostgreSQL extension that adds a duration data type.
Source: https://github.com/jkosh44/pg_duration

The `pgrx` crate lets you write Postgres extensions in Rust instead of C:
https://github.com/pgcentralfoundation/pgrx

---

## Phase 9 — Writing and Public Presence

Joe's blog posts demonstrate that he understands these systems at teaching depth, not just using depth. Each post is narrow, specific, and mechanistic.

### What to Write and When

| Post Idea | When to Write It |
|---|---|
| What I learned implementing a B+Tree in Rust | After Phase 3, when you finish the project |
| How DataFusion's query execution pipeline works | After Phase 6, when the architecture is clear |
| Arrow RecordBatches explained from the binary layout up | After Phase 5 exercises |
| My first DataFusion contribution: the bug, the fix, what I learned | After your first merged PR |
| Raft consensus implemented in Rust | After Phase 7 lab translation |
| Building a Postgres extension in Rust with pgrx | After your extension is published |

### Joe's Writing Pattern

1. _Generics and Dynamic Dispatch in Rust_ — https://joekoshakow.com/blogs/2025-04-06-rust-generics-vs-dynamic-dispatch.html
2. _Rust Async Runtimes Explained_ — https://joekoshakow.com/blogs/2025-04-06-rust-async-runctimes.html
3. _PostgreSQL Intervals are Confusing_ — https://joekoshakow.com/blogs/2025-03-03-postgresql-intervals-are-confusing.html
4. _Role Based Access Control_ — https://materialize.com/blog/rbac/
5. _The Four ACID Questions_ — https://materialize.com/blog/the-four-acid-questions/

The pattern: pick one specific narrow thing, lead with the surprising or confusing aspect, walk through the mechanism with code or concrete examples, link to the actual source or spec, conclude with what this implies.

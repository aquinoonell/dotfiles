# Roadmap: Databases, Distributed Systems & Open Source

> Goal: Become a software developer specializing in databases, distributed systems, and open source — with everything expressed in Rust.
> Model: Joe Koshakow — https://joekoshakow.com
> Your GitHub: https://github.com/aquinoonell

---

## Where You Actually Are

This is the honest picture before the roadmap starts. Being clear about this matters because the plan changes depending on where you're starting from.

**What you have:**

You're a CS student at John Jay College (CUNY) working as a Graduate Intern at NYCT MTA. Your GitHub shows two real projects in Rust.

The first, `ratatui-` (rename this to `secure-chat` — it has no description and no topics, so it's invisible to anyone who lands on your profile), is a terminal-based end-to-end encrypted chat application. The crypto stack — Ed25519 identity keys, X25519 ephemeral key exchange, HKDF-SHA256 key derivation, ChaCha20-Poly1305 encryption, and a one-way symmetric ratchet for per-message forward secrecy — is not a beginner project. You can read a spec and implement it correctly. That matters.

The second is a contribution to `tuxedo`, a published Rust TUI tool with 106 stars and a Homebrew tap. That gives you a real merged contribution you can point to.

At work, you use Hexagon EAM, SQL, and Jira. You do not use DataFusion or Arrow at work.

**What's actually missing:**

The gap between where you are and where Joe is comes down to three things. First, Rust: you have projects in Rust but you say you're starting from zero on the language, which means the `ratatui-` project was built while learning, and there are gaps in your understanding of how Rust actually works. Second, database internals: you have no background yet in how databases are built — storage engines, indexes, query execution, transactions. Third, the open source infrastructure ecosystem: DataFusion, Arrow, and Postgres core are entirely new territory.

**The gap, mapped concretely:**

| You Now | Joe |
|---|---|
| Some Rust from projects, gaps in fundamentals | Deep Rust — production database systems |
| No database internals | Postgres committer, written isolation levels at Materialize |
| No distributed systems background | PMC member on Apache Fluo (distributed transactions) |
| No DataFusion or Arrow experience | DataFusion and Arrow contributor |
| Two real projects (tuxedo contribution, secure-chat) | Years of OSS contributions + original projects |

**What this means for the roadmap:**

Rust comes first, as a proper foundation, not as something to pick up while building. Database internals come second. DataFusion and Arrow come after you have enough Rust and database vocabulary to read their source code and understand what you're looking at. The website and writing are built up continuously from Phase 3 onward.

---

## How This Roadmap Works

The phases are roughly sequential but several run in parallel. The timeline assumes consistent part-time effort alongside school and work. A realistic pace:

- Phase 0 and Phase 1 run at the same time.
- Phase 2 (Rust) starts immediately and runs for about six months, overlapping with everything else.
- Phase 3 (database internals) starts around month two and runs for most of the first year.
- Phase 4 (Rust for databases) overlaps with Phase 3 — you apply what you're learning in Rust to the database concepts you're studying at the same time.
- Phases 5 and 6 (Arrow and DataFusion) start once you have enough Rust and database foundation to read the source code.
- Phase 7 (distributed systems) starts in the second half of the first year.
- Phase 8 (OSS contributions) begins around month six — you don't need to be an expert to contribute, just informed enough to find and fix something small.
- Writing and the website are ongoing from month three onward.

The total arc from now to a profile like Joe's is four to six years of consistent, deliberate work. The first year builds the foundation. The second year produces real contributions. The third year and beyond are where the depth compounds.

---

## Course Structure

| Book | Focus |
|------|-------|
| **Start Here** | This page — overview and context |
| **Phase 0-1: Setup & CS Foundations** | Environment, data structures for databases |
| **Rust Foundation** | Full Phase 2 — the language from zero |
| **Database Internals** | CMU 15-445, B+Tree, WAL, MVCC, papers |
| **Rust for Databases** | Volcano model, Arc/RwLock, ExecutionPlan |
| **Apache Arrow** | Columnar format, RecordBatch, downcasting |
| **Parquet** | File format, read/write, parq-tool Layer 1 |
| **DataFusion** | Query engine architecture, UDFs, contributing |
| **parq-tool Project** | Complete build guide — 5 layers |
| **Distributed Systems & OSS** | Raft, 6.824, contribution ladder |
| **Reference** | Resource index, Rust translation guide |

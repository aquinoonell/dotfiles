#!/usr/bin/env bash
# Convert course markdown to HTML pages for kiwix-guide
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
COURSE="$DIR/../bookstack-content/course"
OUT="$DIR/rust"
DBOUT="$DIR/db"

mkdir -p "$OUT" "$DBOUT"

wrap_page() {
  local title="$1"
  local body_file="$2"
  local outfile="$3"
  local nav="$4"
  cat > "$outfile" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${title} — Kiwix Guide</title>
  <link rel="stylesheet" href="../style.css">
</head>
<body>
  <nav class="nav">${nav}</nav>
  <article class="content">
$(pandoc "$body_file" -f markdown -t html)
  </article>
</body>
</html>
EOF
}

RUST_NAV='<a href="../index.html">← Library</a> · <a href="index.html">Rust Data Stack</a> · <a href="../db/index.html">Postgres &amp; DuckDB</a>'
DB_NAV='<a href="../index.html">← Library</a> · <a href="index.html">Postgres &amp; DuckDB</a> · <a href="../rust/index.html">Rust Data Stack</a>'

wrap_page "Rust Data Stack Overview" "$DIR/rust-overview.md" "$OUT/index.html" "$RUST_NAV"
wrap_page "Apache Arrow in Rust" "$COURSE/05-apache-arrow.md" "$OUT/arrow.html" "$RUST_NAV"
wrap_page "Parquet in Rust" "$COURSE/06-parquet.md" "$OUT/parquet.html" "$RUST_NAV"
wrap_page "DataFusion in Rust" "$COURSE/07-datafusion.md" "$OUT/datafusion.html" "$RUST_NAV"
wrap_page "Rust for Databases" "$COURSE/04-rust-for-databases.md" "$OUT/patterns.html" "$RUST_NAV"
wrap_page "Database Internals" "$COURSE/03-database-internals.md" "$OUT/database-internals.html" "$RUST_NAV"

wrap_page "Postgres, DuckDB, and DataFusion" "$DIR/db-overview.md" "$DBOUT/index.html" "$DB_NAV"
wrap_page "How PostgreSQL Works" "$COURSE/10-postgres.md" "$DBOUT/postgres.html" "$DB_NAV"
wrap_page "How DuckDB Works" "$COURSE/11-duckdb.md" "$DBOUT/duckdb.html" "$DB_NAV"

echo "Built rust guide pages in $OUT"
echo "Built db guide pages in $DBOUT"

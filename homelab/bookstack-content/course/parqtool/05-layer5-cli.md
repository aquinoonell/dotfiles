# Layer 5 — CLI Flags and Polish

## What you are building

Merge all layers into `src/main.rs` with command line flags:

- positional argument: path to input Parquet file
- `--query` or `-q`: SQL query string
- `--output`: path to write output Parquet file
- `--postgres`: Postgres connection string
- `--explain`: print the DataFusion execution plan before running
- `--limit`: limit on rows to print

## Documentation to read first

**The clap crate — use the derive API:**
https://docs.rs/clap/latest/clap/

The derive API lets you annotate a Rust struct and clap generates all the argument parsing:

```rust
use clap::Parser;

/// Simple program to greet a person
#[derive(Parser, Debug)]
#[command(version, about, long_about = None)]
struct Args {
    /// Name of the person to greet
    #[arg(short, long)]
    name: String,

    /// Number of times to greet
    #[arg(short, long, default_value_t = 1)]
    count: u8,
}

fn main() {
    let args = Args::parse();

    for _ in 0..args.count {
        println!("Hello {}!", args.name)
    }
}
```

## Args Struct for parq-tool

```rust
use clap::Parser;

#[derive(Parser)]
#[command(name = "parq-tool")]
#[command(about = "Query Parquet files with SQL, write to Parquet or Postgres")]
struct Args {
    /// Path to the input Parquet file
    input: String,

    /// SQL query to run (table name is "data")
    #[arg(short, long)]
    query: Option<String>,

    /// Write output to this Parquet file
    #[arg(long)]
    output: Option<String>,

    /// Write output to this Postgres database (connection string)
    #[arg(long)]
    postgres: Option<String>,

    /// Print the DataFusion execution plan
    #[arg(long)]
    explain: bool,

    /// Limit rows printed to stdout
    #[arg(long, default_value_t = 10)]
    limit: usize,
}
```

## Complete main.rs

```rust
use clap::Parser;
use datafusion::prelude::*;
use datafusion::error::Result;
use parquet::arrow::ArrowWriter;
use parquet::file::properties::WriterProperties;
use parquet::basic::Compression;
use std::fs::File;

#[derive(Parser)]
#[command(name = "parq-tool")]
#[command(about = "Query Parquet files with SQL, write to Parquet or Postgres")]
struct Args {
    /// Path to the input Parquet file
    input: String,

    /// SQL query to run (table name is "data")
    #[arg(short, long)]
    query: Option<String>,

    /// Write output to this Parquet file
    #[arg(long)]
    output: Option<String>,

    /// Write output to this Postgres database
    #[arg(long)]
    postgres: Option<String>,

    /// Print the DataFusion execution plan
    #[arg(long)]
    explain: bool,

    /// Limit rows printed to stdout
    #[arg(long, default_value_t = 10)]
    limit: usize,
}

#[tokio::main]
async fn main() -> Result<()> {
    let args = Args::parse();
    
    // Create DataFusion context
    let ctx = SessionContext::new();
    
    // Register input file as "data" table
    ctx.register_parquet("data", &args.input, ParquetReadOptions::default()).await?;
    
    // Default query if none provided
    let query = args.query.unwrap_or_else(|| {
        format!("SELECT * FROM data LIMIT {}", args.limit)
    });
    
    // Execute query
    let df = ctx.sql(&query).await?;
    
    // Show explain if requested
    if args.explain {
        println!("=== Execution Plan ===");
        df.clone().explain(false, false)?.show().await?;
        println!();
    }
    
    // Handle output destinations
    match (&args.output, &args.postgres) {
        (Some(output_path), _) => {
            // Write to Parquet
            let batches = df.collect().await?;
            if !batches.is_empty() {
                let schema = batches[0].schema();
                let file = File::create(output_path)?;
                let props = WriterProperties::builder()
                    .set_compression(Compression::SNAPPY)
                    .build();
                let mut writer = ArrowWriter::try_new(file, schema, Some(props))?;
                for batch in &batches {
                    writer.write(batch)?;
                }
                writer.close()?;
                println!("Wrote {} batches to {}", batches.len(), output_path);
            }
        }
        (_, Some(_pg_conn)) => {
            // Write to Postgres (see Layer 4 for full implementation)
            println!("Postgres output not implemented in this example");
        }
        _ => {
            // Print to stdout
            df.show_limit(args.limit).await?;
        }
    }
    
    Ok(())
}
```

## Usage Examples

```bash
# Just show schema and first 10 rows
parq-tool data.parquet

# Run a custom query
parq-tool data.parquet -q "SELECT COUNT(*) FROM data"

# Write query results to new Parquet file
parq-tool data.parquet -q "SELECT * FROM data WHERE amount > 100" --output filtered.parquet

# Show execution plan
parq-tool data.parquet -q "SELECT a, SUM(b) FROM data GROUP BY a" --explain
```

## How Types Connect Across Layers

```
std::fs::File
    |
    | ParquetRecordBatchReaderBuilder::try_new(file)
    v
ParquetRecordBatchReaderBuilder
    |
    | .build()
    v
ParquetRecordBatchReader  (implements Iterator<Item = Result<RecordBatch>>)
    |
    v
RecordBatch
    |
    | .column(i) -> &ArrayRef
    v
ArrayRef  (= Arc<dyn Array>)
    |
    | .as_any().downcast_ref::<Int64Array>()
    v
Concrete array type

--- DataFusion path ---

SessionContext::new()
    |
    | .register_parquet("name", "path", opts).await?
    v
SessionContext
    |
    | .sql("SELECT ...").await?
    v
DataFrame
    |
    | .collect().await? -> Vec<RecordBatch>
    | .show().await?    -> prints to stdout
    v
Vec<RecordBatch>
    |
    v
ArrowWriter::try_new(file, schema, None)?
    |
    | .write(&batch)?
    | .close()?
    v
Parquet file on disk
```

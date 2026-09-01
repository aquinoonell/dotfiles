use anyhow::Result;
use parquet::arrow::arrow_reader::ParquetRecordBatchReaderBuilder;
use std::fs::File;
use std::path::PathBuf;

fn main() -> Result<()> {
    let path = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("../data/sample.parquet");
    let file = File::open(&path)?;
    let builder = ParquetRecordBatchReaderBuilder::try_new(file)?;
    println!("Schema:\n{}", builder.schema());
    let mut rows = 0usize;
    for batch in builder.build()? {
        rows += batch?.num_rows();
    }
    println!("Total rows: {rows}");
    Ok(())
}

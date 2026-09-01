# Phase 6 — Apache DataFusion in Rust

DataFusion is a query engine written in Rust that uses Arrow as its data format. It is your primary contribution target. The goal of this phase is to go from someone who has never used DataFusion to someone who can read its source code, understand its architecture, and make a meaningful contribution.

## Official Documentation — Read in This Order

### User Guide

- Introduction: https://datafusion.apache.org/user-guide/introduction.html
- Example usage: https://datafusion.apache.org/user-guide/example-usage.html
- Gentle Arrow Introduction: https://datafusion.apache.org/user-guide/arrow-introduction.html
- DataFrame API: https://datafusion.apache.org/user-guide/dataframe.html
- SQL Reference: https://datafusion.apache.org/user-guide/sql/index.html
- Configuration: https://datafusion.apache.org/user-guide/configs.html

### Library User Guide (how to extend DataFusion)

- Introduction: https://datafusion.apache.org/library-user-guide/index.html
- Using the SQL API: https://datafusion.apache.org/library-user-guide/using-the-sql-api.html
- Using the DataFrame API: https://datafusion.apache.org/library-user-guide/using-the-dataframe-api.html
- Working with Expressions: https://datafusion.apache.org/library-user-guide/working-with-exprs.html
- Adding User Defined Functions: https://datafusion.apache.org/library-user-guide/functions/adding-udfs.html
- Custom Table Provider: https://datafusion.apache.org/library-user-guide/custom-table-providers.html
- Query Optimizer: https://datafusion.apache.org/library-user-guide/query-optimizer.html

### Contributor Guide

- Architecture: https://datafusion.apache.org/contributor-guide/architecture.html
- Development environment: https://datafusion.apache.org/contributor-guide/development_environment.html
- Testing: https://datafusion.apache.org/contributor-guide/testing.html
- How to submit a PR: https://datafusion.apache.org/contributor-guide/howtos.html

API Reference: https://docs.rs/datafusion/latest/datafusion/

## DataFusion's Architecture

Understanding this pipeline is the most important thing to internalize before looking at the source code.

```
SQL string you write (e.g. "SELECT name FROM users WHERE age > 25")
    |
    | sqlparser-rs: parses text into a structured AST
    v
Abstract Syntax Tree
    |
    | datafusion-sql: converts AST to a logical plan
    v
LogicalPlan (describes WHAT to compute, not HOW)
    |
    | LogicalOptimizer: applies rule-based rewrites
    |   - PredicatePushdown: move WHERE filters as close to data as possible
    |   - ProjectionPushdown: only read the columns you actually need
    |   - CommonSubexprEliminate: compute duplicate expressions only once
    |   - SimplifyExpressions: fold constants, simplify trivial comparisons
    v
Optimized LogicalPlan
    |
    | PhysicalPlanner: converts logical plan to physical execution plan
    v
ExecutionPlan tree (a tree of operators, each implementing the ExecutionPlan trait)
    |
    | ExecutionPlan::execute() is called for each partition
    v
SendableRecordBatchStream per partition (runs in parallel on tokio thread pool)
    |
    | df.collect().await or df.execute_stream().await
    v
Vec<RecordBatch> or an async stream you consume row by row
```

## Key Source Directories

```
datafusion/
    core/src/
        execution/         SessionContext, TaskContext, the execution entry point
        physical_planner/  converts LogicalPlan to ExecutionPlan
    expr/src/
        logical_plan/      the LogicalPlan type and its variants
        expr.rs            the Expr enum (logical expressions like col("x") + lit(1))
    optimizer/src/         the LogicalOptimizer rules — Joe's NULL fixes live here
    physical-expr/src/     physical expressions — how expressions are evaluated at runtime
    physical-plan/src/
        filter.rs          FilterExec — applies a WHERE predicate to a stream
        sort.rs            SortExec — sorts a stream, spilling to disk if necessary
        joins/             HashJoinExec, SortMergeJoinExec
        aggregates/        AggregateExec, accumulator implementations
    functions/src/
        string/            built-in string functions — upper(), lower(), trim(), etc.
        math/              built-in math functions
        array/             built-in array functions — array_slice is here
    sql/src/               SQL → LogicalPlan conversion
```

## Running DataFusion

```bash
cargo install datafusion-cli
datafusion-cli
```

At the prompt:

```sql
-- create an in-memory table
CREATE TABLE employees AS VALUES
    ('alice', 95000),
    ('bob', 87000),
    ('charlie', 102000);

-- query it
SELECT * FROM employees WHERE column2 > 90000;

-- see the execution plan
EXPLAIN SELECT * FROM employees WHERE column2 > 90000;
```

## Your First DataFusion Program

```rust
use datafusion::prelude::*;
use datafusion::error::Result;

#[tokio::main]
async fn main() -> Result<()> {
    // SessionContext is the entry point — it holds configuration, catalogs, functions
    let ctx = SessionContext::new();

    // Register a CSV file as a queryable table
    ctx.register_csv(
        "employees",           // the table name to use in SQL
        "employees.csv",       // the file to read
        CsvReadOptions::new(),
    ).await?;

    // Run a SQL query — returns a DataFrame (a lazy logical plan)
    let df = ctx.sql("
        SELECT name, salary
        FROM employees
        WHERE salary > 90000
        ORDER BY salary DESC
    ").await?;

    // Show the execution plan the optimizer produced
    df.clone().explain(false, false)?.show().await?;

    // Execute and print results
    df.show().await?;

    Ok(())
}
```

## Writing a User Defined Function

User defined functions (UDFs) are the most direct path from DataFusion user to DataFusion contributor.

```rust
use datafusion::prelude::*;
use datafusion::arrow::array::{ArrayRef, StringArray};
use datafusion::arrow::datatypes::DataType;
use datafusion::error::Result;
use datafusion::logical_expr::{create_udf, Volatility};
use std::sync::Arc;

// A scalar UDF that takes a string column and returns it in uppercase
fn make_shout_udf() -> datafusion::logical_expr::ScalarUDF {
    create_udf(
        "shout",
        vec![DataType::Utf8],   // input types
        DataType::Utf8,         // output type
        Volatility::Immutable,  // same input always produces same output
        Arc::new(|args: &[ArrayRef]| {
            let input = args[0]
                .as_any()
                .downcast_ref::<StringArray>()
                .unwrap();

            let output: StringArray = input.iter()
                .map(|s| s.map(|v| v.to_uppercase()))
                .collect();

            Ok(Arc::new(output) as ArrayRef)
        }),
    )
}
```

Compare your UDF to the built-in `upper()` function in `datafusion/functions/src/string/upper.rs`.

## Finding Your First Contribution

1. Clone the repo and make sure all tests pass: `cargo test`
2. Read Joe's merged PRs for code style and scope: https://github.com/apache/datafusion/pulls?q=is%3Apr+is%3Amerged+author%3Ajkosh44
3. Browse good first issues: https://github.com/apache/datafusion/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22
4. Look specifically for: NULL handling edge cases, missing type support (search the source for `not yet implemented` or `todo!()`), edge cases in array functions.
5. Fix it. Add a test that would have caught the bug. Submit a PR.

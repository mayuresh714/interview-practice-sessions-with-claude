# Data Engineering Interviews — applying CLEAR

Covers pipeline design, SQL/ETL rounds, and data-modeling rounds common at
data engineering-heavy companies.

## Clarify
- Batch or streaming? What's the actual freshness requirement (is 24-hour
  latency fine, or does this need to be near-real-time)?
- Data volume and growth rate — today and in 2 years.
- Who consumes this data and how (dashboards, ML features, another
  pipeline)? Different consumers imply different schema/latency trade-offs.
- Source system characteristics: append-only, mutable, CDC available?

## Lay out
- Propose the simplest pipeline shape first (e.g., batch ELT into a
  warehouse) before a more complex one (streaming + CDC), and justify
  moving to the complex version only if freshness/scale demands it.
- Name the trade-off between schema-on-write vs. schema-on-read for this
  specific use case.
- If modeling: sketch the grain of the fact table and the key dimensions
  before writing any DDL, and get buy-in on the grain — getting grain wrong
  early invalidates everything downstream.

## Execute
- Narrate each transformation step and why it's there (dedup logic,
  late-arriving data handling, partitioning key choice).
- For SQL-heavy rounds: state the query plan in words before writing SQL
  ("I'll aggregate first to shrink the join size, then join").
- Call out idempotency and replay-ability explicitly — a pipeline that
  can't be safely rerun is a red flag interviewers listen for.

## Assess
- Walk through a late-arriving or out-of-order data scenario and how the
  pipeline handles it.
- Check for data quality: what happens with nulls, duplicate keys, schema
  drift from the source.
- State how you'd monitor this in production (row count anomalies, freshness
  SLAs, schema change alerts).

## Refine
- State the cost trade-off (compute/storage) of the chosen design vs. the
  simpler alternative.
- Name one scaling bottleneck and how you'd address it if volume grew 10x.
- One-sentence summary aimed at a downstream consumer, not another engineer.

## Flags specific to data engineering rounds
- Designing for the happy path only — no mention of late data, duplicates,
  or schema drift until prompted.
- Treating "add more compute" as the answer to every scaling question
  instead of addressing the actual bottleneck (skew, shuffle, small files).
- No mention of how correctness would be tested/monitored after ship.

# System Design — applying CLEAR

For Google/Meta-style "design X" rounds (design a URL shortener, design
Twitter's feed, design a rate limiter, etc.).

## Clarify — the questions that must not be skipped
- Who are the users, roughly how many, read-heavy or write-heavy?
- What's the latency budget (p50/p99 if they'll give it)?
- Consistency requirement: is stale-by-a-few-seconds acceptable, or does
  this need strong consistency (e.g., payments, inventory)?
- What's explicitly out of scope? (Ask this directly — it prevents scope
  creep eating your 45 minutes.)

## Lay out
- Draw (describe) the high-level components first: client, API layer,
  service(s), datastore(s), cache, queue — before picking specific tech.
- Name 2 storage options and the trade-off (e.g., SQL for relational
  integrity vs. wide-column for write throughput at scale) rather than
  asserting one.
- Get buy-in on the component diagram before going deep on any one box.

## Execute
- Go one component deep at a time; narrate why you're going there next
  ("let's zoom into the write path since that's the bottleneck we flagged").
- State back-of-envelope numbers out loud (storage estimate, QPS, cache
  size) even if rough — the estimation process is being scored, not the
  precision.
- Introduce a bottleneck yourself before being asked ("this single DB will
  cap out around X QPS, so here's how I'd shard/cache/queue around it").

## Assess
- Pick one failure mode (node dies, hot partition, cache stampede, network
  partition) and walk through what happens end to end.
- State the actual trade-off of your mitigation (e.g., "adding a cache
  fixes read latency but introduces staleness — acceptable per our
  consistency answer from Clarify").

## Refine
- Name what you'd change with 2x more time (usually: better observability,
  a specific scaling bottleneck, or a consistency edge case).
- One-sentence summary of the whole design as if to a PM who just walked in.

## Common failure modes to self-check for
- Naming technologies without justifying them ("I'll use Kafka" — why?).
- Going deep on one component (usually the DB schema) and running out of
  time before reaching the rest of the system.
- Never returning to the numbers from Clarify to check the design actually
  meets them.

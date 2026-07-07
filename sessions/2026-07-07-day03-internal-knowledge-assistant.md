---
date: 2026-07-07
day: 03
type: ml-genai
company_archetype: general
difficulty: hard
---

# Day 03 — ml-genai — internal-knowledge-assistant

## Problem / Prompt
Design a system where a user can ask natural-language questions over their
company's internal data — spanning a Postgres database, internal Confluence
docs, and a Slack export — and get back accurate answers. Framed as an
Applied AI / Agentic Engineer round; deliberately broad and close to my own
production experience (text-to-SQL + RAG + agent orchestration from Opus
Brain), to see how I run the room, not just what I know.

## Transcript

**Interviewer:** Here's the prompt. Start with your clarifying questions.

**Me:** First thing — is this a chatbot that just answers questions, or an
agent that can take actions? Second, for the Postgres piece, what kind of
querying do we need — any arbitrary question, which means text-to-SQL
generation plus tooling to execute it, or something narrower? And what's
the actual purpose here — plain answers to user doubts, or something more?
Also, for Confluence and Slack — is that data available to us live, say via
MCP, or is it something like a batch export sitting in S3?

**Interviewer:** Good instincts on all three, but three questions in one
run-on paragraph reads as unstructured — ask one, get the answer, then ask
the next. Answers: (1) read-only Q&A for v1, no writes or external side
effects, though it can still reason in multiple internal steps. (2) Assume
arbitrary natural-language questions — text-to-SQL with execution tooling
is intentional, it's your strength, I want to see it. (3) Assume nightly
batch export to S3 for Confluence/Slack; Postgres is live and directly
queryable. But you're missing a bigger one: nothing about who's allowed to
see what. Confluence and Slack are exactly the kind of internal sources
with per-user access boundaries — flatten that into one index and you've
built a data leak, not a chatbot.

**Me:** Right — so does everyone have the same access, or is it role- or
doc-based? Do we want any personalization, like employees keeping private
docs? What's the acceptable latency for an internal use case, and roughly
how many concurrent requests are we expecting — and does this need its own
sign-in, like an internal ChatGPT-style app?

**Interviewer:** Better — you went straight at the permissions gap and took
it a level deeper. Still bundled five questions into one breath though;
that's the same habit from a minute ago, now a recurring one — pick the
most important unresolved question, ask it, then decide if you need the
next. Answers: access is real and source-enforced already (Confluence
space/page permissions, Slack channel membership) — my system needs to
respect it, not re-decide it. No personalization/private docs for v1.
Latency: a few seconds end-to-end is fine, not sub-second, not 30 seconds.
Concurrency: a few hundred employees, tens of concurrent at peak — not
internet scale. Auth: sits behind existing company SSO, and the
authenticated identity needs to flow through to what restricts retrieval.
Move to Lay Out: baseline architecture, end to end, trade-offs named as you
go — especially how permissions flow into retrieval.

**Me:** I'm actually still unclear on the search mechanism itself — do we
use keyword-based APIs that retrieve docs and hand them all to the LLM, or
do we vectorize everything and use RAG to pass additional context before
generating the final response? What should I assume there?

**Interviewer:** That one's different from your earlier clarifying
questions — access, latency, scale were things only the business side
could answer. Keyword vs. RAG is a technical design decision, and deciding
and defending it *is* the interview — I can't answer it for you. [Taught
the trade-off: keyword/full-text search is fast and cheap but only matches
literal/stemmed terms, so it misses paraphrased questions; vectorize+RAG
catches semantic paraphrase but costs an ingestion pipeline and can
confidently mis-retrieve on bad chunking; "send everything to the LLM"
isn't viable past a handful of docs — context limits, cost, latency, and
needle-in-haystack degradation, name why and move on; strong candidates
land on hybrid retrieval — keyword/BM25 alongside vector search or a
reranker, since internal docs are full of exact-match terms like product
names and ticket IDs that pure embeddings handle surprisingly badly.] Also
flagged: whatever gets indexed needs the source doc's ACL stored as
metadata on the chunk itself, or you've rebuilt the same permissions leak
inside the vector store instead of the API layer. Told to commit to an
answer and give the full Lay Out: ingestion, retrieval strategy, how
Postgres/text-to-SQL fits alongside it, and how identity/permissions get
enforced at query time.

**Me:** For ingestion — vectorize all the docs but keep metadata like
source and access level in the database. Use a batch processing service
rather than per-doc-update vectorization, refreshing roughly every 24
hours (whatever was updated, created, or deleted), separately for
Confluence and Slack, with source-specific refresh cadences since active
docs get a lot of back-and-forth during live collaboration and
vectorizing on every edit isn't worth it. Ingestion should be pluggable —
Jira, Confluence, Slack, Google Chat as separate source connectors, all
landing in a single raw table, then per-source jobs clean and vectorize
into the store with metadata. For Postgres, I'm assuming that's covered
by the tech docs already ingested.

For querying: request hits a load balancer, into an app/microservice.
File upload is out of scope for now — text only. The app is a multi-agent
system: a router agent first decides whether the query needs the
database, tech docs, or user history. Then a retrieval step does semantic
similarity search and pulls the top-k docs. Those go to an "answer
refinement" agent — since maybe 5 of the 20 retrieved are actually
relevant and the rest are just noise from the k value, that agent's job
is to filter and produce the final response. Then a validation agent,
which I think should also be an LLM call, checks ethical concerns, checks
citations used as evidence against hallucination, and — for the
text-to-SQL path — checks whether the answer surfaced data the user
wasn't supposed to access.

## Claude's Feedback

*(In progress — Postgres/text-to-SQL layout, deterministic permissions
enforcement, hybrid-retrieval confirmation, and an evals sentence were
requested and not yet given. Feedback below covers Clarify and the first
Lay Out pass only; scores may move once those are answered.)*

### Rubric (1-5 each)
- **Clarify:** 4 — didn't restate the problem verbally up front, but the
  first question ("just answers, or can it act?") effectively did that
  work. Round 1 missed permissions/access-control entirely — the single
  biggest miss of the two rounds. Round 2 self-corrected well once
  prompted and went a level deeper (role-based vs. uniform access) without
  being told to. Docked one point for two separate misses, not one.
- **Lay out:** 3 — ingestion pipeline (raw landing table → per-source jobs
  → vectorize+metadata, batch over per-doc-update, source-specific
  cadence) is solid and correctly reasoned, clearly pattern-matched from
  real ETL experience. Router → retrieve → filter-for-relevance →
  validate is a reasonable multi-agent shape (the filter step is
  essentially corrective RAG, applied correctly). But: (1) Postgres/
  text-to-SQL — the actual differentiator and the interviewer's explicit
  point of interest — got one dismissive line while the comfortable,
  familiar ingestion pipeline got five sentences; (2) permissions
  enforcement was handed entirely to an LLM validation agent, which
  can't be the *only* layer for a security guarantee; (3) hybrid
  retrieval, agreed on one exchange earlier, silently dropped back to
  vector-only in the actual layout; (4) evals — item #1 on your own
  stated gap list — wasn't mentioned until directly prompted for it.
  Not yet resolved as of this log.
- **Execute:** not reached.
- **Assess:** not reached.
- **Refine:** not reached.

### Flags
- **Hedge-stacking:** absent. Occasional single hedges ("I think," "I'm
  assuming") but never stacked three-deep.
- **Signposting:** absent. No self-initiated phase language ("moving to
  Lay Out now") anywhere in the session — every phase transition was
  named by the interviewer, not by the candidate. Same gap noted in Day
  02's coding session — this is now a **recurring cross-session pattern**,
  not a one-off.
- **Silent debugging:** not applicable — no code-execution phase reached
  this session.

### Specific notes
1. When the interviewer explicitly signaled interest in the text-to-SQL
   branch ("I want to see it") and it still got skipped in favor of the
   more comfortable ingestion-pipeline discussion, that's avoidance of the
   harder, more specific ask — not an oversight. Worth naming to self in
   the moment: "I'm about to skip the part I'm least sure how to
   structure out loud" is exactly the moment to slow down, not speed
   past.
2. Security/permissions enforcement was described as an LLM validation
   check rather than a deterministic filter at retrieval time. An LLM
   judgment call cannot be the mechanism behind an access-control
   guarantee — it can be a second-layer backstop, never the only layer.
3. Clarifying questions were delivered as one run-on paragraph in both
   Clarify rounds, despite being flagged after round 1. Ask one at a
   time — it's a communication habit, not a knowledge gap, and it's the
   cheapest fix in this whole session.

### Model verbal answer
"For access control, I wouldn't rely on the LLM to catch permission
violations after the fact — models can be wrong or manipulated, so I can't
make a security guarantee depend on one. Instead I'd enforce it
structurally: when I ingest a Confluence page or Slack message, I store
the source's ACL as metadata on every chunk. At query time, before I even
run the vector search, I resolve the requesting user's accessible
space/channel IDs and pass that in as a hard filter on the k-NN query
itself, so unauthorized content is never retrieved in the first place. Same
idea on the Postgres side — text-to-SQL runs against a row-level-security-
scoped connection or a pre-scoped view for that user, never the raw
tables. I'd still keep an LLM validation pass as a second layer, but it's
a backstop, not the mechanism."

## Voice Self-Review
- Pace:
- Filler words noticed:
- Where I'd have gone quiet if actually speaking:
- One thing to fix tomorrow:

---
date: 2026-07-08
day: 04
type: system-design
company_archetype: general
difficulty: medium
---

# Day 04 — system-design — profile-url-vanity-slug

## Problem / Prompt
Self-directed research question, not a live timed mock: how do platforms
like LinkedIn generate profile URLs, and what happens when multiple people
share the same name? Worked through as Q&A notes rather than an
interviewer-run session — logged here as prep material for the "design a
username system / URL shortener / profile URL system" family of system
design questions.

## Transcript

**Q: What's the core pattern behind human-readable profile URLs?**
A: Decouple identity from label — every profile has two separate fields,
not one. An **internal ID** (immutable UUID or integer, the real primary
key, never shown, never reused, never changes) and a **slug** (the
human-readable part of the URL, e.g. `linkedin.com/in/john-smith`) as a
separate, mutable field with a unique constraint on it. The URL is never
the identity — it's a mutable, collision-resolved label pointing at a
stable internal key. Same pattern as usernames, short URLs, and SEO slugs
generally.

**Q: How are collisions handled when multiple people share a name?**
A:
```
slugify("John Smith") -> "john-smith"
check unique index -> if taken, append suffix -> "john-smith-2", "john-smith-8f21"
```
First person to claim the exact slug gets the clean version. Others get a
suffixed version, or can pick a custom one later — first-come-first-served.
Some platforms (Twitter/X, GitHub) sidestep this entirely by using a
chosen unique handle instead of deriving one from the real name.

**Q: Why doesn't a name-search results page ever produce a broken link,
even with ten "John Smith" rows?**
A: Because the rows share display **text** but never share `href` — each
slug was assigned independently at account-creation time, not generated
at list-render time:
```html
<a href="/in/john-smith">John Smith</a>
<a href="/in/john-smith-2">John Smith</a>
<a href="/in/jsmith-nyc">John Smith</a>
```
The real UX problem isn't broken links — clicking is always
deterministic — it's *human* disambiguation before the click, solved with
metadata (photo, title, location) rendered next to the name, not with the
URL itself.

**Q: Does search hit the primary profiles database directly?**
A: No — search queries a denormalized search index (Elasticsearch-style):
```json
{ "id": "...", "slug": "john-smith-2", "name": "John Smith",
  "headline": "...", "photo_url": "...", "location": "..." }
```
Profile writes trigger a change-data-capture event (commonly via Kafka)
that pushes the updated document into the index. This avoids resolving
`slug` via a live per-result join at search time — a would-be N+1 problem
across millions of searches/day.

**Q: What has LinkedIn's own engineering team actually published on this,
versus what's inferred?**
A: Sourced from LinkedIn's Engineering blog, *"New Public Profile URL
System at LinkedIn"* (linkedin.com/pulse, Shun Wang):
- **Two tables, keyed differently on purpose**: a `Profile` table keyed by
  `profile_id` holds the `vanity_name` field plus a history of previously
  claimed names; a separate `VanityName` table keyed by `vanity_name`
  points back to `profile_id` with an `is_active` flag.
- **Storage**: both live in **Espresso**, LinkedIn's own distributed
  NoSQL document store — the same one behind member profiles and InMail.
- **Bulk/reverse lookups** (e.g. "all vanity names for this profile") go
  through an **Espresso Global Secondary Index**, not a scan of the
  primary table.
- **Sync mechanism**: an *Identity Databus Consumer* listens for change
  events on the `VanityName` table via the **Brooklin** stream and
  propagates updates to `Profile.vanity_name`; a separate *GSI Builder
  Consumer* keeps the secondary index current.
- **Write-time eligibility**: the Identity Mid-Tier checks eligibility
  rules before firing synchronous parallel writes across the tables.

**Caveat**: the specific default-collision scheme (name + hex-hash suffix
when no custom URL is set, e.g. `john-smith-12a3b4c5`) is observed
behavior from third-party sources, not stated in LinkedIn's own blog
post — flagged as inferred, not confirmed.

### Sources
- https://www.linkedin.com/pulse/new-public-profile-url-system-linkedin-shun-wang
- https://engineering.linkedin.com/espresso/introducing-espresso-linkedins-hot-new-distributed-document-store
- https://engineering.linkedin.com/blog/2020/reducing-latency-and-cost-for-identity-services

**Q: What's the reusable takeaway pattern for other system design
questions?**
A: Immutable internal ID + mutable unique human label + CDC to keep
read-optimized copies (search index, secondary index) in sync + a
redirect/history table for renamed labels. This same shape answers
"design a URL shortener," "design a username system," and "design a
profile URL system."

## Claude's Feedback

This wasn't a live, timed mock — no interviewer pushback, no clarifying
questions asked under pressure, no forced trade-off comparison in the
moment — so the usual Clarify/Lay out/Execute/Assess/Refine rubric doesn't
map cleanly onto it, and forcing 1-5 scores on it would be manufactured
signal, not real. Logging it as interview-readiness notes instead:

- **Strong as reference material**: the ID/slug split, the CDC-to-search-
  index pattern, and the reusable takeaway line at the end are exactly the
  shape a strong candidate would produce live in Lay Out for "design a
  URL shortener" or "design a username system." Good source discipline
  too — the LinkedIn-specific internals (Espresso, Brooklin, GSI) are
  correctly separated from the generic pattern, and the one inferred
  detail is explicitly flagged as unconfirmed rather than stated as fact.
- **Gap to close before this is interview-ready**: everything above reads
  as "the answer," not as something built up live in front of an
  interviewer. The actual skill being tested in Lay Out isn't reciting
  the ID/slug split — it's *deriving* it out loud from the collision
  problem ("if I used the name as the primary key, what breaks when two
  people share a name? ... okay, so I need a separate immutable key").
  Next time this topic comes up live, don't lead with the answer — narrate
  the naive approach first (name as primary key), state why it breaks,
  then arrive at the two-field design as the fix. That's the version an
  interviewer is actually scoring.
- **One real risk if this is used verbatim in an interview**: citing
  LinkedIn's specific internal component names (Espresso, Brooklin, GSI
  Builder Consumer) unprompted can read as reciting a blog post rather
  than reasoning live. Fine to have as background knowledge and fine to
  mention "I recall LinkedIn uses a two-table approach for this" if
  asked about real-world precedent — but the generic pattern (immutable
  ID, mutable unique slug, CDC to search index) should carry the actual
  design, not the proper nouns.

## Voice Self-Review
- Pace:
- Filler words noticed:
- Where I'd have gone quiet if actually speaking:
- One thing to fix tomorrow:

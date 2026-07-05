# interview-practice-sessions-with-claude

A daily practice log for tech interview **communication** — not just
correctness. Each session is a timed, transcribed mock interview run with
Claude Code, scored against a fixed rubric, and committed so progress over
time is visible and provable.

Built for coding, system design, ML/GenAI, behavioral, and data engineering
loops — the kind of interviews you'd see at Google, Meta, Anthropic, GenAI
startups, and data engineering-focused companies generally.

## Why this exists

In most interviews, the bottleneck isn't knowing the algorithm or the
design pattern — it's narrating your reasoning clearly under pressure:
clarifying before solving, comparing approaches out loud, staying vocal
while stuck, catching your own bugs, and closing with a clean summary. That
is a trainable skill, and this repo is the training log.

## The framework: CLEAR

Every session runs through five phases, regardless of interview type:

1. **Clarify** — restate the problem, ask the questions that matter, confirm
   I/O before solving anything.
2. **Lay out** — state a baseline approach, compare alternatives with named
   trade-offs, get explicit buy-in before building.
3. **Execute** — build while narrating continuously, including when stuck.
4. **Assess** — dry-run against edge cases, catch your own bugs before being
   told about them.
5. **Refine** — state final complexity/cost, name an alternative not taken,
   close with a one-sentence summary.

Full detail, time budgets, and the scoring rubric: `framework/01-core-framework.md`.
Domain-specific application:
- `framework/02-system-design.md`
- `framework/03-behavioral.md`
- `framework/04-ml-genai-interview.md`
- `framework/05-data-engineering.md`

## The text-only constraint, and how it's handled

Voice, pace, and facial expression matter in real interviews, and this
setup is text-only. Rather than pretend that gap doesn't exist:

- Sessions are written as if spoken — first person, no code blocks unless
  explicitly "writing this on the whiteboard" — so the *structure* and
  *hedging language* of responses is realistic and scorable in text.
- Claude's feedback is scoped to what text can actually reveal: structure,
  signposting, hedge-stacking, whether reasoning went silent while stuck.
  It does not fabricate feedback about tone or pace it can't hear.
- A short **voice self-review** step closes the rest of the gap: after each
  session, read your written responses aloud, record yourself, and fill in
  the `## Voice Self-Review` section. See
  `prompts/voice-self-review-checklist.md`.

## Running a session

```bash
# 1. Create today's session file
./scripts/new-session.sh <type> [company_archetype] [difficulty]
# type: coding | system-design | ml-genai | behavioral | data-eng
# e.g.:
./scripts/new-session.sh coding google medium
./scripts/new-session.sh ml-genai anthropic hard
./scripts/new-session.sh behavioral meta

# 2. Open Claude Code in this repo (it reads CLAUDE.md automatically)
claude
# then say: "run today's session"

# 3. After the session (and after your 60-second voice self-review):
./scripts/commit-session.sh
```

`CLAUDE.md` is the instruction set Claude Code reads automatically — it
defines exactly how a session is run, scored, and written up. Read it once;
it's the file doing the real work.

## Repo layout

```
CLAUDE.md                   instructions Claude Code follows to run a session
framework/                   the CLEAR framework + per-domain application notes
prompts/
  session-template.md        template used by new-session.sh
  voice-self-review-checklist.md
sessions/                    one dated file per practice session
scripts/
  new-session.sh              scaffolds today's session file
  commit-session.sh           commits + pushes today's session
```

## What this is not

Not a leetcode-answers repo and not a transcript of real interviews. It's a
practice log of a communication framework being rehearsed and critiqued
session by session — the commit history is the evidence of the practice,
not a claim of interview performance.

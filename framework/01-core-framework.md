# The CLEAR Framework

A five-phase structure for talking through *any* technical interview problem
out loud: coding, system design, ML/GenAI, data engineering. The phases are
the same regardless of domain — only what fills them changes. Say the phase
names to yourself as you transition; signposting out loud ("okay, let me lay
out a couple of approaches before I start coding") is part of the score, not
just internal bookkeeping.

## The five phases

### 1. Clarify — 2 to 4 minutes
Goal: prove you don't solve problems from assumptions.
- Restate the problem in your own words.
- Ask about input size/scale, edge cases, and what "correct" means here
  (exact match? approximate? which failure mode is worse?).
- For system design / ML design: ask about scale, latency budget, consistency
  needs, who the users are, read/write ratio, existing infra.
- Confirm I/O shape explicitly: "so I'm given X, and I should return Y — is
  that right?"
- Do not start solving here. If you catch yourself proposing an algorithm,
  stop and say "let me park that thought and finish clarifying first."

### 2. Lay out — 3 to 5 minutes
Goal: show you can compare approaches before committing to one.
- State a brute-force / naive approach first, even if obviously suboptimal —
  it establishes a correctness baseline and shows range.
- State the complexity of the naive approach out loud.
- Propose 1-2 better approaches, naming the trade-off each time (time vs.
  space, latency vs. consistency, simplicity vs. scalability).
- Get explicit buy-in: "I'd like to go with approach B because of X — does
  that sound reasonable, or would you like me to explore something else?"
- This is the phase most candidates skip by jumping straight to coding.
  Skipping it reads as "can code" but not "can design," which is the actual
  signal senior interviews are testing for.

### 3. Execute — 15 to 25 minutes
Goal: narrate while you build, don't go silent.
- Say what you're about to write before you write it ("I'll set up a hash
  map keyed by remainder here").
- When you hit a decision point (naming, data structure choice, helper
  function boundary), say the decision and the one-line reason.
- If you get stuck: narrate the stuckness. "I expected this to work but the
  index is off by one — let me trace through a small example." Going quiet
  while stuck is the single worst signal in this phase; interviewers can't
  distinguish silent-but-thinking from silent-but-stuck.
- If the interviewer interrupts or redirects, acknowledge it explicitly
  before continuing ("got it, switching to handle duplicates first") rather
  than silently changing course.

### 4. Assess — 3 to 5 minutes
Goal: catch your own bugs before being told about them.
- Dry-run on a concrete small example, out loud, line by line.
- Check edge cases explicitly: empty input, single element, all-same,
  max scale, adversarial input.
- If you find a bug: name it plainly ("that's wrong, line 12 should be
  `<=` not `<`") — don't hedge or apologize excessively. One acknowledgment,
  then fix it.
- For system design: this is where you walk through a failure mode (node
  dies, network partition, hot key) and how the design degrades.

### 5. Refine — 2 to 5 minutes
Goal: show you know what you'd do with more time, and can zoom out.
- State current complexity/cost and whether it's acceptable given the
  constraints from Clarify.
- Name one alternative you didn't take and why (shows breadth without
  re-litigating the whole thing).
- Give a one-sentence summary of the solution as if reporting it to someone
  who wasn't watching. This is the "elevator recap" — practice compressing.

## Time budgets by interview type

| Type | Clarify | Lay out | Execute | Assess | Refine |
|---|---|---|---|---|---|
| Coding (45 min) | 3 min | 4 min | 25 min | 5 min | 3 min |
| System design (45-60 min) | 5 min | 8 min | 25 min | 8 min | 5 min |
| ML/GenAI design | 5 min | 8 min | 20 min | 10 min | 5 min |
| Data engineering | 5 min | 6 min | 25 min | 8 min | 5 min |
| Behavioral (per story) | 1 min (clarify the question) | — | 4 min (STAR body) | 1 min (result) | 1 min (reflection) |

Behavioral uses CLEAR loosely — Clarify the actual question being asked,
Execute *is* the STAR body, Assess/Refine collapse into result + reflection.
See `framework/03-behavioral.md`.

## Communication rubric (scored 1-5 each session)

1. **Clarify** — did you restate + ask before solving, or dive in?
2. **Lay out** — did you compare approaches with named trade-offs, or jump
   to one?
3. **Execute** — did you narrate continuously, including while stuck?
4. **Assess** — did you find your own bugs via dry-run, or need prompting?
5. **Refine** — did you close with complexity + alternative + summary?

Plus three cross-cutting flags, marked present/absent each session:

- **Hedge-stacking** — chains like "I think maybe this could possibly work"
  that compound uncertainty language. One hedge is honest; three in a row
  reads as no confidence in your own reasoning.
- **Signposting** — did you name the phase transitions out loud ("let me
  lay out a couple approaches", "now let me test this")? Interviewers use
  these verbal markers to follow your process without interrupting.
- **Silent debugging** — any stretch where you stopped narrating while
  something was clearly wrong (test failing, design gap found) and the
  interviewer would have had no idea what you were thinking.

## Why phases, not scripts

Memorizing lines sounds robotic. The phases are a checklist for *what kind of
thing to say*, not the words themselves — "ask about scale" not "say
'what's the expected QPS.'" Fill each phase with your own voice. The goal is
that under pressure you reach for a phase, not for silence.

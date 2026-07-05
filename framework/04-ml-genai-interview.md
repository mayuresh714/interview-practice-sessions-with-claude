# ML / GenAI Interviews — applying CLEAR

Covers applied-ML design rounds and GenAI-specific rounds (RAG systems, agent
design, prompt/eval work, LLM-judge design) — the kind you'd see at
Anthropic-style companies or GenAI startups, distinct from classic ML-infra
system design.

## Clarify
- What's the actual product/business goal, not just the model metric?
  ("optimize for accuracy" is rarely the real answer — ask what a false
  positive/negative costs.)
- Data: what exists already, labeled or not, how much, how stale?
- Latency/cost constraints — real-time inference vs. batch, and what
  compute budget is implied.
- For GenAI-specific: is this generation, retrieval, classification, or
  agentic/tool-use? Ask explicitly — the architecture differs a lot.

## Lay out
- Propose a simple baseline first (heuristic, small model, or off-the-shelf
  API call) before a custom/fine-tuned solution — shows judgment about when
  complexity is warranted.
- For RAG: name the trade-off between retrieval strategies (dense vs.
  sparse vs. hybrid) and chunking choices before committing.
- For agents: name the trade-off between a single large-context call vs.
  a multi-step tool-use loop, and why.
- State how you'd evaluate before you state how you'd build — eval strategy
  is frequently the actual signal being tested in GenAI rounds.

## Execute
- Narrate the pipeline stage by stage: data → features/prompts → model/call
  → post-processing → serving.
- For prompting/agent design: say the actual prompt structure or tool
  schema out loud at a high level, and why each part is there.
- Call out failure modes proactively as you build: hallucination risk,
  distribution shift, prompt injection (if tool-use/agentic), cost blowup
  from retries.

## Assess
- State how you'd know the system is working: offline eval set, online
  A/B, human eval rubric — pick one and justify it over the others.
- Walk through one concrete failure case (bad retrieval, model
  hallucinates, agent loops) and what signal would catch it in production.
- If asked about bias/safety, answer directly rather than deflecting — this
  is a real evaluation axis at these companies, not a box-check.

## Refine
- State cost and latency trade-offs of the final design explicitly.
- Name what you'd do with more data / more compute / more time, in that
  order of likely impact.
- One-sentence summary in product terms, not model terms ("this gets users
  an answer in under 2 seconds with human-reviewed spot checks on the 5%
  lowest-confidence cases").

## Flags specific to ML/GenAI rounds
- Jumping straight to "fine-tune a model" without justifying why a
  simpler approach (prompting, retrieval, off-the-shelf classifier) is
  insufficient.
- Talking only about model architecture and never about eval — eval-first
  thinking is the single biggest differentiator interviewers look for here.
- No mention of cost/latency until asked — these are first-class constraints
  in GenAI systems, not afterthoughts.

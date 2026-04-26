# Exercise 06 — Evaluator / Optimiser (Reference, annotated)

*For instructor debrief. Not to be released until all pairs have completed.*

## The graph

```
Manual Trigger
  └─ Set Input (task)
       └─ Generate Draft           (Basic LLM Chain — open prose)
            └─ Score Draft         (Basic LLM Chain — ONE number 1-10)
                 └─ Score >= 8? (IF on Number($json.text.trim()))
                      ├─ true ─→ Final (Approved)             (Set: outcome="approved-on-first-try")
                      └─ false ─→ Critique → Revise → Final (Revised)
                                  (Critique: 1 sentence)        (Set: outcome="revised-after-critique")
                                  (Revise: original + feedback)

Ollama Chat Model
  └── ai_languageModel ── (fans out to all four Chains)
```

## Why this shape

- **Generate-Score-Gate is the spine.** Generate produces. Score evaluates. The IF gate routes. Three separate concerns, three separate nodes. Students who try to do "generate and self-evaluate in one prompt" get muddy results — separating the two is the whole point.
- **Score is a number, not prose.** The narrow output prompt (slide 2846) makes the IF gate possible. The expression `Number($json.text.trim())` converts the text "8" to the integer 8 for comparison.
- **Critique is separate from Revise.** A real production version might fold them together, but separating them teaches that *feedback is its own artefact*. The Critique's output is also stored in Final (Revised) under `feedback`, so a downstream consumer can audit *why* the revision happened.
- **Two terminal nodes with the same schema.** Different paths produce different content but identical fields (`score`, `outcome`, `final_draft`). Downstream code reads either uniformly. The `outcome` field is the discriminator.
- **One retry only.** Real loops require counters, max-attempts, and graceful giveup. This exercise demonstrates the pattern *shape*; the loop is implicit (one pass through the failure path = one revision attempt).

## Points to surface at debrief

1. **Same model, four roles.** The Ollama Chat Model is loaded once. It serves as Generator, Scorer, Critic, and Reviser — each role determined entirely by its prompt. *That's what "agent" means in this slide unit.*

2. **Why the score is a number.** A score of "I'd give this maybe a 7 or 8" is unparseable. A score of "8" is comparable. Tight output discipline is what makes downstream automation possible.

3. **Non-determinism.** Run the same input five times. Watch the score vary. This is why real systems use *multiple evaluators* and average — single-LLM judgement is noisy. (Lead-in: how would you build that? Ex 05's parallelisation pattern.)

4. **The pattern composes.** The same evaluator-optimiser shape appears in Ex 07 as the policy-audit step. Once students see this, "draft → check → revise" becomes a vocabulary item they recognise everywhere.

## Common student errors

| Error | Lesson |
|---|---|
| Scorer returns prose | Re-read the narrow-prompt slide. The output contract isn't optional. |
| `Number($json.text)` without `.trim()` | LLMs append newlines. Always trim. |
| Threshold left at `0` (placeholder) | Everything passes. The revision path never fires. |
| Revise regenerates from scratch | The whole point is to use the feedback. Reference both the draft AND the feedback. |
| Final nodes have different field shapes | Downstream code breaks. Pick a schema, both terminals match it. |
| Tries to build a real loop | Out of scope. n8n's loop construct is for batches, not retry-with-backoff. Building real loops needs counters and a give-up branch. |

## Progressive destruction prompts

- **"Make the threshold 10."** The first draft never passes. Watch the revision fire every time. Sometimes the revision still scores < 10. Real-world: this is why production loops have max-attempts.
- **"Use a different model for Score Draft."** Swap in `qwen2.5:7b`. Compare scores on identical drafts. Different models have different "personalities" as evaluators.
- **"Run the scorer twice in parallel and average."** Combines Ex 06 with Ex 05. Real-world consensus pattern.
- **"What if Critique's feedback is wrong / unhelpful?"** Revise can't tell. Now you need a Critique-evaluator that scores the *feedback* before passing it to Revise. Patterns nest indefinitely.

## Mapping back to the slides

- Slide 2586 (*"Pattern: Evaluator / Optimiser"*) — abstract pattern, source diagram.
- Slide 2846 (*"Prompting for workflow agents"*) — the narrow-output discipline that makes the scorer work.
- The "Draft email → check tone and grammar → revise until good" example in the slide is essentially this exercise.

## Threads forward

- **Ex 07 (Research Agent — final lab)**: the policy-audit loop is a direct application of this pattern. Audit findings against ICD policies → if any violations → critique → revise. Same shape, different domain.
- **Ex 08 (Policy Simplifier, optional)**: uses a similar shape to verify that simplified XML is still complete.
- Conceptually bridges to **Session 5 (Autonomous Agents)** where the loop becomes self-driven and unbounded.

## On the loop limitation

Worth a brief note. The slide's diagram shows a loop ("Improve" arrow goes back to Generate). Real n8n implementations of this loop need:

1. A counter (max attempts).
2. A "give up" branch that produces a graceful failure output.
3. State maintenance across iterations (can't just fork and rejoin trivially).

We're skipping all of that for pedagogy. The single-retry version captures the *intent* (generate → evaluate → revise → done) without the operational complexity. Production versions of this pattern would use n8n's Loop Over Items node, sub-workflows with retry semantics, or explicit attempt counters in static data.

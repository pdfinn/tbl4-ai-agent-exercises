# Exercise 06 — Pattern: Evaluator / Optimiser

*Instructor-facing overview. Student-facing instructions are in `06-a-blank.md` and `06-b-half-built.md`.*

## Learning goal

Students realise the **Evaluator / Optimiser** pattern from the slides. By the end they should:

- Use one LLM to *generate* and another LLM (configured differently) to *evaluate* — same model, different prompts.
- Write a narrow numeric-output prompt for an evaluator (1-10 score, no explanation).
- Use an IF gate against the numeric output to route to *accept* vs. *critique-and-revise*.
- Compose a Critique step that produces actionable feedback as input to a Revise step.
- Understand why this is *one retry, not a loop* — and what would be needed to build a real loop with retry counters.

## Domain

Writing assistance — the model drafts an email, scores it, and revises if needed. Universally relatable. Substitutable: any document the LLM can both produce and evaluate (a Slack message, an SQL query, an apology note, code).

## The three artefacts

| File | Use |
|---|---|
| `06-a-blank.workflow.json` | Manual Trigger + 5 sticky notes (pattern, task, prompt-design tips, rules, extension). |
| `06-b-half-built.workflow.json` | Full 10-node graph with three gaps: scorer prompt, IF threshold, revise prompt. |
| `06-c-reference.workflow.json` | Working solution. |

## Recommended session flow (~60 min)

1. **(5 min) Whiteboard.** Redraw the slide's pattern. Highlight the *gate-and-loopback* shape — but immediately clarify "we're going to do one retry, not an infinite loop, because real loops with retry counters are noisier than the lesson needs."
2. **(5 min) Demo a sloppy evaluator.** Show what happens when the Score prompt is too vague: "Rate this 1-10" returns "I'd give it about a 7, here's why...". Output is unparseable; the IF can't compare. Then tighten the prompt: "Output ONE number, no explanation." Watch it work. *That's the lesson moment.*
3. **(35 min) Pair build.** Watch for:
   - Scorer prompts returning prose (the most common failure).
   - IF threshold left at the placeholder `0` so everything passes.
   - Revise prompts that ignore the feedback (and just regenerate).
4. **(5 min) Run with a low threshold (4).** Most drafts pass on first try. Then with a high threshold (9). Watch the revision path fire on every run. Discuss the implications of strict gates.
5. **(10 min) Discuss the loop limitation.** What would a *real* loop look like? Counter, max attempts, "give up gracefully" branch. We don't build it here, but acknowledge it. Lead-in to autonomous agents (Session 5).

## The 3 gaps in variant B (answer key)

1. **Score Draft prompt:**
   ```
   =Evaluate the following draft against the original brief. Score it from 1 to 10 considering: clarity, tone match, length match, completeness.

   Output EXACTLY ONE number between 1 and 10. No explanation, no punctuation, no preamble. Just the number.

   Brief:
   {{ $('Set Input').item.json.task }}

   Draft:
   {{ $json.text }}
   ```

2. **Score >= 8? → rightValue:** `8`.

3. **Revise prompt:**
   ```
   =Revise the draft based on the feedback. Output the revised document only — no preamble.

   Brief:
   {{ $('Set Input').item.json.task }}

   Original draft:
   {{ $('Generate Draft').item.json.text }}

   Feedback:
   {{ $('Critique').item.json.text }}
   ```

## Why two terminal nodes (Final Approved / Final Revised)?

The simplest n8n way to handle "two paths produce different data shapes" without a real Merge dance. Both terminal nodes share the same field names (`score`, `outcome`, `final_draft`), so a downstream consumer (an email node, a Slack post, etc.) can read either one identically.

The `outcome` field — `approved-on-first-try` vs. `revised-after-critique` — is the discriminator if anyone needs to know which path produced the result.

## Progressive destruction prompts

- **"Run it five times. Does the same draft always score the same?"** No — LLMs are non-deterministic. Discuss: this is why real production systems average multiple evaluator runs.
- **"Make the threshold 10."** The first draft will essentially never pass. Watch the revision path fire every run. Sometimes the revision still scores < 10. Lead-in to multi-attempt loops.
- **"Use a different model for the evaluator than the generator."** Swap in `qwen2.5:7b` for the Score Draft node. Now you have a "harsher" evaluator. Compare scores on identical drafts.
- **"Add a third pass."** Build Critique-2 → Revise-2 after Final (Revised) if the revised draft also scores low. Now you have two-attempt logic. The complexity creep is the lesson — patterns are addictive.

## Common student errors

| Error | Lesson |
|---|---|
| Scorer returns prose | Prompt isn't narrow enough. Re-read slide 2846. |
| IF compares the *whole text* instead of the parsed number | The expression `Number($json.text.trim())` is what makes the comparison work. |
| Revise prompt regenerates from scratch instead of revising | The Revise prompt MUST reference the original draft AND the feedback. Otherwise it ignores both. |
| Final (Approved) and Final (Revised) have different field names | Downstream consumers can't read the result generically. Same shape, different content. |
| Threshold left at placeholder | Everything passes. The exercise looks done but the revision path never fires. |

## Mapping back to the slides

- Slide 2586 (*"Pattern: Evaluator / Optimiser"*) — the abstract pattern.
- Slide 2846 (*"Prompting for workflow agents"*) — the narrow prompt discipline that makes the scorer work.
- This pattern is the conceptual ancestor of the policy-audit loop in Ex 07.

## Threads forward

- **Ex 07 (Research Agent — final lab)** uses this pattern as the policy-audit step: draft a briefing → audit against ICD policies → revise if non-compliant. Same shape, different evaluator.
- **Ex 08 (Policy Simplifier, optional)** uses an evaluator to check that the simplified XML is still complete and accurate.
- Bridges to **Session 5 (Autonomous Agents)** — multi-attempt loops with self-evaluation are how autonomous agents reason.

## Import instructions

From inside n8n: **Workflows → top-right menu → Import from File** → pick one of the `.json` files. Confirm `Ollama (local)` is selected on the Ollama Chat Model.

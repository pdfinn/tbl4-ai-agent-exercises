# Exercise 06 — Evaluator / Optimiser (Blank Starter)

Build the Evaluator / Optimiser pattern from the slides as an n8n workflow.

## The pattern

```
Task → Generate → Evaluate ─┬─ pass ─→ Final (Approved)
                             └─ fail ─→ Critique → Revise → Final (Revised)
```

One LLM generates an output. A second LLM (same model, different prompt) scores it. If the score passes a threshold, the output is accepted. If not, the workflow critiques the failure, revises, and produces a new output.

## Your goal

Build a workflow that drafts a writing task (e.g., a friendly team email), scores its own output, and either ships the first draft or revises it based on feedback.

## What you've been given

- A **Manual Trigger** node.
- Five sticky notes describing the pattern, the task, prompt design tips, rules, and an extension.

## Build it

### Inputs (Set node)

- `task` — a writing brief. Example: *"Draft a short, friendly email to my team asking everyone to send a one-paragraph weekly update by 5pm Friday. Tone: warm but clear. Length: under 80 words."*

### Pipeline

1. **Generate Draft (Basic LLM Chain)** — produce the draft. Prompt asks for the document, references the task.
2. **Score Draft (Basic LLM Chain)** — score the draft 1–10. THIS PROMPT IS NARROW: it must output ONE NUMBER, nothing else. References the brief and the previous draft.
3. **Score >= 8? (IF node)** — uses the expression `={{ Number($json.text.trim()) }}` on the left side, comparing to your chosen threshold (8 is the slide's default). Operator: *Greater than or equal to*.
4. **Pass branch (true):** Final (Approved) — a Set node. Fields: `score`, `outcome` ("approved-on-first-try"), `final_draft`.
5. **Fail branch (false):** Critique (Basic LLM Chain) → Revise (Basic LLM Chain) → Final (Revised). Critique gives ONE sentence of actionable feedback. Revise produces the new draft from the original + the feedback.

### Same field shape on both terminals

Both Final nodes should produce items with the same field names (`score`, `outcome`, `final_draft`) so downstream consumers don't care which path ran. Use `outcome` to discriminate.

### Models

`llama3.1:8b`, credential `Ollama (local)`. One Ollama Chat Model sub-node feeds all four Basic LLM Chains via four `ai_languageModel` connections.

## Three different prompt styles

This exercise asks you to write *four* prompts that are each tuned to a different purpose:

- **Generate Draft** — open prose: tell the model what to write.
- **Score Draft** — narrow output: ONE number 1-10, no explanation. (Like Ex 04's classifier.)
- **Critique** — structured but short: ONE actionable sentence. Don't write a new draft.
- **Revise** — composite: takes the draft AND the feedback, produces a revised draft.

Same model, same syntax, different behaviour — driven entirely by prompt design.

## Rules

- **No Code node.** Allowed: Set, IF, Basic LLM Chain, Ollama Chat Model.
- **One retry only.** Don't try to build an actual loop. The slide's "loop until threshold met" is a real production pattern; here we're showing the *single-pass* version of it.
- **Run multiple times** with the same input to see the non-determinism — the same draft can score 7 in one run and 9 in another.

## Success

You execute the workflow. Either:
- Score >= 8: Final (Approved) shows the original draft labelled `approved-on-first-try`.
- Score < 8: Final (Revised) shows the revised draft labelled `revised-after-critique`, with the feedback that drove the revision.

## Extension — if you finish early

- **Strict gate.** Set the threshold to 9 or 10. Watch the revision path fire on almost every run.
- **Different evaluator persona.** Make the Score Draft prompt say "You are a strict editor for The Economist." Compare scores against the default.
- **Two-evaluator consensus.** Run the scorer twice in parallel (see Ex 05), average the scores. Reduces single-judgement noise.

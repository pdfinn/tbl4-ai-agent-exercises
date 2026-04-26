# Exercise 05 — Pattern: Parallelisation

*Instructor-facing overview. Student-facing instructions are in `05-a-blank.md` and `05-b-half-built.md`.*

## Learning goal

Students realise the **Parallelisation** pattern from the slides. By the end they should:

- Recognise fan-out/fan-in shape: one input feeds many independent tasks, results combine.
- Use the **Merge node** with multiple input slots — and understand `combineByPosition` as the mode for "first item from each input pairs into one merged item."
- Specialise each branch's prompt to a different output style: free prose (Summary), structured list (Entities), one word (Sentiment).
- Use cross-node references in the final Compose step — the same pattern they saw in Ex 04 of the data.gov.sg unit.
- See the difference between the *graph topology* of parallelisation (truly parallel branches) and n8n's *runtime execution order* (which can serialise even parallel branches when they share a model).

## Domain

Document analysis. The reference uses a memo about hawker centre operations — multiple named people and places, a clear sentiment, distinct decisions. That gives all three sub-tasks something to chew on. Domain-substitutable: a press release, a research abstract, a meeting transcript.

## The three artefacts

| File | Use |
|---|---|
| `05-a-blank.workflow.json` | Manual Trigger + 5 sticky notes (pattern, task, Merge wiring tips, rules, extension). |
| `05-b-half-built.workflow.json` | Full 8-node graph with three gaps: Entities prompt, Sentiment prompt, Compose Report template. |
| `05-c-reference.workflow.json` | Working solution. |

## Recommended session flow (~60 min)

1. **(5 min) Whiteboard.** Redraw the fan-out / fan-in. Highlight: same input, different prompts, recombined output.
2. **(5 min) Demo Merge slots.** This is the new piece. Show how setting `Number Of Inputs: 3` on Merge exposes three input slots on the canvas. Draw three connections, one from each parallel branch.
3. **(35 min) Pair build.** Watch for:
   - Students wiring all three branches to the same input slot (Merge then sees 3 items in slot 0, not 1 item per slot).
   - Students forgetting to set `Number Of Inputs: 3` (Merge defaults to 2).
   - Confusion about the difference between Set Input fanning OUT to 3 (fan-out) vs. Merge fanning IN from 3 (fan-in). Same n8n connection mechanism, opposite intent.
4. **(5 min) Run it; read the report.** Students see Markdown output combining all three branches.
5. **(5 min) Discuss execution order.** In n8n v1 execution, the three "parallel" branches actually run *sequentially* (one after another) on the same Ollama instance. They're parallel in the *graph* but not the *runtime*. This is a real-world gotcha worth naming.
6. **(5 min) Debrief.** Release reference. Compare prompts.

## The 3 gaps in variant B (answer key)

1. **Extract Entities prompt** — must produce structured output:
   ```
   =Extract named entities from this document and group them by type. Use this exact format — nothing else:

   People: <comma-separated list, or "none">
   Places: <comma-separated list, or "none">
   Organisations: <comma-separated list, or "none">
   Dates: <comma-separated list, or "none">

   Document:
   {{ $('Set Input').item.json.document }}
   ```

2. **Classify Sentiment prompt** — one-word output:
   ```
   =Classify the overall sentiment of this document as exactly one word: POSITIVE, NEUTRAL, or NEGATIVE. No explanation, no punctuation, no preamble.

   Document:
   {{ $('Set Input').item.json.document }}
   ```

3. **Compose Report `report` value** — Markdown with cross-node refs:
   ```
   =# Document analysis report

   ## Summary
   {{ $('Summarise').item.json.text }}

   ## Entities
   {{ $('Extract Entities').item.json.text }}

   ## Sentiment
   **{{ $('Classify Sentiment').item.json.text.trim() }}**
   ```

## Progressive destruction prompts

- **"Why does each branch need a different prompt style?"** Force the question. Some students try to use one general prompt for all three. Show: the Sentiment branch needs deterministic single-word output for downstream use; the Summary branch needs prose; the Entities branch needs structured fields. Three different output contracts.
- **"Add a fourth branch: translate to Bahasa Melayu."** Easy add — but show the Merge needs `Number Of Inputs: 4` and a fourth slot wiring. Patterns extend without hand-waving.
- **"Replace one of the LLM branches with an HTTP call to data.gov.sg's `/environment/psi`."** Now the document is enriched with live air-quality data alongside its LLM analysis. Cross-domain composition.

## The runtime-order surprise

Worth a five-minute moment at the end. In n8n's v1 execution mode:

- The graph shows three parallel branches.
- The runtime serialises them — they don't actually run concurrently.
- Total wall-clock time = sum of three LLM calls, not max.

This is because Ollama (the model server) is a single-process, single-stream service for the local case. n8n's "parallel" branches share the same backend.

True parallelism would require either:
- Multiple Ollama instances behind a load balancer,
- Different models per branch (so each loads independently into memory),
- A cloud API (which can serve concurrently).

For class purposes, what matters is that **the graph topology and the runtime behaviour are different things**. The pattern is "logical parallelism for code structure" — even if the runtime serialises.

## Common student errors

| Error | Lesson |
|---|---|
| Wires all three branches to Merge slot 0 | Each branch needs its own slot. Set `Number Of Inputs: 3` on Merge first. |
| Forgets to set Number Of Inputs (defaults to 2) | Only two slots visible; one branch can't connect. |
| Uses one generic prompt for all three branches | Defeats the point of parallelisation. Each sub-task has different output requirements. |
| Compose Report runs three times | Means the Merge isn't actually merging — it's appending. Switch combineBy to `combineByPosition`. |
| Sentiment branch returns prose instead of one word | Prompt isn't narrow enough. Add explicit constraints. |

## Mapping back to the slides

- Slide 2551 (*"Pattern: Parallelisation"*) — abstract pattern.
- Slide 2846 (*"Prompting for workflow agents"*) — narrow vs. chatbot prompts; the three branches here are three narrow prompts.
- Slides Exercises 1-3 cover Chaining/Routing/Research; this exercise's source is the Parallelisation pattern slide.

## Threads forward

- **Ex 06 (Evaluator/Optimiser)** uses parallel branches to generate-and-evaluate concurrently.
- **Ex 07 (Research Agent — final lab)** uses parallelisation for the multi-query Wikipedia search step.

## Import instructions

From inside n8n: **Workflows → top-right menu → Import from File** → pick one of the `.json` files. Confirm the Ollama Chat Model has `Ollama (local)` selected.

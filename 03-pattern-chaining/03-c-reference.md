# Exercise 03 — Prompt Chaining (Reference, annotated)

*For instructor debrief. Not to be released until all pairs have completed.*

## The graph

```
Manual Trigger
  └─ Set Input (article + target_language)
       └─ Summarise (1st)               ← Basic LLM Chain
            └─ Under 100 words? (IF)
                 ├─ true ─→ Translate
                 └─ false ─→ Summarise (Stricter) ─→ Translate

Ollama Chat Model
  └── ai_languageModel ── (fans out to all three Chains)
```

## Why this shape

- **One Set node for inputs.** Hardcoding inputs in a Set is the cheapest way to teach this exercise without a webhook or form. Extension: replace with a Form Trigger.
- **Word-count expression on the left side of the IF.** Putting the count on the left, threshold on the right, keeps the comparison readable — *"length(summary) ≤ 100"* — same as you'd write in a spec.
- **Two paths converging at Translate.** This is the n8n idiom for either-or-then-rejoin. The Translate node has two incoming connections; whichever upstream produces an item triggers the run. No Merge node needed for this case.
- **One Ollama Chat Model sub-node fanning out.** All three Basic LLM Chains share the same model. The sub-node has three outgoing `ai_languageModel` connections from a single output socket. This is more efficient than three model nodes (each would force model-load). Worth pointing out.

## Points to surface at debrief

1. **The gate is what makes this *prompt chaining*, not just *call → call*.** A linear pipe of LLM calls is just a pipe. The lesson is the gate — a non-LLM check that sits between LLM steps and decides whether to proceed.
2. **The stricter prompt is real prompt engineering.** Students who write "make it shorter" get the same long output. Students who write "Maximum 80 words. No filler. Key points only." get measurable improvement. Workshop the difference if time permits.
3. **Which input does the stricter retry use?** The original article, not the first summary. If you re-summarise the summary, you get a worse summary, not a better one. (Compression artefacts compound.) This is a subtle and useful trap.
4. **Two paths converge.** Most students try to wire Translate twice or use a Merge node. Show that an n8n node simply accepts multiple incoming connections and runs once per item from any upstream.

## Common student errors

| Error | Lesson |
|---|---|
| Wires the false branch directly to Translate (skipping Stricter) | The whole point of the failure branch is to retry; don't skip the retry. |
| Re-summarises `$json.text` instead of the article | Compression artefacts compound. Always retry from the source. |
| Uses `text.length` (characters) instead of word count | Read your threshold's units. |
| Three separate Ollama Chat Models | Wasteful. Show that one fans out. |
| Threshold is too low (e.g. `30`) → infinite-feeling retry | The gate has no retry counter; one fail = one stricter attempt. There's no third try. Mention this. |

## Progressive destruction prompts

- "What happens if the first summary is in French already?" → No language check. The gate doesn't care; Translate gets a French summary and translates it again. Add a language-check stage.
- "Lower the threshold to `50`. Both summaries fail." → The workflow ends with a too-long summary going to Translate (because the False branch only fires once, then continues). Real-world fix: add a counter and a "give up" branch.
- "Add a third stage after Translate that gates on the translation being non-empty." → Multiple gates compose. The chain extends.

## Mapping back to the slides

This exercise corresponds to:
- Slide 2484 (*"Pattern: Prompt Chaining"*).
- Slide 2978 (*"Exercise 1 — Prompt chaining workflow"*).

Students should be able to point at the slide diagram and at their workflow side by side.

## Threads forward

- **Ex 04 (Routing)** uses the same gate idiom but with three branches, each with its own specialised prompt.
- **Ex 05 (Parallelisation)** removes the gate and uses parallel branches.
- **Ex 06 (Evaluator/Optimiser)** generalises the gate-and-retry to a real loop with a separate evaluator step.
- **Ex 07 (Research Agent)** uses Prompt Chaining as the spine of the multi-step pipeline.

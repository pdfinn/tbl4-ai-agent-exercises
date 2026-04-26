# Exercise 03 — Pattern: Prompt Chaining

*Instructor-facing overview. Student-facing instructions are in `a-blank.md` and `b-half-built.md`.*

## Learning goal

Students realise the **Prompt Chaining** pattern from the slides as a concrete n8n workflow. By the end they should:

- Recognise the shape: `Input → AI → Gate → AI → Output`, with the gate being the new bit.
- Use an **IF node** as a quality gate against an LLM's output (a non-deterministic upstream).
- Understand that **two converging connections into one node** is the n8n idiom for either-or-then-rejoin.
- Write a *secondary* prompt that runs only when the first attempt failed quality control. This is real prompt-engineering iteration in workflow form.
- See that **one Ollama Chat Model sub-node can feed multiple Basic LLM Chains** — the `ai_languageModel` connection isn't 1:1.

## Domain

Article → 100-word summary → translation. Sample article is on hawker culture, deliberately ~250 words so a 100-word summary is achievable but not trivial. The exact domain is unimportant; it just gives the LLM something concrete to chew on.

## The three artefacts

| File | Use |
|---|---|
| `a-blank.workflow.json` | Manual Trigger + 5 sticky notes (pattern, task, expression hint, rules, extension). |
| `b-half-built.workflow.json` | Full 7-node graph with three deliberate gaps: target language, IF threshold, second-summarise prompt. |
| `c-reference.workflow.json` | Working solution. Release at debrief. |

## Recommended session flow (~45 min)

1. **(5 min) Whiteboard.** Redraw the slide's diagram on the board. Trace what flows where. Ask: "If the gate fails, what should happen?" Get students to commit to *retry with stricter prompt* rather than just exiting — that's where the real lesson is.
2. **(5 min) Demo the gate expression.** `$json.text.split(/\s+/).filter(w => w.length > 0).length` is intimidating to a non-programmer. Walk through it once: split on whitespace, drop empty pieces, count what's left. Don't ask students to write it from scratch — it's reproducible boilerplate.
3. **(25 min) Pair build.** Most students will pick variant B. Watch for:
   - Confusion about which IF branch is which (top output = true, bottom output = false in the canvas).
   - Trying to wire Translate twice instead of letting both upstream branches feed it.
   - Forgetting to attach the Ollama credential on the Chat Model.
4. **(5 min) Compare summaries.** Run the workflow once with the default 100-word threshold. Run it again with the threshold lowered to 50. Watch the gate flip — and watch the stricter prompt take effect on the retry.
5. **(5 min) Debrief.** Release `c-reference.workflow.json`. Highlight the converging-into-Translate pattern.

## The 3 gaps in variant B (answer key)

1. **Set Input → `target_language`** — any string the LLM understands. `French`, `Mandarin`, `Bahasa Melayu`, `Tamil`. Whatever the student picks.
2. **Under 100 words? → rightValue** — `100` (matches the slide). Half the value of teaching this is the student justifying the threshold.
3. **Summarise (Stricter) → prompt text** — example:
   > `=Your previous summary was too long. Produce a stricter, briefer summary. Maximum 80 words. No fluff, no preamble — key points only.\n\nArticle:\n{{ $('Set Input').item.json.article }}`
   Any prompt that's measurably more aggressive than the first works.

## Progressive destruction prompts

Once a pair has the workflow running:

- "Lower the threshold to 50. Now both summaries are too long. What happens?" → infinite-loop trap. Lead-in to retry-with-counter or fail-after-N attempts.
- "Add a third condition to the IF: also fail if the summary contains forbidden words (`AI`, `intelligence`, `culture`). What's the AND/OR semantics?" → composing conditions.
- "What if the LLM returns a summary in a different language than the source?" → a real failure mode. Add a third gate that checks language.

## Common student errors

| Error | Lesson |
|---|---|
| Wires both Translate inputs to the IF (no go-through-stricter path) | The IF's false branch needs to chain *through* Summarise (Stricter) before reaching Translate. |
| Uses `text.length` instead of word count | `text.length` counts characters. Read the units in the threshold. |
| Forgets the leading `=` on expressions | Field is treated as literal string; the IF compares "{{ $json... }}" (literal) to 100 and routes everything to false. |
| Three Ollama Chat Model sub-nodes | Possible but wasteful — each loads the model in memory. One sub-node serves all three Chains. |

## What this exercise teaches that the next ones build on

- **Ex 04 (Routing)** uses the same IF/Switch pattern but with multiple branches, each with its own specialised prompt.
- **Ex 06 (Evaluator/Optimiser)** generalises the gate-and-retry idea into a real loop with a separate evaluator step.
- **Ex 07 (Research Agent — final lab)** uses chaining as the spine of the research pipeline.

## Import instructions

From inside n8n: **Workflows → top-right menu → Import from File** → pick one of the `.json` files in this folder. Confirm the Ollama Chat Model node has the `Ollama (local)` credential attached after import.

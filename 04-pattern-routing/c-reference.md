# Exercise 04 — Routing (Reference, annotated)

*For instructor debrief. Not to be released until all pairs have completed.*

## The graph

```
Manual Trigger
  └─ Set Input (customer_message)
       └─ Classify (Basic LLM Chain — one-word output)
            └─ Route (Switch on $json.text)
                 ├─ BILLING ─→ Handle Billing (Basic LLM Chain — billing prompt)
                 ├─ TECHNICAL ─→ Handle Technical (Basic LLM Chain — technical prompt)
                 └─ GENERAL ─→ Handle General (Basic LLM Chain — general prompt)

Ollama Chat Model
  └── ai_languageModel ── (fans out to all four Chains)
```

## Why this shape

- **Set Input first.** Hardcoding the customer message in a Set node is the cheapest way to swap test inputs without recreating the trigger. Replace with Form Trigger when going to production.
- **Classifier output is constrained.** The prompt tells the model what to do AND what NOT to do. The "EXACTLY ONE WORD" instruction, combined with explicit category definitions, makes the output deterministic enough for routing.
- **Switch uses `contains` with `caseSensitive: false`.** Belt-and-braces matching — handles "BILLING", "billing", "Billing", and "BILLING\n" identically. Real LLM outputs vary in subtle ways; the matcher should tolerate that.
- **`.trim()` on the left side.** LLMs sometimes append a newline. Trimming the left side before comparison handles this without making the prompt more elaborate.
- **Three specialist Chains, one shared model.** Same Ollama Chat Model sub-node, four outgoing `ai_languageModel` connections. The "four agents" are really one model with four prompts.

## Points to surface at debrief

1. **The classifier is the lesson.** A sloppy classifier breaks every downstream branch. A tight classifier makes everything else easy. Reading slide 2846 ("Prompting for workflow agents") next to the classifier prompt is high-value.
2. **Specialist prompts should be measurably different.** If Billing and Technical produce indistinguishable outputs, the routing was for nothing. Workshop one student's prompts at debrief.
3. **One model, four agents.** This is what the slides mean by "agent" — a model + a system prompt for a specific task. Not magic, just a focused configuration.
4. **The fallback matters.** "If unsure, choose GENERAL" gives the model a safe default. Without it, ambiguous messages produce ambiguous (often non-routable) outputs.

## Common student errors

| Error | Lesson |
|---|---|
| Classifier returns "I think this is a billing issue" | Prompt wasn't narrow enough. Add explicit constraints. |
| Switch is `equals` not `contains` | Trailing newlines or punctuation defeat exact match. |
| Three handlers have nearly-identical prompts | Then routing didn't accomplish anything. Specialise. |
| Forgets `.trim()` on the Switch left value | Trailing newline = no match = falls through to fallback. |
| Wires Ollama only to Classify | Four Chains need the model. One sub-node, four outgoing connections. |
| Doesn't test all three messages | The exercise isn't done if only one branch has been verified. |

## Progressive destruction prompts

- **Two-category message:** *"I was charged for the Pro plan but the app crashes when I try to use it."* The classifier picks one, but it's BOTH. Lead-in to multi-label classifiers and parallelisation (Ex 05).
- **Lowercase ambiguity:** Force the classifier to return lowercase by changing its prompt. Watch the Switch behave (or not) depending on `caseSensitive`. Real-world fragility lesson.
- **No fallback:** Remove "If unsure, choose GENERAL" from the classifier. Watch what happens with ambiguous inputs. Sometimes the model invents a fourth category. Now what?

## Mapping back to the slides

- Slide 2520 (*"Pattern: Routing"*) — the abstract pattern, three branches.
- Slide 2846 (*"Prompting for workflow agents"*) — the narrow vs. chatbot-style distinction; this is the worked example.
- Slide 2998 (*"Exercise 2 — Routing workflow"*) — direct source of this exercise.

## Threads forward

- **Ex 05 (Parallelisation)** — the fan-out shape, but every branch fires (no Switch dispatch). Different intent.
- **Ex 06 (Evaluator/Optimiser)** — the evaluator step uses a narrow prompt like the classifier here, but its output is a numeric score not a category.
- **Ex 07 (Research Agent)** — uses a routing-like decision after the audit step (publish vs. revise).
- **Ex 09 (Model Rodeo, optional)** — re-runs THIS workflow with different LLMs swapped in. The classifier is the most sensitive node to model quality.

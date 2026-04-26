# Exercise 02b — Workflow Warm-Up

A three-stage primer on the n8n primitives that the pattern exercises (Ex 03–07) silently assume. **Optional but strongly recommended** before students attempt Ex 03 if their n8n background is light.

## Why this exists

Session 4's slides motivate the four workflow patterns brilliantly but don't drill the n8n primitives needed to build them. Ex 03 onwards expects students to:

- Write n8n expressions: `{{ ... }}`, the `=` prefix, `$json`, `$('NodeName').item.json`.
- Configure the IF node correctly (with the `options.version: 2` quirk).
- Wire sub-nodes via the `ai_languageModel` sideways connection.
- Use `.trim()` on LLM outputs.
- Write narrow-output classifier prompts.

If a student arrives at Ex 03 missing any of these, they will struggle for non-pedagogical reasons (typos, syntax confusion, wrong fields) rather than struggling productively with the patterns themselves. This warm-up surfaces every primitive on a small, focused canvas before Ex 03 needs them.

## Format

Three progressively-built stages, like Ex 00. No `a-blank` / `b-half-built` / `c-reference` variants — this is a primer, not a pattern exercise.

| Stage | Nodes | What it drills | Time |
|---|---|---|---|
| 1 — Expressions and cross-node refs | 5 (Manual, Set, LLM Chain, Set, Ollama) | `=` prefix, `{{ $('Node').item.json.x }}`, `{{ $json.text }}`, sub-node wiring | ~15 min |
| 2 — The IF node | 5 (Manual, Set, IF, Set, Set) | IF configuration, binary routing, two terminal nodes, testing both paths | ~15 min |
| 3 — LLM classifier + IF (Ex 04 in miniature) | 7 (Manual, Set, LLM Chain, IF, Set, Set, Ollama) | Narrow-output classifier prompts, `.trim()`, `contains` vs `equals`, the routing pattern in miniature | ~15 min |

Total: ~45 minutes.

## When to use this

- **Before Ex 03** if your students did not complete the data.gov.sg unit or the equivalent — i.e. their only n8n background is Session 3's MCP/chaining intro.
- **As a refresher** at the start of the Session 4 lab if students seem rusty.
- **As a debug sandbox** if a student gets stuck on Ex 03 / 04: have them open Stage 3 here and confirm they can build the IF + classifier shape on a tiny canvas before scaling up.

## Recommended session flow

1. **(2 min) Frame the warm-up.** "Before we hit the patterns, we're going to drill the primitives. Same idea as scales before the symphony."

2. **(15 min) Stage 1.** Students import `stage-1-expressions.workflow.json`, run it, click on each node and read the output panel. Optionally have them change the input sentence (e.g. "Your code is broken." or "I disagree completely.") and re-run. Walk the room — this is where you catch students who don't yet read the output panel.

3. **(15 min) Stage 2.** Import `stage-2-if-node.workflow.json`, run it once with `mood: happy` (default), then change `mood` in *Set Mood* to anything else and re-run. Both branches should fire across the two runs.

4. **(15 min) Stage 3.** Import `stage-3-llm-classifier.workflow.json`. Run it on the default sentence, then on a deliberately sad one ("My team lost again"), then on something ambiguous ("It's Monday"). Watch the classifier and the routing.

5. **(5 min) Bridge to Ex 03.** "You've now built Ex 04 in miniature. The patterns are this shape, scaled up. Ex 03 adds a quality gate. Ex 04 swaps the IF for a Switch and adds a third branch. Ex 05 adds parallel branches. Ex 06 adds an evaluator. Same primitives, new compositions."

## What students should be able to do after this warm-up

Without prompting:
- Identify what the `=` prefix does on a field value.
- Write `{{ $('Set Input').item.json.x }}` to read a field from a named upstream node.
- Configure an IF node to compare a string against a literal.
- Connect an Ollama Chat Model to a Basic LLM Chain via the `ai_languageModel` sideways connection.
- Read the output panel on any node and find the `text` field on an LLM Chain's output.

If they can do all five, they're ready for Ex 03.

## Common student errors caught here (better than later)

| Error | Stage | Fix |
|---|---|---|
| Forgets the `=` prefix | 1 | Field is treated as a literal string. The expression appears verbatim in the output. |
| Pastes `$('Set Input').item.json.x` *without* the `{{ }}` brackets | 1 | Same outcome — string instead of value. Both `=` and `{{ }}` are required. |
| Forgets `options.version: 2` on the IF | 2 | n8n shows a validation error. Easier to learn here than in a 14-node workflow. |
| Uses `equals` instead of `contains` for LLM output | 3 | LLM appends a newline; equals fails. The combination of `.trim()` + `contains` is forgiving. |
| Doesn't test the false branch | 2, 3 | Half the workflow is unverified. Always run with both inputs. |

## Files

- `stage-1-expressions.workflow.json` — start here.
- `stage-2-if-node.workflow.json` — second.
- `stage-3-llm-classifier.workflow.json` — third; this completes the primer.

## What this is NOT

- Not a pattern exercise. The patterns are 03–07.
- Not a substitute for prior n8n exposure. Students who have NEVER used n8n before will struggle with even Stage 1; they should do a basic n8n intro first.
- Not a replacement for instructor scaffolding. The instructor still walks through Stage 1 live, then sets the class loose on 2 and 3.

## Threads forward

- **Ex 03 (Prompt Chaining)** uses everything from this primer plus the converging-IF pattern (two paths into one node).
- **Ex 04 (Routing)** is essentially Stage 3 here, scaled up to three branches with a Switch node.
- **Ex 05 (Parallelisation)** adds the Merge node — new primitive — but the cross-node refs and sub-node wiring carry over.
- **Ex 06 (Evaluator)** adds numeric comparisons in the IF (`Number($json.text.trim()) >= 8`) — new wrinkle on the IF, same pattern.
- **Ex 07 (Research Agent)** combines all of these.

## Import instructions

From inside n8n: **Workflows → top-right menu → Import from File** → pick one of the three stage files. Confirm the Ollama Chat Model has the `Ollama (local)` credential selected after import.

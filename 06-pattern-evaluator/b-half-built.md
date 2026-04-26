# Exercise 06 — Evaluator / Optimiser (Half-Built)

Ten nodes are on the canvas, fully wired. **Three fields are blank or set to placeholders** — fill them in.

## Gap 1 — The Score Draft prompt

The **Score Draft** node has its prompt blank. This is the most important prompt in the workflow — get it wrong and the IF gate downstream can't make a decision.

Write a NARROW prompt that returns ONE number 1-10. The discipline is the same as the classifier in Ex 04: tight constraints, explicit output format, zero room for prose.

The prompt should:
- Tell the model to evaluate the draft against the brief.
- List criteria (clarity, tone, length, completeness).
- Demand: ONE number, between 1 and 10, no explanation, no punctuation.
- Reference the brief: `{{ $('Set Input').item.json.task }}`
- Reference the draft: `{{ $json.text }}` (the previous-node output)

## Gap 2 — The threshold

The **Score >= 8?** node has its `rightValue` set to `0`. That means everything passes the gate (any score from 1-10 is `>= 0`).

Change it to the threshold from the node's name. The slide uses 8.

(The expression on the left, `={{ Number($json.text.trim()) }}`, is already done — it converts the text-output of the scorer to a number.)

## Gap 3 — The Revise prompt

The **Revise** node has its prompt blank. This is a *composite* prompt — it pulls in three things:

- The brief: `{{ $('Set Input').item.json.task }}`
- The original draft: `{{ $('Generate Draft').item.json.text }}`
- The feedback: `{{ $('Critique').item.json.text }}`

Write a prompt that asks the model to revise the original draft based on the feedback. Output the revised document only — no preamble.

(The Critique prompt is already filled in — read it as a template for how Revise should compose multiple upstream sources.)

## Everything else is already done

- Generate Draft has its prompt.
- Critique has its prompt — references brief, draft, and score.
- Both terminal nodes (Final Approved / Final Revised) are configured with the same field shape.
- The IF expression on the left side parses the score correctly.
- All four Basic LLM Chains share one Ollama Chat Model sub-node.

## Run it twice

After your gaps are filled, run the workflow at least twice with the same input. LLMs are non-deterministic — the same draft can score 7 in one run and 9 in another. Both paths (Approved and Revised) should be reachable.

## Rule

No Code node.

## Extension — if you finish early

- Set the threshold to 9 or 10. Watch how rarely the first draft passes.
- Change the Score Draft prompt's persona ("strict editor", "friendly proofreader") and compare scores.
- Run the scorer twice in parallel (Ex 05's pattern) and average the two scores.

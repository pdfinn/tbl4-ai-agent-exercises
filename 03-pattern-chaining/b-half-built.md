# Exercise 03 — Prompt Chaining (Half-Built)

Seven nodes are on the canvas, fully wired. **Three fields are blank or set to placeholder values** — fill them in.

## Gap 1 — `target_language`

The **Set Input** node has `target_language` blank. Pick a language for the translation step. Anything the LLM speaks: `French`, `Mandarin`, `Tamil`, `Bahasa Melayu`, `Spanish`, `Tagalog`. Your call.

## Gap 2 — The gate threshold

The **Under 100 words?** node has its `rightValue` set to `0`. That means the gate would always fail — the summary can never have ≤ 0 words.

Change it to the threshold from the slide. (Hint: the node is named after the threshold.)

The expression on the left side is already done — it counts words in the upstream summary using:

```
={{ $json.text.split(/\s+/).filter(w => w.length > 0).length }}
```

You set the right side. It's a number, not a string.

## Gap 3 — The stricter prompt

The **Summarise (Stricter)** node has its prompt text blank. This node only runs when the first summary failed the gate.

Write a prompt that does what the name suggests: produce a stricter, shorter summary. Be more aggressive than the first prompt — try a lower word limit (e.g. 80), forbid filler, demand keywords-only style.

Reference the original article via:

```
{{ $('Set Input').item.json.article }}
```

(Don't reference `{{ $json.text }}` — that's the previous *summary*, not the article. We want a fresh attempt at summarising the original.)

## Everything else is already done

- **Summarise (1st)** has its prompt.
- **Translate** has its prompt and references both the language input and the upstream summary.
- The IF node's left-side expression already counts words correctly.
- The wiring is correct: pass branch → Translate; fail branch → Stricter → Translate.
- The Ollama Chat Model is already connected to all three Chains via `ai_languageModel`.

## Before you run

Click on the **Ollama Chat Model** node and confirm the credential is `Ollama (local)`. (After importing, n8n sometimes drops the credential reference.)

## Rule

No Code node. Use the expressions in the prompts and the IF gate.

## Extension — if you finish early

- Lower the gate threshold to `50`. Now both summaries fail the gate. Watch what happens — and propose a fix.
- Add a Form Trigger so anyone with the URL can paste any article and get a translation back.

# Exercise 03 — Prompt Chaining (Blank Starter)

Build the Prompt Chaining pattern from the slides as an n8n workflow.

## The pattern

```
Input → Summarise → Quality Gate ─┬─ pass ─→ Translate → Output
                                   └─ fail ─→ Re-summarise (stricter) ─→ Translate → Output
```

The gate decides whether to proceed with the first summary, or take the failure branch and try again with a stricter prompt. **Both paths converge at Translate** — that's the n8n idiom for "either-or-then-rejoin."

## Your goal

Click *Execute Workflow* and produce a translated summary of an article. If the first summary is over 100 words, the workflow automatically retries with a stricter prompt before translating.

## What you've been given

- A **Manual Trigger** node.
- Four sticky notes describing the pattern, the task, an expression hint, the rules, and an extension.

You build the rest.

## Build it

### Inputs (use a Set node right after the trigger)

- `article` — a 200–300 word block of text. (Pick anything you like, or grab a paragraph from a news site.)
- `target_language` — French, Mandarin, Tamil, Bahasa Melayu — whatever you want to translate into.

### Pipeline

1. **Summarise (1st)** — a Basic LLM Chain. Prompt: ask for a summary in under 100 words. Reference the article via `{{ $('Set Input').item.json.article }}`.
2. **Under 100 words?** — an IF node. (See the *expression hint* sticky note for how to count words.)
3. On **pass (true)** — go straight to Translate.
4. On **fail (false)** — go through a second Basic LLM Chain (`Summarise (Stricter)`) with a tougher prompt, then go to Translate.
5. **Translate** — a Basic LLM Chain. Prompt: translate the input to `{{ $('Set Input').item.json.target_language }}`.

Both pass-path and fail-path converge at Translate. Wire two incoming connections into the Translate node.

### Models

- **Model:** `llama3.1:8b` (or whatever you have pulled).
- **Credential:** select `Ollama (local)` on the Ollama Chat Model node.
- **Sharing:** one Ollama Chat Model sub-node can feed all three Basic LLM Chains via three outgoing `ai_languageModel` connections. You don't need three model nodes.

## Rules

- **No Code node.** Allowed: HTTP, Set, IF, Basic LLM Chain, Ollama Chat Model.
- **Sketch first.** Draw the graph on paper. Decide where the failure branch rejoins the success branch.
- **Run after every node you add.** Read the output panel before extending.

## Success

You execute the workflow. The Summarise (1st) output is checked by the gate. If the count was ≤ 100, the workflow continued straight to Translate. If not, it ran Summarise (Stricter) first, then Translate. Either way, the final output is a translated summary.

## Extension — if you finish early

- **Compose conditions.** Add a second condition to the gate: fail if the summary uses any forbidden word (`AI`, `intelligence`, `revolutionary`). Use the IF's AND combinator.
- **Replace Manual Trigger with a Form Trigger.** Now you have a public URL where someone can paste any article and get a translated summary back.
- **Chain three patterns.** Add a third stage *after* Translate: a second gate that checks the translation isn't empty, then formats it as Markdown.

# Exercise 05 — Parallelisation (Blank Starter)

Build the Parallelisation pattern from the slides as an n8n workflow.

## The pattern

```
Document ─┬─→ Summarise        ─┐
          ├─→ Extract Entities  ┼─→ Merge ─→ Compose Report
          └─→ Classify Sentiment┘
```

Three independent sub-tasks process the same document in parallel branches. A Merge node combines their outputs; a Compose Report node assembles them into a single Markdown document.

## Your goal

Take a document; produce a structured analysis report containing a summary, an entity list, and a sentiment classification — all from one execution.

## What you've been given

- A **Manual Trigger** node.
- Five sticky notes (pattern, task, Merge wiring tips, rules, extension).

## Build it

### Inputs (use a Set node)

- `document` — pick a document with multiple people, places, dates, and a clear tone. A meeting memo, press release, or memo works best.

### Three parallel branches

Each is a Basic LLM Chain off the Set Input:

1. **Summarise** — 2-sentence summary, free prose.
2. **Extract Entities** — structured list:
   ```
   People: <list, or "none">
   Places: <list, or "none">
   Organisations: <list, or "none">
   Dates: <list, or "none">
   ```
3. **Classify Sentiment** — one word: `POSITIVE`, `NEUTRAL`, or `NEGATIVE`.

Each branch has a *different* prompt style because each has a different output contract. The Sentiment branch's narrowness is what made Ex 04's classifier work.

### The Merge node

`n8n-nodes-base.merge`, version 3.2.

- **Mode:** Combine
- **Combine By:** Position
- **Number Of Inputs:** 3

Setting `Number Of Inputs: 3` exposes three input slots on the canvas. Wire each parallel branch's output to a different slot:
- Summarise → Merge slot 0
- Extract Entities → Merge slot 1
- Classify Sentiment → Merge slot 2

The Merge produces ONE item containing all three results.

### Compose Report

A Set node downstream of Merge, with one assignment:

- Field: `report`
- Type: string
- Value: a Markdown template with cross-node references — `{{ $('Summarise').item.json.text }}`, `{{ $('Extract Entities').item.json.text }}`, `{{ $('Classify Sentiment').item.json.text.trim() }}`. Wrap them in headings.

## Models

`llama3.1:8b`, credential `Ollama (local)`. One Ollama Chat Model sub-node feeds all three Chains via `ai_languageModel`.

## Rules

- **No Code node.** Allowed: Set, Merge, Basic LLM Chain, Ollama Chat Model.
- **Each branch's prompt is different.** Sentiment narrow, Entities structured, Summary prose. Don't use the same prompt three times.
- **Run after every node you add.** Read the data panel before extending.

## Success

You execute the workflow once. The Compose Report node's output panel shows a Markdown document with three sections — summary, entities, sentiment — generated from the same source document.

## A note on n8n's "parallel"

n8n v1 execution treats the three branches as *logically parallel* in the graph, but actually runs them *sequentially* on the same Ollama instance. Wall-clock time = sum of three LLM calls. This is fine for now — the lesson is the pattern shape, not the actual concurrency. Production setups with multiple model servers can run them concurrently for real.

## Extension — if you finish early

- Add a fourth branch: *Translate to Bahasa Melayu*. Update Merge's `Number Of Inputs` to 4.
- Replace one branch with an HTTP Request to `/environment/psi` — now the report includes live air-quality data alongside the document analysis.
- Replace the Manual Trigger with a Form Trigger. Anyone with the URL can submit a document.

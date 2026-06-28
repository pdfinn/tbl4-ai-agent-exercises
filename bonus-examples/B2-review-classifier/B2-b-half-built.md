# Bonus B2 — Classify Reviews, Then Filter (Half-Built)

Eight nodes are on the canvas, fully wired. **Three fields are blank** — fill them in.

## Gap 1 — the classifier prompt

The **Classify Sentiment** node has a blank prompt. Write a *narrow classifier*: read the review and output **exactly one word** — `POSITIVE`, `NEGATIVE`, or `NEUTRAL`. No explanation, no punctuation, no preamble.

The review text is at `{{ $json.review }}`.

Why one word? Because the Filter three nodes downstream routes on this value. "This review seems mostly negative…" can't be filtered cleanly; `NEGATIVE` can.

## Gap 2 — the filter value

The **Keep Negative Only** node has a blank `rightValue`. Type the sentiment to keep: `NEGATIVE`.

The operator is `contains` (case-insensitive), so a stray newline or capitalisation from the model won't break the match. The left side (`{{ $json.sentiment }}`) is already set.

## Gap 3 — the summary prompt

The **Summarise Complaints** node has a blank prompt. The negative reviews arrive aggregated into one item at `$json.flagged` (an array). Write a prompt asking for a 2-3 sentence summary: the recurring complaints, and which one to fix first.

Hint — feed the reviews in with:

```
{{ $json.flagged.map(r => '- ' + r.author + ': ' + r.review).join('\n') }}
```

## Already done for you — study this one

The **Tag Review** node shows the key trick. After the LLM runs, the item only holds `text` (the sentiment) — the original review is gone. Tag Review pulls it back with a **cross-node reference to the matching row**:

```
author    = {{ $('Split Reviews').item.json.author }}
review    = {{ $('Split Reviews').item.json.review }}
sentiment = {{ $json.text.trim() }}
```

`$('Split Reviews').item` is *the row that produced this verdict* — n8n tracks the pairing through the LLM step. This is how you carry a row's data across a node that rewrites the output.

## Before you run

Click **Ollama Chat Model** and confirm the credential is `Ollama (local)`.

## Rule

No Code node. The classifier's one-word discipline is the lesson.

## Extension — if you finish early

- Swap the Filter for a Switch and draft different replies for POSITIVE vs NEGATIVE (Ex 04 routing).
- Filter on `rating <= 2` instead and compare to the LLM's sentiment. Where do they disagree?

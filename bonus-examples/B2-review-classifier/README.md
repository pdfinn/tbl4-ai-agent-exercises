# Bonus B2 — Classify Reviews, Then Filter

*Instructor-facing overview. Student-facing instructions are in `B2-a-blank.md` and `B2-b-half-built.md`.*

A standalone bonus exercise, answering the recurring student request to "snarf a Google review page and classify the reviews." It does the classify/filter/summarise half honestly — over a fixture — and is upfront about *why* we don't scrape Google itself. Builds directly on Bonus B1.

## Learning goal

By the end students should:

- Run an **LLM classifier once per row** (Basic LLM Chain over a Split Out stream).
- Write a **narrow one-word classifier prompt**, and see that the narrowness is exactly what lets a downstream Filter/Switch act on it.
- Use a **cross-node reference** (`$('Split Reviews').item.json.review`) to recover a row's data after an LLM step rewrote the item — the most-missed trick in the course.
- Filter, aggregate, and summarise the flagged rows.
- Understand the limits of LLM sentiment (non-determinism, sarcasm) and cross-check against a structured signal (star rating).

## Domain

Ten customer reviews of a hawker stall (`author`, `rating`, `review`), deliberately mixed: clear positives, clear negatives, and one genuinely ambiguous "okay lah" (Hafiz) that flips between NEUTRAL and NEGATIVE across runs. Embedded in the Set node and shipped standalone as `sample-reviews.json`.

## Why we don't scrape Google (say this out loud)

Students ask for live Google reviews. The honest answer, on a sticky note in every variant:

1. **A plain HTTP fetch won't work** — Google Maps reviews are JavaScript-rendered; you get script, not text.
2. **Scraping them violates Google's ToS** — the supported path is the paid Google Places API.
3. **The lesson is source-independent** — classify/filter/summarise is the same regardless of where the rows came from.

Honest alternative offered in the notes: scrape a sandbox built for it (`books.toscrape.com`, `quotes.toscrape.com`) with the HTML Extract node, then feed the same pipeline.

## The three artefacts

| File | Use |
|---|---|
| `B2-a-blank.workflow.json` | Manual + Set Input (reviews given) + 4 sticky notes. Students build Split → Classify → Tag → Filter → Aggregate → Summarise. |
| `B2-b-half-built.workflow.json` | Full 8-node graph with 3 gaps: classifier prompt, filter value, summary prompt. (Tag Review's cross-node ref is given as a worked example.) |
| `B2-c-reference.workflow.json` | Working solution. Release at debrief. |

## Recommended session flow (~40 min)

1. **(3 min) Frame it.** "You wanted to classify Google reviews. Here's the catch about Google — and here's the part that's actually the skill." Walk the three reasons.
2. **(5 min) Per-row LLM.** Run the classifier over the Split stream; scroll the ten verdicts. This is the new idea vs B1.
3. **(20 min) Pair build.** Watch for chatty classifier prompts, `equals` vs `contains`, and pairs who skip Tag Review and lose the review text.
4. **(5 min) Non-determinism.** Re-run twice. Watch Hafiz flip. Discuss the star-rating cross-check.
5. **(5 min) Debrief + extension to a Switch** (routing over tabular data → Ex 04).

## The 3 gaps in variant B (answer key)

1. **Classify Sentiment → prompt** — one-word POSITIVE/NEGATIVE/NEUTRAL classifier over `{{ $json.review }}`.
2. **Keep Negative Only → rightValue** — `NEGATIVE`.
3. **Summarise Complaints → prompt** — 2-3 sentences over `$json.flagged`, what to fix first.

## Expected result

Four clear negatives (Marcus, Priya, Ahmad, Ben); recurring themes are wait time, hygiene, value-for-money. Hafiz is the deliberate borderline case.

## Common student errors

| Error | Lesson |
|---|---|
| Chatty classifier | Breaks the Filter. One capitalised word only. |
| Skips Tag Review's cross-node ref | Sentiments with no reviews attached. |
| `equals` not `contains` | Trailing newline fails `equals`. |
| Forgets Aggregate | Summariser fires once per row, not once total. |

## Threads

- **Requires the Split Out / Filter / Aggregate spine from Bonus B1.** Do B1 first.
- **The classifier** is Ex 04 / 02b-stage-3, applied to a list.
- **Switch extension** = Ex 04 routing over tabular data.

## Import instructions

n8n → **Workflows → top-right menu → Import from File** → pick a `.json`. Confirm the Ollama Chat Model has the `Ollama (local)` credential.

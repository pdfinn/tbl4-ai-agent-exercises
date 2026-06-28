# Bonus B2 — Classify Reviews, Then Filter (Reference, annotated)

*For instructor debrief. Release after pairs have built it.*

## The graph

```
Manual Trigger
  └─ Set Input (the reviews)     ← one item, a `reviews` array (10)
       └─ Split Reviews          ← Split Out: 1 → 10
            └─ Classify Sentiment ← Basic LLM Chain, one-word output
                 └─ Tag Review    ← Set: recovers row via $('Split Reviews').item + sentiment
                      └─ Keep Negative Only ← Filter: sentiment contains NEGATIVE
                           └─ Collect Complaints ← Aggregate: → `flagged`
                                └─ Summarise Complaints ← Basic LLM Chain

Ollama Chat Model ── ai_languageModel ──→ Classify Sentiment  AND  Summarise Complaints
```

## Why this shape

- **Per-row classification is the new idea.** B1 ran nodes over rows; B2 runs an *LLM* over rows. The Basic LLM Chain fires once per item — ten reviews, ten verdicts. Have students click Classify Sentiment and scroll the ten outputs.
- **Narrow output makes the Filter possible.** The classifier returns one capitalised word. That's the whole reason a downstream Filter (or Switch) can act on it. A discursive answer can't be routed. This is the slides' "workflow-agent prompt, not a chatbot prompt" made concrete.
- **Tag Review is the subtle lesson.** A Basic LLM Chain replaces the item with `{ text: ... }`, so the original review would be lost. `$('Split Reviews').item.json.review` reaches back to *the row that produced this verdict* — n8n keeps the pairing through the LLM. Without this, students get a list of sentiments with no idea which review each belongs to.
- **One Chat Model, two chains.** The same Ollama sub-node feeds both the classifier and the summariser via two `ai_languageModel` connections — same fan-out as Ex 03/04.

## The 3 gaps in variant B (answer key)

1. **Classify Sentiment → prompt** — a one-word POSITIVE/NEGATIVE/NEUTRAL classifier reading `{{ $json.review }}`. (Full text in the reference workflow.)
2. **Keep Negative Only → rightValue** — `NEGATIVE`.
3. **Summarise Complaints → prompt** — 2-3 sentence summary over `$json.flagged`, asking what to fix first.

## Expected result (with the fixture)

The clearly negative reviews are **Marcus T.** (cold food, long wait), **Priya** (hygiene — hair in food), **Ahmad R.** (overpriced, bland, soggy), and **Ben** (dirty tables, hygiene). That's **4 of 10**. Hafiz ("okay lah", prices crept up) is the ambiguous one — most runs call it NEUTRAL, some NEGATIVE. That borderline case is worth dwelling on: sentiment is not deterministic, and the star rating (Hafiz gave 3) is a useful cross-check. The summary should surface **wait time, hygiene, and value-for-money** as the recurring themes.

## Points to surface at debrief

1. **The LLM is non-deterministic; re-run and watch a borderline review flip.** This is a feature to design around, not a bug to hide. The `contains` operator and a star-rating cross-check are two ways to be robust to it.
2. **Sentiment vs stars can disagree.** Marcus gave 2 stars and the text is clearly negative — they agree. But invite students to imagine a sarcastic 5-star review. Which signal do you trust?
3. **Why not scrape Google?** Walk the three reasons (JS-rendered, ToS, paid API). Then show the honest alternative (toscrape sandbox + HTML Extract). Students respect being told the real constraint.

## Common student errors

| Error | Lesson |
|---|---|
| Chatty classifier prompt | "This is a negative review because…" breaks the Filter. One word only. |
| Skips Tag Review's cross-node ref | After the LLM, the review body is gone. You get sentiments with no reviews attached. |
| `equals NEGATIVE` instead of `contains` | A trailing newline from the model fails `equals`. `contains` + lowercase-insensitive is forgiving. |
| Forgets Aggregate | The summariser fires once per negative review instead of once over all of them. |

## Threads

- **Builds directly on Bonus B1** — same Split Out → Filter → Aggregate spine, plus a per-row LLM.
- **The classifier** is the Ex 04 / 02b-stage-3 classifier, applied to a list instead of one message.
- **Extension to a Switch** turns this into the Ex 04 routing pattern over tabular data.

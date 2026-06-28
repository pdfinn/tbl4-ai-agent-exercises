# Bonus B2 — Classify Reviews, Then Filter (Blank Starter)

Take a batch of customer reviews, have the LLM tag each with a sentiment, keep only the negative ones, and summarise what the owner should fix. It's Bonus B1's tabular spine with an **LLM classifier running once per row** in the middle — the most common "AI + data" shape there is.

## The pattern

```
Reviews → Split → Classify each (LLM, one word) → Tag → Keep negatives (Filter) → Collect → Summarise (LLM)
(1 item)  (10)    (10, one verdict each)            (10)   (fewer)                   (1)        (prose)
```

## Heads-up: we are not scraping Google

Students often ask for "snarf a Google reviews page." We deliberately don't, for three honest reasons:

1. **A plain fetch won't work** — Google Maps reviews are rendered by JavaScript, so an HTTP Request gets a page of script, not review text.
2. **It violates Google's Terms of Service** — the supported route is the paid Google Places API, which needs a billing-enabled key.
3. **The lesson is identical** whether the rows came from a scrape, an API, or this fixture.

If you want to practise real scraping *honestly*, point an HTTP Request at a sandbox built for it (`books.toscrape.com`, `quotes.toscrape.com`) and use the HTML Extract node — then run the rows through this same pipeline.

## What you've been given

- A **Manual Trigger**.
- A **Set node** with 10 reviews (`author`, `rating`, `review`) as a `reviews` array.
- Four sticky notes.

## Build it

1. **Split Out** — field `reviews`. Run it: 10 items.
2. **Basic LLM Chain ("Classify Sentiment")** + **Ollama Chat Model** — read `{{ $json.review }}`, output **one word**: `POSITIVE`, `NEGATIVE`, or `NEUTRAL`. No explanation, no punctuation. (Narrow output is the whole game — it's what the Filter routes on.)
3. **Set ("Tag Review")** — the LLM only returns `text`, so recover the row's data with a cross-node reference to the matching item:
   - `author` = `{{ $('Split Reviews').item.json.author }}`
   - `review` = `{{ $('Split Reviews').item.json.review }}`
   - `sentiment` = `{{ $json.text.trim() }}`
4. **Filter ("Keep Negative Only")** — keep rows where `sentiment` contains `NEGATIVE`.
5. **Aggregate ("Collect Complaints")** — into a field `flagged`.
6. **Basic LLM Chain ("Summarise Complaints")** — 2-3 sentences: recurring complaints, what to fix first. Feed in `{{ $json.flagged.map(r => '- ' + r.author + ': ' + r.review).join('\n') }}`.

## Rules

- **No Code node.**
- **One-word classifier.** A chatty classifier ("This review seems quite negative…") breaks the Filter. Narrow it.
- **Run after every node.** Read the verdicts in *Classify Sentiment* before you filter.

## Success

The classifier tags all 10 reviews; the Filter keeps the negatives; Aggregate returns one item; the summary names the recurring complaints (you'll see wait times, hygiene, and value-for-money recur).

## Extension — if you finish early

- **Route, don't just filter.** Swap the Filter for a Switch: POSITIVE → "thank-you draft", NEGATIVE → "service-recovery draft". That's the Ex 04 routing pattern.
- **Compare to the star rating.** Filter on `rating <= 2` instead. Where does the star rating disagree with the LLM's sentiment, and why?
- **Summarise the positives** into a one-line marketing blurb.

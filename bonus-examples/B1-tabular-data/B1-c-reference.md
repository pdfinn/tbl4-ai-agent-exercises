# Bonus B1 — Working with Tabular Data (Reference, annotated)

*For instructor debrief. Release after pairs have built it.*

## The graph

```
Manual Trigger
  └─ Set Input (the table)        ← one item, a `rows` array of 10 dishes
       └─ Split Into Rows         ← Split Out: 1 item → 10 items
            └─ Add Revenue Column ← Set: computed column revenue = price * units_sold
                 └─ Keep Strong Sellers  ← Filter: units_sold >= 40
                      └─ Sort By Revenue ← Sort: revenue descending
                           └─ Collect Rows ← Aggregate: 10→1, array field `top_dishes`
                                └─ Write Readout ← Basic LLM Chain (narrate only)

Ollama Chat Model ── ai_languageModel ──→ Write Readout
```

## Why this shape

- **Split Out is the lesson.** The jump from 1 item to 10 is where "one item = one row" lands. Have students click the node and read the panel before and after. Everything else is operations *on the list of rows*.
- **Computed column in a Set node.** `revenue = price * units_sold` runs once per item. This is how you add derived data in n8n without a Code node.
- **Filter vs IF.** The Filter node uses the *same condition editor* as the IF node — but it has no branches. Rows pass or vanish. Point this out: it's the IF they already know, minus the routing.
- **Aggregate is the inverse of Split Out.** It collapses many items back into one, with the rows in an array field. You need this before the LLM step, because a Basic LLM Chain runs once per *item* — without Aggregate it would fire once per surviving row and you'd get N tiny readouts instead of one.
- **The LLM narrates; it does not calculate.** The total is computed with `.reduce()` in the expression and handed to the model as a fact. This is the single most transferable habit in the exercise.

## The 3 gaps in variant B (answer key)

1. **Add Revenue Column → `revenue`** — `={{ $json.price * $json.units_sold }}`, type Number.
2. **Keep Strong Sellers → rightValue** — `40`.
3. **Write Readout → prompt** — any prompt that uses the two supplied expressions and instructs the model to narrate, not recompute. Example:
   > `=You are a sales analyst. Below are dishes that sold at least 40 units, sorted by revenue. The total is computed for you — do not recompute it.\n\nWrite 2-3 plain sentences for the stall owners: the top earner, any category pattern, and the total.\n\nTotal: ${{ $json.top_dishes.reduce((s,d)=>s+d.revenue,0) }}\n\nDishes:\n{{ $json.top_dishes.map(d => '- ' + d.dish + ' (' + d.stall + '): $' + d.revenue).join('\\n') }}`

## Expected result (with the fixture)

Eight dishes survive the `units_sold >= 40` filter (Chendol at 38 and Ice Kacang at 29 are dropped). Sorted by revenue, the top earner is **Chicken Rice** ($660) — a nice teaching moment, because the *best-selling by units* is Teh Tarik (210 sold) but at $1.80 it earns only $378. Units sold ≠ revenue. The total across the eight survivors is **$2,985.50**.

## Points to surface at debrief

1. **Watch the item count.** `1 → 10 → 10 → 8 → 8 → 1`. The count *is* the data model.
2. **Units vs revenue.** The fixture is rigged so the unit-leader is not the revenue-leader. A good prompt and a good filter surface that; a sloppy "just ask the LLM" approach buries it.
3. **Why Aggregate before the LLM.** Remove it and re-run: the chain fires per row. Demonstrate the failure, then fix it. (Build, break, repair.)

## Common student errors

| Error | Lesson |
|---|---|
| Leaves `revenue` as type String | The Sort then orders lexicographically ("510" < "85"). Types matter. |
| Forgets Aggregate; wires Sort straight to the LLM | The chain runs 8 times. One readout per row, none of them complete. |
| Asks the LLM to compute the total | It will sometimes be wrong. Compute with `.reduce()`, hand it the answer. |
| Uses `units_sold` for "best dish" | Best by units ≠ best by revenue. Read what the question asks. |

## Threads back to the core course

- **Split Out / Aggregate** are exactly the nodes Ex 07 (Research Agent) uses to fan Wikipedia hits out and back in. This exercise isolates them on a tiny canvas.
- **Filter** is the IF node from the 02b warm-up with the branches removed.
- The "LLM narrates, nodes compute" rule is the data-side complement to Ex 03's "gate decides, LLM drafts."

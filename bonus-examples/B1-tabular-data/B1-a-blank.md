# Bonus B1 — Working with Tabular Data (Blank Starter)

n8n is, at heart, a tool for moving tables around. Every node passes a **list of items** to the next, and the rule to keep in your head is: **one item = one row.** This exercise builds the standard "load → reshape → filter → summarise" pipeline that almost every data automation is made of.

## The pattern

```
The table → Split into rows → Add a revenue column → Filter strong sellers → Sort by revenue → Collect rows → LLM readout
 (1 item)    (10 items)         (computed column)       (fewer items)          (sorted)           (1 item)      (prose)
```

## What you've been given

- A **Manual Trigger**.
- A **Set node** ("Set Input (the table)") holding a 10-row table of hawker-stall sales as a `rows` array. Run the workflow once and click it — you'll see one item with an array inside.
- Four sticky notes (pattern, build steps, rules, extension).

You build the pipeline from Split Out onward.

## Your goal

Turn the raw table into a short readout: which dishes sold well, sorted by revenue, with a total — written as 2-3 plain sentences by the LLM.

## Build it

1. **Split Out** — field to split out: `rows`. Run it. The item count should jump from 1 to **10**. This is the single most important idea in the exercise: read the output panel and watch the count change.
2. **Set ("Add Revenue Column")** — add a *number* field `revenue` = `{{ $json.price * $json.units_sold }}`. Carry `dish`, `stall`, `category`, `units_sold` through as well.
3. **Filter** — keep rows where `units_sold` is at least 40. Same condition editor as the IF node, but there are no branches: a row either passes or disappears.
4. **Sort** — by `revenue`, descending.
5. **Aggregate** — *Aggregate All Item Data* into a field named `top_dishes`. This collapses the many rows back into **one** item, so the LLM can see them all at once.
6. **Basic LLM Chain ("Write Readout")** + **Ollama Chat Model** — narrate the result.

## Rules

- **No Code node.** Split Out / Set / Filter / Sort / Aggregate cover everything.
- **Do the arithmetic in nodes, not the LLM.** Compute `revenue` and the total with expressions. Ask the LLM only to *describe* the numbers. An LLM asked to sum a column will occasionally get it wrong; a Set node never does. This is the whole point of the exercise.
- **Run after every node.** The item count tells the story: `1 → 10 → 10 → fewer → fewer → 1`.

## Feeding the array into the prompt (step 6)

After Aggregate, the rows live at `$json.top_dishes`. Useful expressions:

- Total: `${{ $json.top_dishes.reduce((s, d) => s + d.revenue, 0) }}`
- The list: `{{ $json.top_dishes.map(d => '- ' + d.dish + ': $' + d.revenue).join('\n') }}`

## Success

You execute the workflow. Split Out shows 10 items; the Filter drops the low sellers; Sort orders them by revenue; Aggregate returns a single item; the LLM writes a 2-3 sentence readout that names the top earner and states a total you computed (not one the LLM guessed).

## Extension — if you finish early

- **Group by category.** Total revenue per `category` (Main / Drink / Dessert). Which category earns most?
- **Swap in a real CSV.** Replace the Set node with an HTTP Request fetching a published Google Sheet as CSV (`.../export?format=csv`) and an Extract From File node (operation: CSV). The downstream pipeline is unchanged. (That's the bridge to Bonus B3 — Google Docs.)
- **Filter on text** instead of a number: keep only `category = Main`.

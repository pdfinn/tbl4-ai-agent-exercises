# Bonus B1 — Working with Tabular Data (Half-Built)

Seven nodes are on the canvas, fully wired. **Three fields are blank or set to a placeholder** — fill them in.

## Gap 1 — the computed column

The **Add Revenue Column** node has its `revenue` field blank. Each row has a `price` and a `units_sold`. Write the expression that multiplies them:

```
={{ $json.price * $json.units_sold }}
```

Leave the field type as **Number**. This is a *computed column*: the Set node runs once per row, so every row gets its own `revenue`.

## Gap 2 — the filter threshold

The **Keep Strong Sellers** node has its `rightValue` set to `0`, so every row passes (everything sold ≥ 0). Change it so the Filter keeps only dishes that sold **at least 40 units**.

It's a number, not a string. The left side (`{{ $json.units_sold }}`) and the operator (`is greater than or equal to`) are already set.

## Gap 3 — the readout prompt

The **Write Readout** node has a blank prompt. After the Aggregate node, all the surviving rows live in one item at `$json.top_dishes` (an array). Write a prompt that turns them into a 2-3 sentence readout for the stall owners.

Two expressions do the heavy lifting — paste them into your prompt:

- Total revenue: `${{ $json.top_dishes.reduce((s, d) => s + d.revenue, 0) }}`
- The dish list: `{{ $json.top_dishes.map(d => '- ' + d.dish + ': $' + d.revenue).join('\n') }}`

Tell the model the total is computed and must not be recalculated — its job is to *narrate*, not to do arithmetic.

## Everything else is already done

- Split Out is set to split `rows`.
- The Filter's left side and operator are correct.
- Sort is set to `revenue` descending.
- Aggregate collects everything into `top_dishes`.
- The Ollama Chat Model is connected to the Basic LLM Chain.

## Before you run

Click the **Ollama Chat Model** node and confirm the credential is `Ollama (local)`. (n8n sometimes drops the credential reference on import.)

## Rule

No Code node. Maths in expressions; the LLM only narrates.

## Extension — if you finish early

- Lower the Filter threshold to `0` again and watch the desserts reappear. Raise it to `100` and watch most of the table vanish. The output panel makes filtering visible.
- Add a second Aggregate that totals revenue per `category`.

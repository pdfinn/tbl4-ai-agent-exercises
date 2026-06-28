# Bonus B7 — Reference notes (bulk tender pricing from a database)

Two workflows:

- `B7-c-reference-offline.workflow.json` — **always runs.** Catalogue in a Set node; a Code node stands in for the query. The class file.
- `B7-c-reference.workflow.json` — **live**: a real **Postgres** node with a parameterised query. Run `schema.sql` first.

## The shape both share

```
Request (code + qty) → Look up (DB / Code) → Apply tier pricing → found? → Write quote (LLM narrates) → Quote
                                                                     └ no → Not found
```

The only difference between the two files is the **lookup node**. The deterministic pricing, the found? gate, and the LLM-narrates-only discipline are identical.

## Why this is not RAG

A price is structured and exact; "relevance" doesn't enter into it. You don't want the *most similar* row, you want *the* row, and then exact arithmetic. So: query the DB, compute in code, let the LLM phrase. If you ever see a tutorial "embed your product catalogue and ask the LLM for the price," that's the wrong tool — it will hallucinate prices and you can't audit it.

## The pricing logic

`bulk_tiers` is a list of `{ min_qty, discount_pct }` ascending. The applied discount is the **highest tier whose `min_qty` the order quantity meets**. For 100 × ABC1233-019: tiers are 50→8%, 100→12%, 500→18%; qty 100 meets the 100 tier → **12%**. List 12.50 → net 11.00 → line total 1,100.00, saving 150.00 SGD. The LLM is handed those numbers and told not to change them.

## Live: Postgres specifics

- **Parameterised query.** `WHERE product_code = $1` with the value bound via the node's query-replacement — never string-concatenated. This is the SQL-injection defence and it's mandatory once any user/LLM input reaches the query.
- **`bulk_tiers` is JSONB.** The Code node `JSON.parse`s it if the driver returns a string.
- **Run `schema.sql` first** — it creates the table, loads the four products, and makes a **read-only** `n8n_readonly` role. Point the n8n Postgres credential at that role, not a superuser.

## Security & data governance — the student's real question

| Concern | Practice |
|---|---|
| Where do DB creds live? | n8n's encrypted credential store (`N8N_ENCRYPTION_KEY`), never in a prompt/expression. Back up the key. |
| SQL injection | Parameterised queries only. Never build SQL by concatenating input. |
| Over-broad access | Least privilege: a `SELECT`-only role on the one table. A pricing lookup never writes. |
| LLM sees too much | Pass only the one priced row to the model — no catalogue dump, no PII. Local Ollama keeps even that on-prem. |
| Cloud n8n ↔ internal DB | The DB isn't public. Use VPN / private networking / IP allowlist, or self-host n8n inside the network. |
| Auditability | Log customer, code, qty, price, timestamp for every quote. |
| Writes (placing orders) | Gate behind human approval; separate, more-privileged credential; never let the LLM trigger a write unreviewed. |
| Per-rep data boundaries | Row-level security so a rep prices only their own accounts. |

## The agent / Text-to-SQL alternative (mention, don't default to)

You *can* hand an AI Agent a "query the products DB" tool and let it write SQL from natural language. It's flexible but riskier: generated SQL can be wrong or injectable, and the model can hallucinate columns. For **pricing**, prefer the deterministic shape here. If you do use an agent, keep it to a **read-only** connection, allow-list the queryable views, and still compute the final price in code — never trust a model's arithmetic on money.

## Common student errors

| Error | Lesson |
|---|---|
| LLM "calculates" the total | Forbid arithmetic in the prompt; compute in the node and pass numbers in. |
| SQL built by concatenation | Use bound parameters (`$1`); concatenation is an injection hole. |
| n8n connects as superuser | Least privilege — a SELECT-only role is enough. |
| No not-found branch | A bad code silently yields an empty quote. Gate on `found`. |
| Floats drift (e.g. 11.000000001) | Round once, at compute time (`toFixed(2)` → Number), not in the prose. |

## Import instructions

n8n → **Workflows → top-right menu → Import from File**. Confirm the Ollama Chat Model has the `Ollama (local)` credential after import. The **offline** file runs as-is. For the live file: run `schema.sql`, create a Postgres credential pointing at the read-only role, and set it on the *Query Customer Product DB* node.

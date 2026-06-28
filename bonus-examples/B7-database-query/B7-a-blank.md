# Bonus B7 — Bulk tender pricing from a database (Blank Starter)

Your classmate asked: *"I want to check product bulk tender pricing for 100 Qty for product code ABC1233-019 (Customer Product DB). Is this easily implemented in n8n? What about credentials, security, and data governance — and can it run in the cloud?"*

Short answers: **yes, it's easy and it's a great fit for n8n** — and it is *not* a RAG problem. The rest is the security/governance discipline, which the README covers in full.

## The key idea: don't RAG a database — query it

RAG (Bonus B6) is for **unstructured** documents where "relevance" is fuzzy. A price is **structured and exact** — there's one right answer and it must be auditable. So:

- The **database** is authoritative. You run a **parameterised query** to fetch the row.
- The **price is computed** deterministically (the bulk-discount tier for that quantity).
- The **LLM only writes the quote** — it must not touch a number. A model that "calculates" a price will eventually calculate a wrong one.

This is the course's refrain again: **nodes compute, the LLM narrates.**

## What you'll build (offline shape — always runs)

```
Request (code + qty) → Look up + price → found? → Write quote (LLM) → Quote
                                            └ no → Not found
```

The catalogue lives in a Set node (the offline stand-in for the DB). Going live means swapping the Code lookup for a **Postgres** node — same downstream.

## Build it

1. **Set ("Incoming Request + Catalogue")** — an object `request` with `product_code` (`"ABC1233-019"`), `qty` (`100`), `customer`; and an array `catalogue` (paste `sample-products.json`).
2. **Code ("Look Up + Price")** — find the product by `product_code`. If not found, return `{ found: false, ... }`. Otherwise pick the **highest bulk tier whose `min_qty` the order meets**, then compute `net_unit_price`, `line_total`, and `total_savings`. Flag `below_min_order_qty`.
3. **IF ("Product found?")** — `{{ $json.found }}` true → quote branch; false → not-found branch.
4. **Basic LLM Chain ("Write the Quote")** + **Ollama Chat Model** — narrate the figures into a short professional quote. Rule, in capitals: **do NOT recalculate or change any number.**
5. **Set ("Quote")** and **Set ("Not Found Message")** — the two outcomes.

## Rules

- **The LLM does no arithmetic.** Every number is computed in the Code node (or the DB) and passed in. The prompt forbids recalculation.
- **Branch on the lookup.** A missing product code is a real case — handle it, don't let it reach the LLM as an empty quote.
- **Model:** `llama3.1:8b`. **Credential:** `Ollama (local)`.

## Success

You run the workflow and get a clean tender quote for 100 × ABC1233-019 — list price, the 12% bulk tier applied, net unit price, line total, and the saving — every figure computed by a node, only the wording from the LLM. Change the code to a non-existent one and you get the not-found message instead.

## Then read the README

It answers the security questions directly: where credentials live, why parameterised queries are non-negotiable, least-privilege DB users, data governance for customer pricing, and whether cloud n8n can reach an internal database. The live Postgres version is `B7-c-reference.workflow.json` with `schema.sql`.

## Extension — if you finish early

- **Go live.** Run `schema.sql` against a local Postgres, then swap the Code lookup for the **Postgres** node with a parameterised `WHERE product_code = $1`.
- **Quote several lines.** Feed an array of `{code, qty}`, Split Out, price each, Aggregate, and have the LLM write a multi-line tender.
- **Natural-language in.** Add an LLM step that *parses* "100 of ABC1233-019" into `{product_code, qty}` — but keep the pricing deterministic. (See the README on the agent/Text-to-SQL pattern and its risks.)

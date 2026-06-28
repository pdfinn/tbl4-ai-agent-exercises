# Bonus B7 — Bulk tender pricing from a database

*Instructor-facing overview. Student-facing instructions are in `B7-a-blank.md`; solution notes in `B7-c-reference.md`.*

A standalone bonus answering a student's question almost verbatim:

> *"Querying from a database. User asks: 'I want to check product bulk tender pricing for 100 Qty for product code ABC1233-019 (Customer Product DB)'. Is it easily implemented using n8n? Other security considerations like creating credentials, security and data governance in place — is it easily implemented using n8n in the cloud? Are these possible?"*

The headline lesson sits right next to Bonus B6: **B6 is unstructured documents (RAG); B7 is structured data (query it, don't RAG it).** Teaching them together shows students how to pick the right tool for the shape of their data.

## The student's questions, answered plainly

**"Is it easily implemented in n8n?"** — Yes, and it's a *better* fit for n8n than the RAG case. The graph is small: take the request, run one parameterised query, compute the bulk-tier price, let the LLM write the quote. The offline file runs with zero setup; the live file is the same graph with a Postgres node in place of the Code lookup.

**"Is this a RAG problem?"** — No, and that's the most important point. A price is structured and exact; you want *the* row and exact arithmetic, not the *most similar* chunk. Embedding a product catalogue and asking an LLM for the price is the wrong tool — it hallucinates and can't be audited. **Query the DB, compute in a node, let the LLM only narrate.**

**"Security — creating credentials, is that possible?"** — Yes. n8n has an **encrypted credential store**; DB credentials are entered once on the Postgres node and encrypted at rest with `N8N_ENCRYPTION_KEY`. They never appear in a prompt, an expression, or the workflow JSON. (Back up that key — losing it makes every credential unreadable.)

**"Security and data governance in place?"** — Yes, and this is the substance of the exercise (full table below):
- **Parameterised queries** (`WHERE product_code = $1`) — the SQL-injection defence, mandatory once an LLM or user influences input.
- **Least privilege** — n8n connects as a `SELECT`-only role on the one table (`schema.sql` creates it). A pricing lookup never needs write access.
- **Minimal LLM exposure** — only the single priced row reaches the model; with local Ollama it never leaves the network.
- **Audit + approval gates** — log every quote; gate any *write* (placing an order) behind human review.

**"Easily implemented in n8n in the cloud?"** — The workflow logic, yes. The wrinkle is *reaching an internal database from cloud n8n*: the DB usually isn't public, so you need VPN / private networking / an IP allowlist — or you self-host n8n inside the network. **Many enterprises self-host n8n precisely so customer pricing data never transits a third party.** Same governance instinct as B6.

## Learning goal

By the end students should be able to:

- Decide **query vs RAG** from the shape of the data (exact/structured → query; fuzzy/unstructured → RAG).
- Build **nodes-compute-LLM-narrates** for anything involving money: deterministic price in a node, prose in the LLM.
- Write a **parameterised** DB query and explain why concatenation is unsafe.
- State the credential, least-privilege, governance, and cloud-vs-self-host considerations for an internal DB.
- Handle the **not-found** branch instead of emitting an empty quote.

## Domain

A four-row Customer Product DB of electrical-trade SKUs, each with a list price and a bulk-discount tier table. The student's exact request — 100 × `ABC1233-019` — lands on the 100-unit tier (12% off): list 12.50 → net 11.00 → 1,100.00 SGD, saving 150.00. Shipped as `sample-products.json` (offline) and `schema.sql` (live Postgres).

## The artefacts

| File | Use |
|---|---|
| `B7-a-blank.workflow.json` | Manual Trigger + 2 sticky notes. Students build Set → Code → IF → LLM → Set. |
| `B7-c-reference-offline.workflow.json` | **Always runs.** Catalogue in a Set node; Code node stands in for the query. The class file. |
| `B7-c-reference.workflow.json` | **Live.** Postgres node with a parameterised query + a big security sticky note. |
| `sample-products.json` | The four products (offline source). |
| `schema.sql` | Creates the table, loads the rows, and makes a read-only `n8n_readonly` role. |

> Note: this folder ships `a-blank` + `c-reference` + offline (no `b-half-built`). Ask if you'd like the half-built gap-fill variant added to match B1–B4.

## Recommended session flow (~35 min)

1. **(5 min) Query vs RAG.** Put B6 and B7 side by side. "Why not embed the price list?" → because a price is exact and auditable. Establish *nodes compute, LLM narrates*.
2. **(12 min) Build the offline shape.** Set → Code (lookup + tier pricing) → IF (found?) → LLM (narrate) → Quote. Insist the prompt forbids arithmetic; show what the figures are before the LLM runs.
3. **(5 min) Break it.** Let the LLM compute the total (drop the figures, ask it to "work out the price"); watch it drift. Restore deterministic pricing.
4. **(8 min) The security walk-through.** Open the live file's security sticky note and `schema.sql`. Parameterised query, read-only role, encrypted creds, minimal LLM exposure, cloud-vs-self-host.
5. **(5 min) Governance debrief.** Audit logging, approval gates for writes, row-level security, where the data is allowed to go.

## Security & data governance — the full table

| Concern | Practice in this exercise |
|---|---|
| Credential storage | n8n encrypted store (`N8N_ENCRYPTION_KEY`); never in prompts/expressions/JSON. Back up the key. |
| SQL injection | Parameterised query (`$1`), never concatenation. Non-negotiable once input is model/user-driven. |
| Least privilege | `n8n_readonly` role: `SELECT` on `products` only (`schema.sql`). No write grants. |
| LLM data exposure | Only the one priced row reaches the model. Local Ollama → never leaves the machine. |
| Cloud n8n ↔ internal DB | DB isn't public: VPN / private networking / IP allowlist, or self-host n8n in-network. |
| Auditability | Log customer, code, qty, price, timestamp per quote. |
| Writes / orders | Human-approval gate; separate higher-privilege credential; no unreviewed LLM-triggered writes. |
| Per-user boundaries | Row-level security so reps price only their own accounts. |

## The agent / Text-to-SQL alternative

You *can* give an AI Agent a "query the DB" tool and let it author SQL from natural language — flexible, but riskier (wrong/injectable SQL, hallucinated columns). For **pricing**, prefer the deterministic shape here. If you must use an agent: read-only connection, allow-listed views only, and still compute the final price in code. Never trust a model's arithmetic on money. Covered in `B7-c-reference.md`.

## Threads

- **Pairs with Bonus B6** — the query-vs-RAG decision is the whole reason to teach them together.
- **Routing/gate from Ex 04 and Bonus B4** — the found? IF node is the same branch-on-a-predicate shape.
- **Nodes-compute-LLM-narrates** — the same discipline as B1 (totals), B4 (dates), and B6 (citations): the LLM never owns a number it could get wrong.

## Import instructions

n8n → **Workflows → top-right menu → Import from File**. Confirm the Ollama Chat Model has the `Ollama (local)` credential after import. The **offline** file runs as-is. For the live file: run `schema.sql` against a Postgres, create a Postgres credential on the read-only role, and set it on the *Query Customer Product DB* node.

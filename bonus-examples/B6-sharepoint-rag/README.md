# Bonus B6 — Query SharePoint proposals with RAG

*Instructor-facing overview. Student-facing instructions are in `B6-a-blank.md`; solution notes in `B6-c-reference.md`.*

A standalone bonus answering a student's question almost verbatim:

> *"Querying from SharePoint documents — RAG (I assume it's using RAG) as a local private copy in the company enterprise. User asks: 'please help me to analyse past PDF proposals by comparing country-stability constraints, impact metrics?' Is it a user question posting to a KB — Deep Research Model? Is it easily implemented using n8n in the cloud?"*

This exercise teaches what RAG actually is, builds a runnable version with zero setup, and is honest about what the *real* SharePoint version costs.

## The student's questions, answered plainly

**"Is it using RAG?"** — Yes. The proposals are too many/long to paste into a prompt, so you **retrieve** the relevant excerpts from an indexed copy and feed only those to the LLM. That's Retrieval-Augmented Generation. The alternative — fine-tuning a model on your proposals — is slower, costlier, can't cite sources, and goes stale the moment a proposal changes. For "answer questions over our documents," RAG is the right tool.

**"Is it a user question posting to a KB — Deep Research Model?"** — Yes, that's a fair mental model, with one split worth making explicit:
- The **KB** is the private, in-company copy of the documents, *indexed for search* (chunked + embedded into a vector store). "Posting a question to the KB" = embed the question, retrieve the closest chunks. The SharePoint library is the *source*; the vector index is the *KB*.
- **"Deep Research"** is the *synthesis* layer on top — comparing several proposals, weighing risk against impact, writing it up. That's the same multi-document synthesis as **Exercise 07** (the research agent), except grounded in your private docs instead of Wikipedia. So: **RAG retrieves; the Deep-Research step reasons.** Same two-part shape as Ex 07.

**"Is it easily implemented using n8n in the cloud?"** — Two honest halves:
- **The RAG mechanics:** yes, easily. n8n ships document loaders, text splitters, embeddings, and vector-store nodes. The graph is small (see `B6-c-reference.workflow.json`).
- **The SharePoint connection:** *not* like the published Google Doc in Bonus B3. SharePoint Online is reached through the **Microsoft Graph API**, which needs an **Azure AD app registration** (tenant + client ID, a secret, `Sites.Read.All`/`Files.Read.All` with admin consent). That's a one-time IT task, not a paste-a-URL trick — set expectations accordingly.
- **Cloud vs self-hosted n8n:** SharePoint *Online* + Graph is internet-facing, so n8n Cloud can reach it fine. But note the data-governance reality (below): many enterprises self-host n8n *and* the LLM so private proposals never leave the network. If the company runs **on-prem SharePoint Server** (not Online), cloud n8n can't see it without a VPN/gateway.

## Learning goal

By the end students should be able to:

- Explain RAG as **ingest (chunk → embed → store)** then **query (embed → retrieve top-k → ground the LLM)**.
- Recognise that the **KB is the indexed copy**, and the **comparison/judgement is a separate synthesis step** (same shape as Ex 07).
- Build the retrieve-then-ground shape that always runs (Code-node stand-in for the vector search).
- Know exactly what the live SharePoint version needs (Azure app registration, an embedding model, a persistent vector store).
- Spot the **top-k vs "compare ALL"** trap and the metadata-filter / map-reduce fixes.

## Domain

Five fictional development-aid proposals across Kenya, DRC, Vietnam, Nigeria, and Indonesia — each with an explicit **political-security risk rating** and **impact metrics**, so the student's exact question (compare stability constraints against impact) has a real answer. Shipped as `sample-proposals.json` (full text) and trimmed into the offline workflow's Set node.

## The artefacts

| File | Use |
|---|---|
| `B6-a-blank.workflow.json` | Manual Trigger + 2 sticky notes. Students build Set → Code (retrieve) → LLM → Set. |
| `B6-c-reference-offline.workflow.json` | **Always runs.** Proposals in a Set node; Code node stands in for vector search. The class file. |
| `B6-c-reference.workflow.json` | **Live shape.** SharePoint (Graph) → PDF→Text → vector store → retrieve → LLM. Needs Azure + an embed model; read it, don't expect one-click. |
| `sample-proposals.json` | The five proposals in full. |

> Note: this folder ships `a-blank` + `c-reference` + offline (no `b-half-built`). Ask if you'd like the half-built gap-fill variant added to match B1–B4.

## Can n8n really do this? — the full answer (the three tiers, B3-style)

Reaching the documents, easiest first:

1. **Published / link-shared file URL (B3's trick).** Works for a *single* Google/Office doc you control. Does **not** generalise to "a SharePoint library of 200 proposals" — there's no public export URL for a whole library. So for this use-case, skip it.
2. **Microsoft Graph API (this exercise).** Azure app registration, app permissions, admin consent. Lists the library, downloads each PDF. The right tool for SharePoint Online. One-time setup, then fully automatable (Schedule Trigger to re-ingest nightly).
3. **Microsoft 365 / SharePoint n8n node or OneDrive node.** Wraps Graph behind a credential UI — same Azure registration underneath, less hand-rolled HTTP. Use it once the registration exists.

Lead with #2 conceptually (so they understand what the node hides), then point at #3 for production.

## Recommended session flow (~40 min)

1. **(5 min) What is RAG, and why not just paste the PDFs?** Context limits, cost, no citations, staleness. Draw ingest vs query.
2. **(15 min) Build the offline shape.** Set → Code retriever → grounded LLM → Answer. Insist they read `context` before writing the prompt, and enforce `proposal_id` citations.
3. **(5 min) Break it.** Remove the "use ONLY the context" rule; watch the model invent a plausible metric. Restore it. That's the whole point of grounding.
4. **(10 min) The live shape + the three questions.** Walk `B6-c-reference.workflow.json`; explain Azure app registration; answer "is it RAG / KB / cloud" using the section above.
5. **(5 min) The top-k trap.** Their question is "compare ALL" — show why top-k can miss documents, and the metadata-filter / map-reduce fixes.

## The top-k vs "compare ALL" trap (the one real subtlety)

A *comparison across all proposals* is the weak spot of naive RAG: top-k is built to return the *few* most similar chunks, not *coverage*. At five proposals it's invisible; at 200 it silently compares 8 and ignores 192. Fixes: **metadata-filter then retrieve** (narrow to a year/country/sector first), **map-reduce** (summarise each proposal individually — Bonus B2's per-row pattern — then compare the summaries), or at minimum **state the scope** ("compared the 8 most relevant of 200"). Covered in `B6-c-reference.md`.

## Data governance — the part enterprises actually care about

Private proposals are confidential. The governance decisions, independent of the RAG mechanics:

- **Where does the text go at query time?** Each retrieved chunk is sent to the LLM. With **local Ollama** (this course's default) it never leaves the machine. With a cloud LLM, that's a deliberate data-egress decision needing sign-off.
- **Who can ask what?** RAG retrieval is blind to SharePoint permissions by default — if you index every proposal, anyone who can run the workflow can retrieve any chunk. Real deployments carry per-document ACLs into the vector store and filter by the asking user. Worth stating even if out of scope to build.
- **Where do the vectors live?** In-memory store = gone on restart and not access-controlled. A real private KB uses **Qdrant** (self-hostable in Docker, free) or **pgvector**, inside the company network.
- **Self-host the lot.** Many enterprises run n8n + Ollama + Qdrant on their own infrastructure precisely so proposals, embeddings, and prompts never transit a third party. (See Bonus B7 for the same governance theme on structured data.)

## Threads

- **Same two-part shape as Ex 07** (retrieve/research → synthesise/audit), grounded in private docs instead of Wikipedia.
- **Grounding discipline** is the same one Ex 03/06 enforce with a quality gate — here it's "cite the `proposal_id` or don't claim it".
- **Pairs with Bonus B7** — B6 is *unstructured* documents (RAG); B7 is *structured* data (query a DB, don't RAG it). Teach them together to show students which tool fits which data.

## Import instructions

n8n → **Workflows → top-right menu → Import from File**. Confirm the Ollama Chat Model has the `Ollama (local)` credential after import. Use the **offline** file in class — it runs with no Microsoft setup. The live file needs the Azure/Graph credential and `ollama pull nomic-embed-text` before it executes.

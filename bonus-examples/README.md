# Bonus / Useful Examples

Standalone, student-requested examples that sit alongside the core curriculum (00–07). They aren't part of the Session 4 pattern arc — pick whichever a class asks for. Each is **simple, direct, and illustrative** rather than impressive, and each reuses primitives the core exercises already teach.

Same stack and rules as the rest of the repo: **Ollama** (`llama3.1:8b`) + local Docker **n8n**, no paid services, no API keys, no web access required (B3's live variant fetches a public Google Doc; an offline variant is included). Most ship in the usual three forms — `B*-a-blank` (build it), `B*-b-half-built` (fix the gaps), `B*-c-reference` (solution) — plus a `README.md` with instructor notes. B6 and B7 ship `a-blank` + `c-reference` + an offline variant (no half-built yet).

## The seven

| # | Example | Teaches | New primitives | Builds on |
|---|---|---|---|---|
| **[B1](./B1-tabular-data/)** | Working with tabular data | One item = one row; load → reshape → filter → summarise | Split Out, computed columns, Filter, Sort, Aggregate | Ex 07's fan-out/in, isolated |
| ↳ | …live from a Google Sheet | same pipeline, fed from a shared Sheet (zero-auth CSV, like B3) | HTTP `export?format=csv`, Extract From File (CSV) | B1 + B3's shared-link trick |
| **[B2](./B2-review-classifier/)** | Classify reviews, then filter | LLM classifier per row; recover row data across an LLM step | Per-row LLM, cross-node `.item` reference | B1 + Ex 04 classifier |
| **[B3](./B3-google-docs/)** | Read a Google Doc | An "integration" is often just an HTTP fetch; the 3 Google auth tiers | HTTP export URL, text response, build-URL-from-input | Ex 00 / Ex 07 HTTP shape |
| **[B4](./B4-calendar-date-finder/)** | Check a date, else find an alternate | Routing/gate on a date predicate; date arithmetic | Luxon (`DateTime`, `.weekday`, `.plus`, `.toFormat`) | Ex 03 IF+converge, Ex 04 routing |
| **[B5](./B5-agent-memory/)** | An agent that remembers you | Memory = text in the prompt; persistence = a file read before / written after | **AI Agent node**, Read/Write Files (write), Convert to File, Continue On Error | B1 file handling + Ex 07 Ollama wiring |
| **[B6](./B6-sharepoint-rag/)** | Query SharePoint proposals with RAG | Retrieve-then-ground; the KB is the *indexed copy*; **query vs RAG** | Retriever (Code stand-in / vector store), grounded+cited LLM, Microsoft Graph (live) | Ex 07 retrieve→synthesise; B3 auth-tiers honesty |
| **[B7](./B7-database-query/)** | Bulk tender pricing from a database | Query structured data (don't RAG it); DB credentials, security & governance | Postgres parameterised query, least-privilege role, IF gate | B4 routing/gate; B1/B4 nodes-compute |

## Suggested order

**B1 → B2** is a genuine sequence: B2 drops a per-row LLM into B1's tabular spine. **B3** stands alone (and feeds B1 if pointed at a Sheet). **B4** stands alone and could equally live as a fourth stage of the 02b warm-up. **B5** stands alone — the natural "what about agents with memory?" follow-up, and the only bonus that uses the AI Agent node. **B6 → B7** are a pair worth teaching together: B6 is *unstructured* documents (RAG), B7 is *structured* data (query it, don't RAG it) — the contrast teaches students which tool fits which data.

## A theme across the set

Most of them hammer one habit worth naming explicitly in class:

> **Nodes compute; the LLM narrates.**

Revenue totals (B1), the filter decision (B1/B2), every date (B4), the bulk-tender price (B7), and source citations (B6) are produced deterministically by nodes — totals and discounts in expressions, the priced row from the database, the retrieved chunks from the index. The LLM is used only where judgement or wording is needed — sentiment (B2), grounded synthesis (B6), and human-readable replies (B1/B4/B7). An LLM asked to do arithmetic, calendar maths, or to recall an exact price will eventually be wrong; a node won't.

## The Google question, answered once

B3 spells it out, but for quick reference — the local Docker n8n **can** reach Google, three ways:

1. **Published export URL** — zero credentials, read-only. `…/export?format=txt` (Docs) or `?format=csv` (Sheets). Best for getting data *in*; this is what B3 uses.
2. **Service Account** — download a JSON key, paste into an n8n Google credential, share the doc with the service-account email. No browser consent. Use this to **write**.
3. **OAuth2** — full consent screen + redirect to `http://localhost:5678/rest/oauth2-credential/callback`. Most capable, most setup; overkill for intro.

Lead intro students with #1.

## Import

n8n → **Workflows → top-right menu → Import from File** → pick a `.json`. After import, confirm the **Ollama Chat Model** node has the `Ollama (local)` credential.

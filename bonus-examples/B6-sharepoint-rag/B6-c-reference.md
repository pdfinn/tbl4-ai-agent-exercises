# Bonus B6 — Reference notes (RAG over SharePoint proposals)

Two workflows ship the solution:

- `B6-c-reference-offline.workflow.json` — **always runs.** Proposals in a Set node; a Code node stands in for the vector search. Use this in class.
- `B6-c-reference.workflow.json` — the **live shape**: SharePoint via Microsoft Graph → embed → vector store → retrieve → LLM. Needs an Azure app registration and an embedding model; it's there to read, not to one-click run.

## The shape both share

```
Question → Retrieve the most relevant proposal excerpts → LLM answers grounded ONLY on them, cited → Answer
```

The only thing that changes between offline and live is **how retrieval works** and **where the documents come from**. The grounding-and-citing discipline is identical.

## Offline: how the Code retriever works

It tokenises the question, drops stop-words, and scores each proposal by how many query terms appear in its text. It sorts by score and keeps `TOP_K`. With a *comparison* question over five proposals, `TOP_K = 5` returns the whole corpus — which is correct here, and is also the lesson: plain top-k is the wrong default for "compare ALL of X" (see below).

To go semantic without SharePoint: replace the Code node with **Vector Store (In-Memory, retrieve)** + **Ollama Embeddings** (`ollama pull nomic-embed-text`), keeping the Set-node source. That's real RAG on local data with no Microsoft setup at all.

## Live: what each phase needs

**Phase 1 — Ingest (one-time / scheduled).** SharePoint is reached through the **Microsoft Graph API**, which requires an **Azure AD app registration** (tenant + client ID, a client secret, `Sites.Read.All`/`Files.Read.All` with admin consent). The two HTTP nodes list the document library and download each PDF; **Extract From File** turns the binary into text; the **Vector Store (insert)** chunks, embeds, and stores. Run nightly with a Schedule Trigger to keep the KB fresh.

**Phase 2 — Query.** The question is embedded with the **same** model used at ingest, the **Vector Store (retrieve)** returns top-k chunks, **Aggregate** stitches them, and the LLM answers grounded + cited.

## The one nuance worth teaching: top-k vs "compare ALL"

The student's question — *compare all past proposals* — is exactly where naive RAG underperforms. Top-k retrieval is built to find the *few* most relevant chunks; "compare everything" wants *coverage*, not the top few. If the KB held 200 proposals, `topK = 8` would silently compare 8 and ignore 192. Three honest fixes:

1. **Metadata filter, then retrieve** — narrow to `year = 2024` or `sector = Health` first, so top-k operates on a set small enough to be complete.
2. **Map-reduce** — summarise each proposal individually (one LLM call each, like Bonus B2's per-row pattern), then compare the summaries. Scales to any corpus size.
3. **Retrieve, but tell the user the scope** — "Compared the 8 most relevant of 200; refine by country to widen." Never let top-k masquerade as "all".

This is the difference between a demo and something a colleague can trust.

## Common student errors

| Error | Lesson |
|---|---|
| LLM invents a metric not in the context | Grounding rule wasn't enforced; require a `proposal_id` citation on every claim. |
| Different embed model at ingest vs query | Vectors aren't comparable; retrieval returns noise. Pin one model. |
| Expects "compare all" from top-k | Top-k finds the *few* most similar; use a metadata filter or map-reduce for coverage. |
| Tries to publish-share SharePoint like B3's Doc | SharePoint isn't a public export URL; it's Graph API + Azure app registration. |
| Cloud n8n "can't see" on-prem SharePoint Server | Graph (SharePoint Online) is internet-facing and fine; *on-prem* SharePoint needs a gateway/VPN. |

## Import instructions

n8n → **Workflows → top-right menu → Import from File**. Confirm the Ollama Chat Model has the `Ollama (local)` credential after import. The offline file runs as-is. The live file needs the Microsoft credential and `nomic-embed-text` before it will execute.

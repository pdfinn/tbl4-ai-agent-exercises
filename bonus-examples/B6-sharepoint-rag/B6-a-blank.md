# Bonus B6 — Query SharePoint proposals with RAG (Blank Starter)

Your classmate asked: *"Please help me analyse past PDF proposals by comparing country-stability constraints and impact metrics"* — over a private, in-company copy of documents kept in **SharePoint**. Is that RAG? Is it a question posted to a knowledge base? Is it easy to do in n8n in the cloud?

Short answers: **yes it's RAG, yes the KB is the private SharePoint copy, and yes n8n can do it** — but SharePoint is a *real* integration (Azure app registration), not a zero-auth URL like the Google Doc in B3. This exercise builds the RAG *shape* so the moving parts are clear; the README answers the three questions in full.

## What RAG is (in one breath)

You can't paste 200 proposals into a prompt. So:

```
Ingest (once):  documents → split into chunks → embed → store the vectors   ← the "KB"
Query (each Q): question → embed → retrieve the most similar chunks → LLM answers grounded on them
```

The LLM only ever sees the handful of chunks that matched. That's why answers can cite a source and why they don't drift into made-up numbers.

## What you'll build here (offline shape — always runs)

```
Question + KB → Retrieve top-k → Compare (LLM, grounded + cited) → Answer
```

We mock two things so it runs with **nothing to install**:

- **The source.** Instead of SharePoint, a Set node holds five proposal excerpts — "the private local copy of the KB".
- **The retriever.** Instead of a vector store + embedding model, a Code node ranks by keyword overlap. Same *shape*: retrieve, then ground.

## Build it

1. **Set ("Load KB + Question")** — a string `question` and an array `proposals`. Paste `sample-proposals.json`, or the trimmed excerpts from the reference.
2. **Code ("Retrieve Relevant Proposals")** — tokenise the question, score each proposal by keyword overlap, sort, keep the top-k, and build a `context` string of the survivors. Return `{ question, retrieved, context }`.
3. **Basic LLM Chain ("Compare Proposals")** + **Ollama Chat Model** — answer using ONLY `context`. Rules: cite every claim with its `proposal_id`; output a Markdown table (Proposal | Country | Political-security risk | Headline impact metric) then a 3–4 sentence risk-vs-impact judgement; if the context is insufficient, say so.
4. **Set ("Answer")** — `answer` = `{{ $json.text }}`.

## Rules

- **Ground the LLM.** It must answer from `context` only and cite `proposal_id`. No outside knowledge, no invented metrics.
- **Nodes retrieve, the LLM reasons.** Selecting which proposals are relevant is deterministic work for the Code node; comparing them is the LLM's job.
- **Model:** `llama3.1:8b`. **Credential:** `Ollama (local)`.

## Success

You ask the comparison question and get back a cited table ranking the proposals by political-security risk against their impact metrics — every figure traceable to a `proposal_id` in the KB.

## Then read the README

It answers your classmate's three questions, explains why a *cross-proposal comparison* is a weak spot for plain top-k RAG (and what to do instead), and shows the live SharePoint + vector-store workflow (`B6-c-reference.workflow.json`).

## Extension — if you finish early

- **Go semantic.** Swap the Code node for n8n's **Vector Store (In-Memory)** in retrieve mode + an **Ollama Embeddings** node (`ollama pull nomic-embed-text`). Same downstream LLM.
- **Add a metadata filter.** Restrict retrieval to `year >= 2024` or `country == "Nigeria"` before ranking — the fix for "compare ALL of X" questions.
- **Cite with confidence.** Have the LLM append a "Sources" list of the `proposal_id`s it actually used, and compare against `retrieved`.

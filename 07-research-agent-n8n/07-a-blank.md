# Exercise 07 — Research Agent (Blank Starter)

The integration exercise. You will combine **all four workflow patterns** from Session 4 into one working workflow.

## The shape

```
Topic
  ↓
Generate Query (LLM)              ← Chaining
  ↓
Wikipedia Search (HTTP)
  ↓
Split Hits → Fetch Summary × N    ← Parallel-ish (Wikipedia returns N hits)
  ↓
Aggregate Sources
  ↓
Synthesise Briefing (LLM)         ← Chaining (IC analytic style)
  ↓
Audit Briefing (LLM, against policies)   ← Evaluator
  ↓
Audit Clean? (IF gate)            ← Routing
  ├─ pass ─→ Final (Approved)
  └─ fail ─→ Revise (LLM) → Final (Revised)   ← Optimiser
```

All four patterns. One workflow. Real research and real policy enforcement.

## What you've been given

- A **Manual Trigger** node.
- Five sticky notes describing the pattern, the three sub-systems, the policies, the rules, and an extension.
- The folder `policies/` containing four simplified ICD documents in slide-style XML.

## Build in three sub-systems

### A. Research (top-left of canvas)

1. **Set Input** — a `topic` field. Default: "Singapore hawker culture and UNESCO recognition".
2. **Generate Query** (Basic LLM Chain) — outputs ONE Wikipedia search query, max 8 words, no quotes.
3. **Wikipedia Search** (HTTP Request):
   - URL: `https://en.wikipedia.org/w/api.php`
   - Query params: `action=query`, `format=json`, `list=search`, `srsearch={{ $json.text.trim() }}`, `srlimit=3`
   - **Headers** (required by Wikipedia since 2026): turn on *Send Headers* and add `User-Agent` with a value like `tbl4-research-agent/1.0 (classroom exercise; contact: instructor)`. Without this, Wikipedia returns 403.
4. **Split Hits** (Split Out on `query.search`).
5. **Fetch Summary** (HTTP Request, runs per hit):
   - URL: `https://en.wikipedia.org/api/rest_v1/page/summary/{{ encodeURIComponent($json.title) }}`
   - **Same User-Agent header as Wikipedia Search** — Wikipedia 403s without it.
6. **Aggregate Sources** (Aggregate, mode `aggregateAllItemData`, destination `sources`).

### B. Synthesise (middle)

7. **Synthesise Briefing** (Basic LLM Chain) — produces an IC-style analytic briefing using the aggregated sources. Requirements:
   - Length 150-250 words.
   - Cite sources via `[Source N]` inline + a Sources list at the end.
   - Express likelihood using one of seven canonical terms (`almost no chance / very unlikely / unlikely / roughly even chance / likely / very likely / almost certain`).
   - Distinguish information from judgment ("we assess", "the source reports").
   - One alternative hypothesis.
   - Brief customer relevance at the end.
   - References sources via `{{ $json.sources.map((s, i) => '[Source ' + (i+1) + '] ' + s.title + ': ' + s.extract).join('\n\n') }}`.

### C. Audit + revise (right)

8. **Audit Briefing** (Basic LLM Chain) — audits the briefing against the four ICD policies. Output format:
   - For each finding: `Citation: <ICD-XXX> / <rule name>`, `Severity: violation | concern | compliant`, `Quote: ...`, `Explanation: ...`, `Fix: ...`
   - If clean: output exactly `COMPLIANT`.
   - End with: `SUMMARY: <N> findings, <V> violations.`
   - Reference briefing: `{{ $('Synthesise Briefing').item.json.text }}`.
   - Embed policy summaries in the prompt itself (or paste the full XML from the `policies/` files for stricter audit).

9. **Audit Clean?** (IF) — checks if the auditor's output contains the marker word from your prompt (probably `COMPLIANT`).

10. **Pass branch:** Final (Approved) — a Set node with fields `outcome=approved-on-first-draft`, `topic`, `briefing`, `audit_log`.

11. **Fail branch:** Revise Briefing (Basic LLM Chain) → Final (Revised). Revise references both the original briefing and the audit findings. Final (Revised) has the same fields plus `original_briefing` and `outcome=revised-after-audit`.

## Models

`llama3.1:8b`, credential `Ollama (local)`. One Ollama Chat Model sub-node feeds all four Basic LLM Chains via four `ai_languageModel` connections.

## Read the policies before writing the audit prompt

The four files in `policies/` are simplified versions of US Intelligence Community analytic standards, in slide-style minimal-tag XML — the same form you saw in lecture. Open each one. Read the rules.

The audit prompt's whole job is to flag findings *grounded in specific rules from these files*. You cannot write the audit prompt without knowing what's in them.

## Rules

- **No Code node.** Allowed: Set, IF, Split Out, Aggregate, HTTP Request, Basic LLM Chain, Ollama Chat Model.
- **Different prompt style per LLM step.** Generate Query is NARROW. Synthesise is COMPOSITE (uses sources, follows requirements). Audit is GROUNDED (every finding cites a rule). Revise is COMPOSITE (uses draft + audit).
- **One revise attempt only.** No looping back to re-audit the revised draft. Production systems would have a max-attempts counter.

## Success

You execute the workflow. Either:

- Audit returns `COMPLIANT`: Final (Approved) shows the briefing labelled `approved-on-first-draft`.
- Audit finds violations: Final (Revised) shows the revised briefing alongside the audit log.

Both paths produce the same field shape (`outcome`, `topic`, `briefing`, `audit_log`).

## Extension — if you finish early

- **Embed the FULL policy XML** in the audit prompt instead of summaries. Compare audit quality.
- **Add a max-attempts counter** so the workflow can retry the audit on the revised briefing, and gracefully give up after 3 attempts.
- **Replace Wikipedia with SearXNG** (a self-hosted metasearch engine) for true web search.
- **Two auditors with different personas** — one strict, one lenient. Average their findings.

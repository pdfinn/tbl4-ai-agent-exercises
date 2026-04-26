# Exercise 07 — Research Agent (Reference, annotated)

*For instructor debrief. Not to be released until all pairs have completed.*

## The graph (linear with one branch)

```
Manual Trigger
  └─ Set Input (topic)
       └─ Generate Query              (Basic LLM Chain — narrow output)
            └─ Wikipedia Search       (HTTP — MediaWiki API)
                 └─ Split Hits         (Split Out on query.search)
                      └─ Fetch Summary (HTTP — REST page summary, runs per hit)
                           └─ Aggregate Sources
                                └─ Synthesise Briefing  (Basic LLM Chain — IC style)
                                     └─ Audit Briefing  (Basic LLM Chain — policy audit)
                                          └─ Audit Clean? (IF on "COMPLIANT" marker)
                                               ├─ true ─→ Final (Approved)
                                               └─ false ─→ Revise → Final (Revised)

Ollama Chat Model
  └── ai_languageModel ── (fans out to all four Chains)
```

## Why this shape

- **All four patterns in one workflow.** Chaining is the spine. Parallel-ish appears in the Wikipedia stage (one search returns 3 hits, each gets its own Fetch Summary call). Routing appears in the Audit Clean gate. Evaluator/Optimiser appears as the audit step + the conditional revise.
- **Wikipedia as a real research source.** No keys, no auth, no setup. The MediaWiki search API gives top hits; the REST summary endpoint returns clean structured text per page. Together they're a real (if narrow) Deep Research clone.
- **The audit step is the lesson.** It encodes a *policy* — the four ICD standards — as a workflow component. The same shape applies to any organisation with a published rule set.
- **Two terminal Final nodes** with matching field shape (`outcome`, `topic`, `briefing`, `audit_log`). Downstream consumers don't care which path produced the result.

## Why the policies are simplified slide-style XML

The original ICD documents (in `02-research-agent/policies/`) use a heavy schema with `id`, `name`, `number`, `date`, `classification` attributes. That's fine for software but mismatched with the slide that teaches XML as `<role>...</role>` and `<rules>...</rules>` — minimal opening/closing semantic tags.

The policies in this exercise's `policies/` are rewritten with that minimal-tag style:

```xml
<policy>
<identifier>ICD-203</identifier>
<title>Analytic Standards</title>
<rule>
<name>Expresses uncertainty</name>
<text>Indicate and explain the basis for uncertainties...</text>
</rule>
</policy>
```

Same content; same form a student saw in lecture. Now the auditor LLM gets context that's structured but not foreign.

## Points to surface at debrief

1. **All four patterns made one workflow.** Walk the canvas left-to-right and label each pattern as it appears. This is the integration moment of Session 4.

2. **The audit prompt is policy-as-code.** The policies stay declarative XML; the audit prompt turns them into a runtime check. Changing the policy means editing the XML or the prompt — not changing the workflow shape. This is *exactly* what real compliance pipelines look like.

3. **Grounding language matters.** "ONLY flag issues grounded in a specific rule cited verbatim" is the line that prevents the auditor from inventing rules. Without it, LLMs reliably hallucinate plausible-sounding rule names. This is a real production lesson.

4. **The marker-word discriminator.** The `COMPLIANT` marker is how a string-output LLM communicates a binary decision to a downstream gate. Same trick as Ex 04's classifier returning `BILLING` / `TECHNICAL` / `GENERAL`.

5. **One revise attempt only.** Worth being explicit: the revise step doesn't get re-audited. A production system would loop with a max-attempts counter and a graceful give-up branch. We're showing the *pattern shape*, not the production loop.

## Common student errors

| Error | Lesson |
|---|---|
| Synthesise Briefing prompt doesn't enforce the likelihood scale | Audit catches it (one of the ICD-203 rules). Good — the audit is doing its job. |
| Briefing has no source citations | Audit catches it. Sourcing is ICD-206. |
| Auditor invents rule names ("Rule 4.2 of style guide") | Anti-fabrication language missing. Add: "Cite rule names verbatim from the policies." |
| Audit gate uses wrong rightValue | Picks something not in the auditor's vocabulary. Read the auditor's output panel to know what to look for. |
| Forgot `encodeURIComponent` on the Wikipedia title | Titles with spaces / special characters break the URL. The reference includes it. |
| The Aggregate destination field doesn't match the synthesis prompt | Aggregate's `destinationFieldName: "sources"` must match the prompt's `$json.sources`. |

## Why one Ollama model serves four roles

The Ollama Chat Model loads `llama3.1:8b` once. It serves as:
- The query generator (narrow one-line output).
- The briefing synthesiser (composite IC-style writing).
- The auditor (grounded in policies).
- The reviser (composite, uses original + feedback).

Same model. Four different prompts. Four different "agents." This reinforces the slide's point: an "agent" is a model + a system prompt for a specific task, not a separate piece of magic.

## Progressive destruction prompts

- **"Run with three different topics."** Some topics will pass first time; some will fail audit. The system handles both.
- **"Embed the FULL policy XML in the audit prompt."** Compare audit quality. Trade-off: prompt becomes ~3-4× longer; latency up; accuracy up.
- **"Make the auditor strict."** Add to the audit prompt: "Be a strict editor for The Economist." Compare findings to the default neutral auditor.
- **"What if both drafts fail?"** Currently no fallback — `revised-after-audit` ships even if the revise still has violations. Production version: max-attempts counter + escalation.
- **"Replace Wikipedia with another source."** SearXNG (self-hosted), DuckDuckGo HTML scrape, or a static JSON file in a Set node. Same workflow shape; different research source.

## Mapping back to the slides

- Slide 2425 (*"Research agents: under the hood"*) — the slide that motivates this exercise; this workflow IS the diagram on that slide.
- Slides 2484–2612 (the four patterns) — every pattern appears in this workflow.
- Slide 2671 (*"XML tags"*) — the slide-style XML format used in `policies/`.
- Slide 2846 (*"Prompting for workflow agents"*) — the narrow-output discipline that makes the auditor's `COMPLIANT` marker reliable.
- Slide 3020 (*"Exercise 3 — Research agent workflow"*) — the slide's homework version of this exercise; this is the n8n realisation.

## On the Wikipedia limitation

The default research source is Wikipedia. Pros: free, no auth, real content, rate-limit-tolerant for class use, returns clean structured JSON. Cons: it's encyclopedic, not "the web" — recent news, social posts, and primary documents aren't there.

For a real Deep Research clone, swap Wikipedia for SearXNG (self-hosted, no key, real web search) or a paid API. The workflow shape stays identical.

## Threads forward

- **Ex 08 (Policy Simplifier — optional)** — a sub-agent that converts heavy ICD XML to the slide-style minimal-tag form used in this exercise's `policies/`. Demonstrates LLM as structured-document transformer.
- **Ex 09 (Model Rodeo — optional)** — re-run this workflow with different LLMs swapped in. The Audit step is the most sensitive node to model quality.
- Conceptually bridges to **Session 5 (Autonomous Agents)** — when the agent decides which sources to consult and when to revise, you've crossed into autonomous territory.

## On length and load

The workflow has 14 nodes. End-to-end run time on a typical student laptop: 60–120 seconds (depending on model warmth and number of revisions). Wall-clock dominated by LLM calls; Wikipedia HTTP is fast.

For class demos, pre-warm the model (run any throwaway prompt first) so the first invocation isn't a cold-start surprise.

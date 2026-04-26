# Exercise 07 — Research Agent (Final Lab)

*Instructor-facing overview. Student-facing instructions are in `07-a-blank.md` and `07-b-half-built.md`.*

## Learning goal

The integration exercise. Students combine **all four patterns** from Session 4 into one working workflow that does real research and self-audits its output. By the end they should:

- See how the four patterns compose: a real workflow uses Chaining + Parallel + Routing + Evaluator/Optimiser, not one in isolation.
- Understand "implementing a policy" as a workflow concept — the policy is enforced as an audit step, not just a document the LLM might or might not honour.
- Use real APIs (Wikipedia MediaWiki + REST) inside an AI workflow.
- Read structured policy XML and write an LLM auditor that grounds findings in specific rules.
- Operate the full research-draft-audit-revise loop and recognise it as a generic pattern that applies far beyond intelligence work.

## Domain

Topic-driven research → analytic briefing → policy audit → revision. Default topic is "Singapore hawker culture and UNESCO recognition" because it has a rich Wikipedia article and is locally meaningful. The pattern is domain-substitutable: any organisation with a published style guide, brand voice, regulatory standard, or quality bar can apply this workflow to any draft output.

## The artefacts

| File | Purpose |
|---|---|
| `policies/ICD-203.xml` etc. | Four simplified IC analytic standards in slide-style XML. The audit step uses these. |
| `07-a-blank.workflow.json` | Manual Trigger + 5 sticky notes (pattern, sub-systems, policies, rules, extension). |
| `07-b-half-built.workflow.json` | Full 14-node graph with three substantial gaps: Synthesise Briefing prompt, Audit Briefing prompt, Audit Clean? gate value. |
| `07-c-reference.workflow.json` | Working solution. |

## Why this exercise opens the policies

The original `02-research-agent` exercise (in OpenWebUI) gave students a system prompt that audits a briefing against the same four policies. **This exercise wraps that prompt as a workflow audit step** and adds the rest — research, draft, audit, revise.

The pedagogical thread:
- **Ex 02:** "I can write a prompt that audits a briefing." (Prompt as artefact.)
- **Ex 07:** "I can wire that prompt into a workflow that runs continuously, on every draft, and refuses to ship non-compliant output." (Prompt as workflow component.)

## Recommended session flow (~90 min)

1. **(5 min) Whiteboard.** Draw all four patterns from session 4 across the board. Label which appears where in this workflow. The Research stage = Chaining. Wikipedia returning N hits and getting per-hit summaries = Parallel-ish. Audit gate = Routing. Audit failing → revise → recheck = Evaluator/Optimiser.
2. **(10 min) Open the policies.** Walk the class through `policies/ICD-203.xml`. Show the slide-style minimal-tag XML — this is the same XML they saw in lecture. Read 2–3 rules out loud. Establish that the audit step's job is to ground findings in these rules.
3. **(15 min) Pre-built skeleton.** Most pairs will start with `07-b-half-built.workflow.json`. Walk through what's already wired — the research stage runs Wikipedia → fetches → aggregates without student input. The student work is the three prompts and the gate.
4. **(45 min) Pair build.** Watch for:
   - Synthesise Briefing prompts that ignore the IC style requirements (no likelihood scale, no information/judgment distinction).
   - Audit Briefing prompts that don't require rule-grounded findings ("the briefing seems unprofessional" is not a finding).
   - Audit Clean? gate looking for the wrong string.
   - Auditor LLMs fabricating rule names not in the policies. Fix: tell the auditor "ONLY flag issues grounded in a rule cited verbatim from the policies."
5. **(10 min) Run it twice.** First run: see what the auditor catches in the first draft. Second run with the same topic but a tighter Synthesise prompt (e.g., "include a sources section"). Watch the audit findings change. Real prompt-engineering iteration.
6. **(5 min) Debrief.** Release reference. Compare audit logs.

## The 3 gaps in variant B (answer key)

1. **Synthesise Briefing prompt** (the IC-style writing prompt):
   ```
   =Write an analytic briefing on the topic, using ONLY the sources provided. Style: IC analytic product. Length: 150-250 words.

   Requirements:
   - Cite sources using [Source N] inline markers and a numbered Sources section at the end.
   - Express likelihood using one of: almost no chance / very unlikely / unlikely / roughly even chance / likely / very likely / almost certain.
   - Distinguish information from judgment with explicit phrases ("we assess", "we judge", "the source reports").
   - Note one alternative hypothesis where appropriate.
   - Address customer relevance briefly at the end.

   Topic: {{ $('Set Input').item.json.topic }}

   Sources:
   {{ $json.sources.map((s, i) => '[Source ' + (i+1) + '] ' + s.title + ': ' + s.extract).join('\n\n') }}
   ```

2. **Audit Briefing prompt** (the policy auditor):
   ```
   =You are an IC analytic-product auditor. Audit the briefing below against four policies. For each rule that is violated or of concern, produce a finding:

   - Citation: <ICD-XXX> / <rule name>
   - Severity: violation | concern | compliant
   - Quote: <exact phrase from briefing>
   - Explanation: <why it violates the rule>
   - Fix: <what to change>

   Only flag issues grounded in a specific rule cited verbatim from the policies below. Do NOT invent rules.

   If the briefing is fully compliant, output exactly: COMPLIANT

   If there are findings, list them, then end with one summary line:
   SUMMARY: <N> findings, <V> violations.

   BRIEFING:
   {{ $('Synthesise Briefing').item.json.text }}

   POLICIES:
   [Embed summaries of ICD-203, ICD-206, ICD-208, ICS-206-1 here. The reference includes full summaries; students can paste these from the policies/*.xml files.]
   ```

3. **Audit Clean? rightValue:** `COMPLIANT`. Anything else passes the audit step. The auditor outputs `COMPLIANT` only when it has no findings.

## Progressive destruction prompts

- **"Run with three different topics."** Some topics will pass first time; some will fail audit. Watch the system handle both.
- **"Embed the FULL policy XML in the audit prompt."** Compare audit quality. Trade-off: latency increases substantially.
- **"What if the auditor invents a rule name?"** Add explicit anti-fabrication language: "Cite rule names verbatim from the policies. If you cannot cite a rule, do not flag the finding."
- **"What if both the original AND the revised briefing fail audit?"** Currently no fallback — the workflow ships a non-compliant briefing labelled `revised-after-audit`. Production version: max-attempts counter + escalation.
- **"Replace Wikipedia with SearXNG."** Self-hosted metasearch. Same shape; different sources. Mention this for advanced students.

## Common student errors

| Error | Lesson |
|---|---|
| Wikipedia returns 403 | Wikipedia (since early 2026) requires a User-Agent header. n8n's HTTP node doesn't set one by default. Both Wikipedia HTTP nodes need `sendHeaders: true` with a `User-Agent` like `tbl4-research-agent/1.0 (Vertical Institute classroom exercise; contact: instructor)`. The reference includes this. |
| Synthesise Briefing references the wrong upstream node | Should reference `$json.sources` (from Aggregate) and `$('Set Input').item.json.topic`. |
| Briefing has no source citations | Synthesise prompt didn't enforce the format. Audit catches it (good!). |
| Auditor fabricates rule names | Prompt didn't forbid invention. Add explicit anti-fabrication language. |
| Audit gate uses wrong rightValue | Picks something not in the auditor's vocabulary. Read the auditor's output to know what to look for. |
| Forgot `encodeURIComponent` on Wikipedia title | Titles with spaces / special characters break the URL. The reference includes it. |
| Aggregate destination field doesn't match the synthesis prompt | Aggregate's `destinationFieldName: "sources"` must match the prompt's `$json.sources`. |

## Mapping back to the slides

- Slide 2425 (*"Research agents: under the hood"*) — the slide that motivates this exercise.
- Slide 2484 onward — the four workflow patterns this lab integrates.
- Slide 2671 (*"XML tags — giving structure to your prompts"*) — the slide-style minimal-tag XML used in the policies.
- Slide 3020 (*"Exercise 3 — Research agent workflow"*) — the slide's homework version of this exercise.

## On policy length and prompt size

The reference uses a *summary* of each policy in the audit prompt — about 60 words per policy. This keeps the prompt under 1000 tokens.

For higher-quality audits, embed the full XML of each policy. Each is 80–150 lines. Total prompt size becomes ~3000-4000 tokens. Llama 3.1 8B handles this comfortably (128k context). Latency increases by maybe 30%.

If a student wants the full audit, point them at the `policies/` files and have them paste the XML into the prompt. Useful extension exercise.

## Threads forward

- **Ex 08 (Policy Simplifier, optional)** — a sub-agent that converts heavy ICD XML to slide-style minimal-tag XML, the same form used in this exercise's `policies/`.
- **Ex 09 (Model Rodeo, optional)** — re-run this workflow with different models. The Audit step is the most sensitive to model quality.

## Import instructions

From inside n8n: **Workflows → top-right menu → Import from File** → pick one of the `.json` files. Confirm the Ollama Chat Model has `Ollama (local)` selected.

The workflow is self-contained — Wikipedia is the only external dependency, and it works without any keys or auth.

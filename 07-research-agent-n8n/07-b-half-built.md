# Exercise 07 — Research Agent (Half-Built)

Fourteen nodes are on the canvas, fully wired. The research stage (query generation, Wikipedia search, fetch, aggregate) is pre-built. **Three substantial fields are blank** — fill them in.

## Gap 1 — The Synthesise Briefing prompt

The **Synthesise Briefing** node has its prompt blank. This prompt produces the IC-style analytic briefing.

The prompt should:
- Tell the model to write a briefing on the topic, using ONLY the provided sources.
- Specify length (150-250 words) and style (IC analytic product).
- Require source citations: `[Source N]` markers + a numbered Sources section at the end.
- Require one of the seven canonical likelihood terms (`almost no chance / very unlikely / unlikely / roughly even chance / likely / very likely / almost certain`).
- Distinguish information from judgment via explicit phrases (`"we assess"`, `"the source reports"`).
- Note one alternative hypothesis.
- Include customer relevance at the end.
- Reference the topic via `{{ $('Set Input').item.json.topic }}`.
- Reference the sources via `{{ $json.sources.map((s, i) => '[Source ' + (i+1) + '] ' + s.title + ': ' + s.extract).join('\n\n') }}`.

This is a **composite prompt** — it pulls in two upstream sources and enforces structural requirements.

## Gap 2 — The Audit Briefing prompt

The **Audit Briefing** node has its prompt blank. This is the **policy auditor**.

Read the four policy files in `policies/` first. They are in slide-style minimal-tag XML — `<policy>`, `<rule>`, `<name>`, `<text>`, etc. Each rule has a name you can cite.

The audit prompt should:
- Establish the model as an IC analytic-product auditor.
- Tell it to audit the briefing against the four policies (which you embed in the prompt).
- For each finding, require: Citation (`ICD-XXX / rule name`), Severity (violation / concern / compliant), Quote (exact phrase), Explanation, Fix.
- ONLY flag issues grounded in a specific rule cited verbatim. Do NOT invent rules. Do NOT flag stylistic preferences not in the policies.
- If clean: output exactly one word that you'll use as the gate marker (e.g., `COMPLIANT`).
- End with `SUMMARY: <N> findings, <V> violations.`
- Reference briefing via `{{ $('Synthesise Briefing').item.json.text }}`.
- Embed either a *summary* of each policy or the full XML in the prompt. Summary is faster; full XML is more thorough.

## Gap 3 — The Audit Clean? gate

The **Audit Clean?** IF node has its `rightValue` blank. Decide what string the IF should look for in the auditor's output to consider the briefing clean.

Whatever marker word you used in the audit prompt for the "clean" case (probably `COMPLIANT`) is what you put here.

The expression on the left, `{{ $json.text }}`, references the auditor's output. The IF uses *contains* (not *equals*) so the marker word can appear anywhere in the output.

## Everything else is already done

- The research stage (Set Input → Generate Query → Wikipedia Search → Split Hits → Fetch Summary → Aggregate Sources) is fully wired and configured.
- The Generate Query prompt is filled.
- The Revise Briefing prompt is filled — references both the original briefing and the audit findings.
- Both Final (Approved) and Final (Revised) Set nodes are configured with the same field shape.
- The IF expression on the left is correct.
- The Ollama Chat Model is connected to all four Basic LLM Chains.

## Read the policies first

You **cannot** write the audit prompt without reading the policies. Open these in your editor or a separate browser tab:

- `policies/ICD-203.xml` — Analytic Standards (objectivity, uncertainty, sourcing, alternatives, clear argumentation)
- `policies/ICD-206.xml` — Sourcing requirements
- `policies/ICD-208.xml` — Maximising utility
- `policies/ICS-206-1.xml` — PAI / CAI / OSINT / AI citation

Notice the format. They use `<policy>`, `<rule>`, `<name>`, `<text>` — the same minimal-tag XML you saw in lecture. Each rule has a `<name>` your auditor will cite.

## Rule

No Code node.

## Extension — if you finish early

- Paste the FULL XML of all four policies into the audit prompt (instead of summaries). Compare audit quality.
- Add a max-attempts counter so revised briefings are also audited.
- Replace Wikipedia with SearXNG (advanced).

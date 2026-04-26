# Exercise 02 --- Research-agent: auditing analytic products against standards

A two-part exercise on using structured policy context as an LLM grounding
source. You will build an AI research agent that reviews an intelligence
briefing against four US Intelligence Community standards and reports where
the briefing complies, where it violates the standards, and how to fix it.

The agent is an editor, not an author. It does not write analysis; it audits
analysis against a rules corpus you provide as context.

The pattern applies well beyond intelligence: code review against a style
guide, policy compliance auditing, editorial review against a style manual,
regulatory self-assessment.

## What you'll need

* Open WebUI running locally with a capable model (Qwen3 14B, Llama 3.2 70B,
  or similar --- smaller models struggle with long structured context)
* The four policy files in [`policies/`](./policies/)
* The [`sample-briefing.md`](./sample-briefing.md) --- an analytic briefing
  seeded with deliberate violations

## The policies

The four files in `policies/` are simplified, semantic versions of real
public IC standards. The originals are dense and use generic `<paragraph>`
tags; these versions strip the governance scaffolding and mark up the
normative content with semantic tags an LLM can work with:

| File | What it covers |
|------|----------------|
| `ICD-203.xml` | Five core analytic standards + nine tradecraft standards + probability scale |
| `ICD-206.xml` | Sourcing mechanisms: SRC, ARC, source descriptor, source summary statement |
| `ICS-206-1.xml` | Citation conventions for PAI, CAI, OSINT, and AI-generated content |
| `ICD-208.xml` | Five principles for maximising product utility |

The semantic markup makes the standards directly quotable: when the agent
flags a violation, it can name the rule by ID (e.g. `ICD-203/expresses-uncertainty/no-mix-likelihood-with-confidence`).

## Part 1 --- Plain prose with the standards as context

Write a system prompt that turns the model into an IC analytic product
reviewer. The prompt should:

* Establish the agent's role as an editor/reviewer, not an author
* Instruct the agent to audit the product against the four standards you
  will paste into context
* Tell it to report findings as a list: what was checked, whether it passed
  or failed, and the specific rule that applies
* Handle uncertainty: when the agent can't tell from the text alone, it
  should say "unable to determine" rather than guess

Paste all four policy files into the system prompt as context, then send
the sample briefing as the user message. Read the output. Run it three
times.

### What to notice

Even with the policies as context, a plain-prose prompt tends to:

* Miss specific rule IDs (it says "the uncertainty standard" rather than
  naming `ICD-203/expresses-uncertainty/no-mix-likelihood-with-confidence`)
* Produce findings in a free-form list that varies run-to-run
* Mix compliant and non-compliant observations together
* Occasionally praise the briefing for things the standards don't actually
  require ("clear structure", "professional tone")

Note two or three of these weaknesses --- Part 2 will fix them.

## Part 2 --- Structure both the prompt and the output

Restructure with Markdown or XML, and specify a machine-parseable output
format:

```markdown
## Role
## Context
<the four standards, as XML, pasted inline>
## Task
## Output format
For each finding, produce:
- **Rule ID:** <standard>/<section>/<rule>
- **Severity:** violation | concern | compliant
- **Quote:** "<exact phrase from the briefing>"
- **Explanation:** <why the quote violates the rule>
- **Fix:** <what the analyst should do>
## Rules
- Do not flag issues that are not grounded in a specific rule from the
  Context section. If you cannot cite a rule, do not flag the issue.
- When the briefing is compliant with a rule, say so once --- do not flood
  the output with "compliant" findings.
- If you are unable to determine compliance from the briefing text alone,
  mark the finding "unable to determine" and explain why.
```

Run the same briefing three times with the structured prompt and compare to
Part 1.

### What should change

* Every finding names a specific rule ID
* The output format is stable run-to-run
* The agent stops flagging things not grounded in a rule
* A downstream script could parse each finding into a structured record

## What the sample briefing gets wrong

The sample briefing seeds roughly 8--10 violations across the four
standards. Here is a non-exhaustive list to validate your agent against
(don't peek until you've run your own):

<details>
<summary>Expected findings (click to expand)</summary>

* **ICD-203 / expresses-uncertainty / no-mix-likelihood-with-confidence**:
  "almost certain ... high confidence they will almost certainly target"
  combines likelihood and confidence terms in the same sentence.
* **ICD-203 / expresses-uncertainty / one-scale**: mixes "improbable" (row
  B) with "probably" (row A) without a disclaimer.
* **ICD-203 / change-or-consistency**: says "consistent with previous
  reporting" with no explanation of how or why --- boilerplate.
* **ICD-203 / distinguishes-info-from-judgment**: "technical indicators
  suggest" without listing the indicators; "has received state support"
  presented as fact, not judgment.
* **ICD-203 / analysis-of-alternatives**: no alternative hypotheses considered.
* **ICD-203 / sources-quality**: no source quality or credibility assessment
  for the "former group member interviewed in an online forum".
* **ICD-206 / src**: briefing contains no SRCs at all; judgments are not
  tied to specific sources.
* **ICD-206 / source-summary-statement**: no source summary statement
  despite multiple sources of differing reliability.
* **ICS-206-1 / ai-citation / classification-model**: "vendor's proprietary
  AI system" cited as a basis for a key judgment with none of the required
  citation elements (model name, precision/recall, training data, version,
  etc.).
* **ICS-206-1 / body-elements / data-host**: no URL, platform, or data host
  named for the "online forum" interview or the threat intel vendor.

</details>

## Going further

* **Wrap this prompt in a workflow.** [Exercise 07](../07-research-agent-n8n/)
  takes the audit prompt you just wrote and embeds it as the audit step in an
  n8n workflow that researches a topic, drafts a briefing, audits its own
  output against the same four policies, and revises on audit findings. The
  policies in that exercise are simplified to slide-style XML; the
  prompt-engineering lesson stays the same.
* Feed the structured output into an n8n workflow that posts each
  high-severity finding to a Slack channel tagged by rule ID.
* Replace the sample briefing with one of your own documents (a blog post,
  a product memo) and a different rules corpus (your style guide, your
  brand voice guidelines). The same pattern works for any rule-corpus
  audit task.
* Try the same prompt with a small model (e.g. 3B or 7B) and a larger one.
  How much smaller a model can you go before findings stop being grounded
  in the rules?

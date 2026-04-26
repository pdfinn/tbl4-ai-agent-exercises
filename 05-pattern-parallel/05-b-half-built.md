# Exercise 05 — Parallelisation (Half-Built)

Eight nodes are on the canvas, fully wired. The Merge node is correctly configured for three inputs. **Three fields are blank** — fill them in.

## Gap 1 — The Extract Entities prompt

The **Extract Entities** node has its prompt blank. Write a prompt that returns a STRUCTURED list — same format every run, parseable by code.

Suggested format:

```
People: <comma-separated list, or "none">
Places: <comma-separated list, or "none">
Organisations: <comma-separated list, or "none">
Dates: <comma-separated list, or "none">
```

The prompt should:
- Tell the model to extract named entities from the document.
- Specify the EXACT output format above.
- Reference the document via `{{ $('Set Input').item.json.document }}`.
- Forbid prose preambles.

## Gap 2 — The Classify Sentiment prompt

The **Classify Sentiment** node has its prompt blank. Write a one-word output prompt — same discipline as the classifier in Ex 04.

The prompt should:
- Tell the model to output exactly one word: `POSITIVE`, `NEUTRAL`, or `NEGATIVE`.
- Forbid explanations, punctuation, preambles.
- Reference the document.

## Gap 3 — The Compose Report template

The **Compose Report** node has its `report` field blank. Write a Markdown template that pulls all three branch outputs into one document via cross-node references.

The expressions you need:
- `{{ $('Summarise').item.json.text }}` — the summary
- `{{ $('Extract Entities').item.json.text }}` — the structured entity list
- `{{ $('Classify Sentiment').item.json.text.trim() }}` — the one-word sentiment (with `.trim()` to handle any trailing whitespace)

Suggested structure:

```
=# Document analysis report

## Summary
[summary expression]

## Entities
[entities expression]

## Sentiment
**[sentiment expression]**
```

Don't forget the leading `=` to mark the field as an expression.

## Everything else is already done

- The Summarise prompt is filled in (a 2-sentence summary). Read it as a template.
- Set Input has a sample document (a memo about hawker operations).
- The Merge node is configured for 3 inputs in `combineByPosition` mode.
- All three branches are wired to the right Merge slots.
- The Ollama Chat Model is connected to all three Basic LLM Chains.

## Rule

No Code node.

## Extension — if you finish early

- Add a fourth branch: Translate to Bahasa Melayu. Update Merge `Number Of Inputs` to 4.
- Try a much longer document. Watch the wall-clock time — the "parallel" branches actually run sequentially in n8n's v1 execution.
- Replace Manual Trigger with a Form Trigger.

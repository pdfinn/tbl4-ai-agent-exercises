# Bonus B3 — Read a Google Doc (Half-Built)

Four nodes are on the canvas, fully wired. **Three fields need filling** — but first you need a published doc.

## Step 0 — publish a Google Doc

Open or create a Doc (paste in `sample-doc.txt` for ready-made notes), then **Share → Anyone with the link → Viewer**. Copy the ID from the URL: the part between `/d/` and `/edit`.

No Google account or offline? Use `B3-c-reference-offline.workflow.json` instead — no setup, runs immediately.

## Gap 1 — the doc ID

**Set Input → `doc_id`** is blank. Paste your published doc's ID.

## Gap 2 — build the URL from the input

**Fetch Doc → URL** contains a hard-coded placeholder `DOC_ID_HERE`. Replace that placeholder with an expression that reads the field you just set:

```
=https://docs.google.com/document/d/{{ $('Set Input').item.json.doc_id }}/export?format=txt
```

This is a small but real skill: building a request URL from workflow data instead of hard-coding it.

## Gap 3 — the extraction prompt

**Extract Action Items → prompt** is blank. The fetched document text is at `{{ $json.doc_text }}`. Write a prompt that pulls the action items into a Markdown checklist, capturing owner and due date. Example shape:

```
- [ ] <owner> — <task> (due <date>)
```

## Already done for you

- The HTTP node is set to return the response as **plain text** into a field named `doc_text` (Options → Response → Response Format = Text).
- The **Result** node copies the LLM output into `action_items`.
- The Ollama Chat Model is connected.

## Before you run

1. Confirm your doc is link-shared (gap 1/2 are useless if Google returns a login page).
2. Click **Ollama Chat Model** and check the credential is `Ollama (local)`.
3. **Run the Fetch Doc node on its own first** and read `doc_text`. If it's your document text, continue. If it's HTML, fix the sharing setting.

## Rule

No Google node, no API key. HTTP + LLM only.

## Extension

- Point it at a published Google **Sheet** (`?format=csv`) + an Extract From File node → tabular data, live from Google.
- Email the result to yourself (Ex 00 stage 3).

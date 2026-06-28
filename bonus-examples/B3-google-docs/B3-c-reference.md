# Bonus B3 — Read a Google Doc (Reference, annotated)

*For instructor debrief. Two reference workflows ship: `B3-c-reference.workflow.json` (live) and `B3-c-reference-offline.workflow.json` (no Google setup).*

## The graph (live)

```
Manual Trigger
  └─ Set Input (doc_id)
       └─ Fetch Doc (HTTP GET export?format=txt → doc_text)
            └─ Extract Action Items (Basic LLM Chain over doc_text)
                 └─ Result (Set: action_items)

Ollama Chat Model ── ai_languageModel ──→ Extract Action Items
```

The offline variant swaps **Fetch Doc** for a **Load Mock Doc** Set node carrying `sample-doc.txt`. Everything downstream is byte-for-byte the same.

## The point of this exercise

Students ask "can the local Docker n8n connect to Google Docs?" The honest, useful answer: **yes, and the easy 80% case needs no credentials at all.** A link-shared Doc exports as plain text at a stable URL. "Connecting to Google" turns out to be the HTTP Request node they already know.

This reframes "integration" for beginners: an integration is often just a well-formed HTTP request. Save OAuth for when they actually need to write.

## The three ways to reach Google (the slide students remember)

| Method | Setup | Can write? | Use when |
|---|---|---|---|
| **Export URL** (this exercise) | None — just publish the doc | No (read-only) | Getting text/CSV *into* a workflow |
| **Service Account** | GCP project → service account → download JSON key → paste into an n8n Google credential → **share the doc with the service-account email** | Yes | You need to create/update Docs or Sheets, no per-user login |
| **OAuth2** | GCP project → OAuth consent screen → client ID/secret → register redirect `http://localhost:5678/rest/oauth2-credential/callback` → approve "unverified app" | Yes (as a user) | Acting as a specific Google user, Gmail, etc. |

For an intro class, lead with the export URL and mention the Service Account as the write upgrade. OAuth's consent-screen + redirect setup is real friction and breaks the course's "no API keys" promise — show it only if asked.

## The 3 gaps in variant B (answer key)

1. **Set Input → `doc_id`** — the student's published doc ID.
2. **Fetch Doc → URL** — replace `DOC_ID_HERE` with `{{ $('Set Input').item.json.doc_id }}`. (Lesson: build the URL from input data.)
3. **Extract Action Items → prompt** — extract action items to a Markdown checklist over `{{ $json.doc_text }}`.

## Why the HTTP node is configured the way it is

- **`export?format=txt`** returns the body as `text/plain`. (For a Sheet, `format=csv`.)
- **Options → Response → Response Format = Text, output `doc_text`.** Without this, n8n tries to JSON-parse the body and you get a confusing failure on what is plainly text. Setting the field name keeps the expression downstream readable (`$json.doc_text`).

## Points to surface at debrief

1. **Run Fetch Doc alone, first.** The #1 failure is a doc that isn't link-shared: Google returns an HTML sign-in page, the LLM dutifully "extracts action items" from HTML, and the student is baffled. Teach: inspect the fetch output before trusting it.
2. **No credentials anywhere.** Open the n8n credentials list — empty. Drive the point home: this is a real Google integration with zero auth config.
3. **Read-only is a real limit.** Ask "how would you write the summary *back* into the doc?" → that's where the Service Account earns its keep. Good segue if a student is ready for it.

## Common student errors

| Error | Lesson |
|---|---|
| Doc not link-shared | HTTP returns HTML login page, not text. Always inspect the fetch first. |
| Leaves `DOC_ID_HERE` hard-coded | The URL must be built from the input field via expression. |
| Forgets Response Format = Text | n8n mis-parses the body; `doc_text` is empty or wrong. |
| Expects to write back | This path is read-only by design. |

## Threads

- **Same HTTP-fetch shape as Ex 00 (data.gov.sg) and Ex 07 (Wikipedia)** — a third public source, now Google.
- **Feeds Bonus B1** if pointed at a Sheet (`format=csv` + Extract From File).
- **Offline variant** mirrors Ex 07's offline fallback philosophy exactly.

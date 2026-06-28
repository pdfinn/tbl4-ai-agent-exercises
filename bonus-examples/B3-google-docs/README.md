# Bonus B3 — Read a Google Doc

*Instructor-facing overview. Student-facing instructions are in `B3-a-blank.md` and `B3-b-half-built.md`.*

A standalone bonus exercise answering the most-asked integration question: **"Can the local Docker n8n connect to Google Docs?"** Short answer — yes, and the easy case needs no credentials. This exercise teaches that, and is honest about the three auth tiers so students know what the "real" node costs.

## Learning goal

By the end students should:

- Know that a **published / link-shared Google Doc** fetches as plain text at `…/export?format=txt` — no Google node, no OAuth, no API key.
- See that "an integration" is frequently just a well-formed **HTTP Request** (same node as Ex 00 and Ex 07).
- **Build a request URL from input data** with an expression.
- Force a **text response** on the HTTP node and read it before trusting it.
- Understand the three ways to reach Google (export URL / Service Account / OAuth2) and when each is worth it.

## Domain

Meeting notes for a fictional product ("Project Laksa"), with clear decisions and dated action items. The LLM extracts the action items into a Markdown checklist. Shipped as `sample-doc.txt` (paste into your own Doc) and baked into the offline variant's Set node.

## The artefacts

| File | Use |
|---|---|
| `B3-a-blank.workflow.json` | Manual Trigger + 4 sticky notes. Students build Set → HTTP → LLM → Set. |
| `B3-b-half-built.workflow.json` | Full 4-node graph, 3 gaps: doc ID, the URL expression, the extraction prompt. |
| `B3-c-reference.workflow.json` | Working **live** solution (fetches a real published doc). |
| `B3-c-reference-offline.workflow.json` | No-Google-setup fallback — doc text in a Set node. Always runs. |
| `sample-doc.txt` | Paste into a Google Doc, or read as the canonical content. |

## Can the local Docker n8n really do this? — the full answer

Yes, three ways, in increasing order of setup cost:

1. **Export URL (this exercise).** Zero credentials, read-only. Publish the Doc (or link-share as Viewer), fetch `…/export?format=txt`. A Sheet exports as CSV with `format=csv`.
2. **Service Account.** Create a Google Cloud service account, download its JSON key, paste it into an n8n Google credential, then **share the document with the service-account email** (it behaves like a robot collaborator). No browser consent flow, no redirect URL. This is the right choice for *writing* Docs/Sheets in a classroom — far simpler than OAuth.
3. **OAuth2.** A GCP project, an OAuth consent screen, a client ID/secret, and the redirect `http://localhost:5678/rest/oauth2-credential/callback` registered. Works with local Docker (the callback hits localhost), but you'll click through an "unverified app" warning and add yourself as a test user. Most capable, most friction — overkill for intro.

Lead with #1. Mention #2 as the "when you need to write" upgrade. Only demo #3 if a student specifically needs per-user Gmail/Calendar access.

## Recommended session flow (~35 min)

1. **(5 min) Reframe "integration".** Ask the class how they'd get a Google Doc into n8n. Most will assume an account + login. Reveal the export URL.
2. **(5 min) Publish a doc together.** Walk the share-as-Viewer step; everyone gets an ID.
3. **(15 min) Pair build.** Watch for un-shared docs (HTML comes back) and hard-coded `DOC_ID_HERE`. Insist they run *Fetch Doc* alone and read `doc_text` before writing the prompt.
4. **(5 min) Show the empty credentials list.** "A real Google integration, zero auth configured."
5. **(5 min) Debrief + the three tiers.** Pose "how would you write *back* into the doc?" → Service Account.

## The 3 gaps in variant B (answer key)

1. **Set Input → `doc_id`** — the published doc's ID.
2. **Fetch Doc → URL** — `DOC_ID_HERE` → `{{ $('Set Input').item.json.doc_id }}`.
3. **Extract Action Items → prompt** — checklist extraction over `{{ $json.doc_text }}`.

## Common student errors

| Error | Lesson |
|---|---|
| Doc not link-shared | Google returns an HTML login page; the LLM "summarises" HTML. Inspect the fetch first. |
| `DOC_ID_HERE` left hard-coded | Build the URL from the input field via expression. |
| Response Format not set to Text | Body is mis-parsed; `doc_text` empty. |
| Expects to write back | The export URL is read-only by design — that's the Service Account's job. |

## Threads

- **Third instance of the HTTP-fetch shape** after Ex 00 (data.gov.sg) and Ex 07 (Wikipedia).
- **Point it at a Sheet** (`format=csv`) to feed Bonus B1's tabular pipeline live.
- **Offline variant** follows Ex 07's offline-fallback pattern.

## Import instructions

n8n → **Workflows → top-right menu → Import from File**. For the live workflow you must publish a Google Doc first; otherwise use the offline variant. Confirm the Ollama Chat Model has the `Ollama (local)` credential after import.

# Bonus B3 — Read a Google Doc (Blank Starter)

"Can n8n connect to Google Docs from the local Docker setup?" Yes — and the simplest way needs **no Google node, no OAuth, and no API key**. A *published* Google Doc can be fetched as plain text by URL, so reading a Doc is just the HTTP Request node you already met in Ex 00 and Ex 07.

## The pattern

```
Doc ID → Fetch Doc (HTTP, export?format=txt) → Extract with LLM → Result
```

Read-only: this gets a Doc's text *into* a workflow. It can't write back. (Writing needs the real Google Docs node plus a Service Account — see the README.)

## First: publish a doc (~2 minutes)

1. Open or create a Google Doc. (Paste in `sample-doc.txt` from this folder for ready-made meeting notes.)
2. **Share → General access → Anyone with the link → Viewer.** (Or File → Share → Publish to web.)
3. Copy the ID from the URL — the part between `/d/` and `/edit`:
   `docs.google.com/document/d/`**`THIS_PART`**`/edit`

If you get HTML back instead of your text, the doc isn't link-shared yet — Google handed back a sign-in page.

**No Google account, or offline?** Skip all this and open `B3-c-reference-offline.workflow.json` — it bakes the doc text into a Set node and runs with zero Google setup.

## What you've been given

- A **Manual Trigger** and four sticky notes (pattern, setup, build steps, extension). You build the rest.

## Build it

1. **Set ("Set Input")** — a string field `doc_id` holding your published doc's ID.
2. **HTTP Request ("Fetch Doc")** — method GET, URL built from the input:
   `=https://docs.google.com/document/d/{{ $('Set Input').item.json.doc_id }}/export?format=txt`
   In **Options → Response → Response Format**, choose **Text**, output field name `doc_text`.
3. **Basic LLM Chain ("Extract Action Items")** + **Ollama Chat Model** — read `{{ $json.doc_text }}`, pull the action items into a Markdown checklist with owner and due date.
4. **Set ("Result")** — `action_items` = `{{ $json.text }}`.

## Rules

- **No Google node, no API key.** Just HTTP + LLM.
- **Run after the fetch.** Click *Fetch Doc* and read `doc_text` *before* you write the prompt. Confirm you got the document, not a login page.
- **Model:** `llama3.1:8b`. **Credential:** `Ollama (local)`.

## Success

You run the workflow and the LLM returns a clean checklist of action items pulled from a real Google Doc you published — no credentials configured anywhere in n8n.

## Extension — if you finish early

- **Sheets, not Docs.** A published Google Sheet fetches as CSV at `.../export?format=csv`. Pair it with an Extract From File node and you have Bonus B1's tabular pipeline, fed live from Google.
- **Email the action items** to yourself (Ex 00 stage 3).
- **Summarise + extract in parallel** (Ex 05): one branch a TL;DR, another the action items, a Merge stitches them.
- **Write back (advanced).** To put the summary *into* a Doc, use the real Google Docs node with a Service Account credential (README has the steps).

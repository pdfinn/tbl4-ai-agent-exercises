# Bonus B1 — Tabular Data from an Uploaded File (variant)

A second live variant of Bonus B1. The data pipeline is identical; the **source** is a file the user **uploads** through a web form. This answers "is there a file-upload node?" — the **Form Trigger** node, with a field of type **File**, is n8n's upload mechanism. n8n hosts the upload page; the file arrives as binary.

Unlike the embedded (Set node) and Google Sheet variants, this lets a user bring their **own** file at run time — and since an importable workflow JSON can't carry a file attachment, upload is the natural way to do that.

## Files

| File | Use |
|---|---|
| `B1-b-half-built-form-upload.workflow.json` | Form front-end with 3 gaps: the file-field type, the binary property name, the readout prompt. |
| `B1-c-reference-form-upload.workflow.json` | Working live solution. |
| `sample-sales.csv` | A CSV to upload (same 10 rows as the embedded exercise). |

Do the embedded `B1-a/b/c` first (that's where Split Out and the pipeline are taught). This variant assumes the pipeline is understood and focuses on the upload front end.

## What changed vs. the embedded version

```
Embedded:     Manual Trigger → Set Input (array) → Split Out → Add Revenue Column → …
File upload:  On Form Submission (File field) → Parse CSV Into Rows → Add Revenue Column → …
```

- **On Form Submission** — a **Form Trigger** with one field, `fieldType: file`. n8n serves a hosted upload page (Test URL while building; Production URL once the workflow is activated). The submitted file lands as **binary data**.
- **Parse CSV Into Rows** — *Extract From File*, operation **CSV**, reading the uploaded binary. Emits **one item per row** (header row → field names). No Split Out, same as the Sheet variant.
- CSV values are strings, so the revenue/units columns coerce with `Number(...)` (same as the Sheet variant).

## How to run a Form Trigger

1. Click **On Form Submission** and open its **Test URL** ("Open form in new tab"). n8n shows the upload page.
2. Upload `sample-sales.csv` (or any CSV with `dish, stall, category, price, units_sold`).
3. Submit — the workflow runs. Click through the nodes to read the panels.

For a permanent public upload URL, **activate** the workflow and use the Production URL.

## ⚠️ The one version-sensitive detail: the binary property name

When a file is uploaded, n8n stores it under a **binary property** whose name depends on the field label and your n8n version (commonly the label with spaces replaced by underscores — e.g. `Sales CSV` → `Sales_CSV`).

**Don't guess — read it.** After your first test upload, click **On Form Submission**, open the **Binary** tab in the output panel, and note the property name. Then set **Parse CSV Into Rows → Input Binary Field** to that exact name. The reference guesses `Sales_CSV`; correct it if your version differs. (This is good practice anyway — read the output panel before trusting it.)

## The 3 gaps in the half-built (answer key)

1. **On Form Submission → "Sales CSV" field type** — change from `text` to **File** (optionally set Accepted File Types `.csv`).
2. **Parse CSV Into Rows → Input Binary Field** — the binary property name from the form output (e.g. `Sales_CSV`).
3. **Write Readout → prompt** — the readout prompt from `B1-c-reference.md`.

## Expected result

Same 10 rows → same answer: eight dishes pass `units_sold >= 40`, top earner **Chicken Rice** ($660), total **$2,985.50**.

## Teaching notes

- **Three sources, one pipeline.** Embedded array (offline), Google Sheet (shared link), uploaded file (Form Trigger) — all converge on the same Add Revenue → Filter → Sort → Aggregate → LLM spine. A clean way to show that *where data comes from* and *what you do with it* are separable concerns.
- **The binary tab.** Most students have never looked at the Binary tab. This is a natural reason to.
- **Multiple files.** If you switch the field to allow multiple files, the trigger outputs several binary properties; you'd Split/loop before Extract From File. Keep it single-file unless you want that discussion.

## Extension

- Add a second form field (a text "Minimum units" number) and wire it into the Filter threshold — now the uploader controls the cutoff.
- Email the readout back (Ex 00 stage 3) so the form becomes a self-service report tool.

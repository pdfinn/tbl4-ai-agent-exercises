# Bonus B1 — Tabular Data from a Google Sheet (variant)

A live variant of Bonus B1. The data pipeline is identical; only the **source** changes — instead of a table baked into a Set node, the rows come from a **shared Google Sheet**, fetched as CSV over plain HTTP. This is the same zero-credential trick as Bonus B3 (read a shared Doc), with `format=csv` instead of `format=txt`.

**No Google node, no OAuth, no API key.** Just link-sharing + the HTTP Request node.

## Files

| File | Use |
|---|---|
| `B1-b-half-built-google-sheet.workflow.json` | Front-end wired with 3 gaps: the sheet ID, the URL expression, the readout prompt. |
| `B1-c-reference-google-sheet.workflow.json` | Working live solution. |
| `sample-sales.csv` | Paste/import into a Google Sheet to get the same 10 rows the embedded exercise uses. |

The embedded `B1-a/b/c-reference.workflow.json` files stay as the **zero-setup / offline** path (and the place to first learn Split Out). Do those first; this variant assumes the pipeline is already understood.

## What changed vs. the embedded version

```
Embedded:  Set Input (array)  → Split Out          → Add Revenue Column → … 
Sheet:     Set Input (id+gid) → Fetch Sheet (HTTP) → Parse CSV Into Rows → Add Revenue Column → …
```

- **Fetch Sheet** — an HTTP Request to the Sheet's CSV export URL. Crucially, **Options → Response → Response Format = File** (binary), because CSV isn't JSON; we want the raw bytes.
- **Parse CSV Into Rows** — the *Extract From File* node, operation **CSV**, binary property `data`. It emits **one item per row**, using the header row as field names.
- **No Split Out.** Extract From File already produces one item per row, so the Split Out step from the embedded version isn't needed here. (Good discussion point: two different ways to arrive at "one item = one row".)

Everything from **Add Revenue Column** onward is byte-for-byte the embedded pipeline — with one tweak: CSV values arrive as **strings**, so the revenue/units columns wrap them in `Number(...)` (`={{ Number($json.price) * Number($json.units_sold) }}`). Worth pointing out: data from a CSV is untyped text until you coerce it.

## Setup (~2 minutes, one time)

1. Create a Google Sheet with the header row `dish, stall, category, price, units_sold`. Quickest: open a new Sheet → **File → Import → Upload** `sample-sales.csv`. (Or just type a few rows.)
2. **Share → General access → Anyone with the link → Viewer.**
3. From the Sheet URL, grab two values:
   `docs.google.com/spreadsheets/d/`**`SHEET_ID`**`/edit#gid=`**`GID`**
   - **SHEET_ID** → *Set Input → `sheet_id`*
   - **GID** (the tab; the first tab is `0`) → *Set Input → `gid`*
4. Run.

**If parsing fails or you see HTML:** the Sheet isn't link-shared — Google returned a sign-in page instead of CSV. Fix the sharing setting and re-run *Fetch Sheet* alone to confirm you get CSV bytes.

## The 3 gaps in the half-built (answer key)

1. **Set Input → `sheet_id`** — the shared Sheet's ID.
2. **Fetch Sheet → URL** — replace `SHEET_ID_HERE` with `{{ $('Set Input').item.json.sheet_id }}`.
3. **Write Readout → prompt** — same readout prompt as the embedded exercise (see `B1-c-reference.md`).

## Expected result

Identical to the embedded exercise (same 10 rows): eight dishes survive the `units_sold >= 40` filter, top earner **Chicken Rice** ($660), total **$2,985.50**.

## Teaching notes

- **Run node-by-node.** *Fetch Sheet* should show a binary `data` attachment; *Parse CSV Into Rows* should show 10 items. The #1 failure is an un-shared Sheet (HTML comes back, parsing chokes) — inspect the fetch before trusting it.
- **Same lesson as B3, different format.** Once students see Docs (`txt`) and Sheets (`csv`) both fetch from a shared-link URL, "connecting to Google" stops being mysterious — it's a URL and the HTTP node.
- **Strings from CSV.** The `Number(...)` coercion is the one real gotcha. Without it, `Sort` would order revenues lexicographically and the filter could misbehave.

## Extension

- Add a second tab to the Sheet and switch `gid` to read it — same workflow, different data.
- Point the embedded B2 (review classifier) at a shared Sheet of reviews the same way.

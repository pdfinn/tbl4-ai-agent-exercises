# Bonus B1 — Working with Tabular Data

*Instructor-facing overview. Student-facing instructions are in `B1-a-blank.md` and `B1-b-half-built.md`.*

A standalone bonus exercise, requested by students who wanted to see n8n handle spreadsheet-style data. It teaches the items model and the five everyday data nodes (Split Out, Set-as-computed-column, Filter, Sort, Aggregate) on a small, deterministic table — no credentials, no network.

## Learning goal

By the end students should:

- Internalise **one item = one row**, and read the item count in the output panel as the workflow reshapes the data (`1 → 10 → 8 → 1`).
- Add a **computed column** with a Set node (`revenue = price * units_sold`).
- Use **Filter** (the IF node's condition editor, minus the branches) and **Sort**.
- Use **Aggregate** to collapse rows back into one item before an LLM step — and understand *why* (a Basic LLM Chain runs once per item).
- Apply the rule **"nodes compute, the LLM narrates"**: arithmetic in expressions, prose in the prompt.

## Domain

Ten rows of hawker-stall daily sales (`dish`, `stall`, `category`, `price`, `units_sold`). The fixture is rigged so the unit-leader (Teh Tarik) is *not* the revenue-leader (Chicken Rice) — a deliberate hook for the "units ≠ revenue" discussion. Data is embedded in the Set node and also shipped standalone as `sample-sales.json`.

## The three artefacts

| File | Use |
|---|---|
| `B1-a-blank.workflow.json` | Manual Trigger + Set Input (table given) + 4 sticky notes. Students build Split Out → … → LLM. |
| `B1-b-half-built.workflow.json` | Full 7-node graph with 3 gaps: the revenue expression, the filter threshold, the readout prompt. |
| `B1-c-reference.workflow.json` | Working solution. Release at debrief. |
| `B1-b-half-built-google-sheet.workflow.json` | **Live variant.** Reads from a shared Google Sheet; 3 gaps (sheet ID, URL, prompt). |
| `B1-c-reference-google-sheet.workflow.json` | **Live variant.** Working solution sourcing from a shared Google Sheet. |
| `B1-b-half-built-form-upload.workflow.json` | **Live variant.** User uploads a CSV via a Form Trigger; 3 gaps (file field type, binary property, prompt). |
| `B1-c-reference-form-upload.workflow.json` | **Live variant.** Working solution; user uploads the CSV through a hosted form. |

## Recommended session flow (~40 min)

1. **(5 min) The items model.** Run variant A as-is. Click *Set Input* — one item, an array inside. Ask: "How many rows is that? How many items?" (One item, ten rows.) Then promise: "By the end, each row will be its own item, and we'll squeeze them back together."
2. **(5 min) Demo Split Out live.** Add one Split Out node, run, watch `1 → 10`. This is the whole concept; spend real time here.
3. **(20 min) Pair build.** Most pairs take variant B. Watch for the String-vs-Number trap on `revenue` (breaks Sort), and for pairs who forget Aggregate and get one readout per row.
4. **(5 min) Units vs revenue.** Run it. Top earner is Chicken Rice, not the best-selling Teh Tarik. Let them notice.
5. **(5 min) Debrief.** Release the reference. Land "nodes compute, LLM narrates."

## The 3 gaps in variant B (answer key)

1. **Add Revenue Column → `revenue`** = `={{ $json.price * $json.units_sold }}`, type **Number**.
2. **Keep Strong Sellers → rightValue** = `40`.
3. **Write Readout → prompt** — uses the two supplied expressions; instructs the model to narrate, not recompute. (Full example in `B1-c-reference.md`.)

## Common student errors

| Error | Lesson |
|---|---|
| `revenue` left as type String | Sort orders lexicographically ("510" before "85"). Types matter. |
| Skips Aggregate; Sort → LLM directly | The chain fires 8 times — eight partial readouts. Aggregate first. |
| Asks the LLM to total the column | Sometimes wrong. Compute with `.reduce()`, hand over the answer. |
| Reads `units_sold` as "best dish" | Units ≠ revenue. Read the question. |

## Live variant — Google Sheet

A self-contained, importable workflow can't carry a binary attachment, so the default table lives in a Set node (same approach as Ex 07's offline variant). The **Google Sheet variant** is the live counterpart: it fetches a shared Sheet as CSV over plain HTTP — the same zero-credential trick as Bonus B3, with `format=csv`. See `B1-google-sheet.md` for setup and notes; `sample-sales.csv` is the importable data.

The front end swaps `Set Input (array)` + `Split Out` for `Fetch Sheet (HTTP, response=File)` + `Parse CSV Into Rows` (Extract From File); everything from Add Revenue Column on is unchanged. Two wrinkles to teach: Extract From File emits one item per row (so no Split Out), and CSV values arrive as strings (so the revenue/units columns wrap them in `Number(...)`).

Run the embedded version first (it's where Split Out is taught and it needs no Google account); reach for the Sheet variant when you want a real external source or to bridge to Bonus B3.

## Live variant — file upload

A third source: the user **uploads** a CSV through a hosted web form. The front end is a **Form Trigger** with a field of type **File** (n8n's file-upload mechanism — there is no separate "upload node"); the file arrives as binary and Extract From File parses it. Lets a user bring their *own* file at run time. See `B1-form-upload.md`. The one version-sensitive detail is the uploaded file's binary property name — students read it off the Form Trigger's Binary tab and point Extract From File at it.

**Three sources, one pipeline:** embedded array (offline) · shared Google Sheet · uploaded file. All converge on the same Add Revenue → Filter → Sort → Aggregate → LLM spine — a tidy demonstration that the data source and the data processing are separable.

## Threads

- **Split Out / Aggregate** are the fan-out/fan-in nodes from Ex 07, isolated here.
- **Filter** is the IF node from the 02b warm-up with branches removed.
- Pairs naturally with **Bonus B2** (review classifier), which runs an LLM *per row* between the Split Out and the Aggregate.

## Import instructions

n8n → **Workflows → top-right menu → Import from File** → pick a `.json` from this folder. Confirm the Ollama Chat Model has the `Ollama (local)` credential after import.

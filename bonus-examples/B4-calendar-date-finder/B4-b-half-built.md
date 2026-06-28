# Bonus B4 — Check a Date, Else Find an Alternate (Half-Built)

Nine nodes are on the canvas, fully wired. The hard date expressions are done for you — study them. **Three fields need filling.**

## Gap 1 — the Tuesday candidate

**Compute Candidates → `cand_tue`** is blank. The `cand_mon` field right above it is your template:

```
={{ DateTime.fromISO($json.requested_date).plus({ days: (8 - DateTime.fromISO($json.requested_date).weekday) % 7 || 7 }).toFormat('yyyy-MM-dd') }}
```

`.weekday` is 1 = Monday … 7 = Sunday. Monday is weekday **1**, and `1 + 7 = 8` — that's the `8` in the Monday expression. Tuesday is weekday **2**. So copy the expression and **change the `8` to a `9`**.

## Gap 2 — the "is it free?" test

**Requested Date Free? → condition** is hard-wired to `={{ true }}`. That means every request looks free, so the workflow always confirms and never finds an alternate — run it and you'll see it confirm a busy date. Replace it with a real membership test: *is the requested date NOT in the busy list?*

```
={{ !$json.busy_dates.includes($json.requested_date) }}
```

(`.includes()` checks array membership; `!` flips it, so TRUE means "free".)

## Gap 3 — the reply prompt

**Compose Reply → prompt** is blank. Write a friendly 2-3 sentence reply that branches on the status:

- `confirmed` → confirm `{{ $json.requested_date }}` works.
- `alternate` → say the requested date is taken; propose `{{ $json.chosen_date }}` (a `{{ $json.chosen_weekday }}` afternoon).
- `none` → apologise, ask for more flexibility.

The fields you can use: `{{ $json.status }}`, `{{ $json.requested_date }}`, `{{ $json.chosen_date }}`, `{{ $json.chosen_weekday }}`.

## Given as worked examples — study these

- **Pick Alternate** chooses Monday if free, else Tuesday, else `none`, with a nested ternary.
- **Finalise** is where both branches rejoin (two connections into one node, like Ex 03's Translate) and where `chosen_weekday` is derived — *after* `chosen_date` exists, because a Set node can't reference its own sibling fields.

## Before you run

Click **Ollama Chat Model** and confirm the credential is `Ollama (local)`.

## Expected result

With the default input (`2026-06-03` busy, next Monday `2026-06-08` also busy), the workflow proposes **Tuesday 2026-06-09 afternoon**.

## Rule

No Code node. Date maths in expressions; the LLM only writes the reply.

## Extension

- Edit `busy_dates` to trigger all three outcomes (confirmed / alternate / none).
- Swap the busy list for Google Calendar's free/busy node — the logic stays identical.

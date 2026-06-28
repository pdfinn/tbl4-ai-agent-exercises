# Bonus B4 — Check a Date, Else Find an Alternate (Reference, annotated)

*For instructor debrief. Release after pairs have built it.*

## The graph

```
Manual Trigger
  └─ Set Input (requested_date, busy_dates)
       └─ Compute Candidates (cand_mon, cand_tue via Luxon)
            └─ Requested Date Free? (IF, boolean membership test)
                 ├─ true ─→ Confirm Requested ─┐
                 └─ false ─→ Pick Alternate ───┴─→ Finalise (chosen_weekday) ─→ Compose Reply (LLM)

Ollama Chat Model ── ai_languageModel ──→ Compose Reply
```

## Why this shape

- **It's Ex 03/04 routing, with a date predicate.** The IF gates on "is the requested date free?" exactly as Ex 03 gates on word count. The two branches converge at Finalise, the same idiom as Ex 03's Translate. Students who did the core patterns recognise the skeleton instantly; the only new thing is the date library.
- **Luxon does the arithmetic.** `DateTime`, `.weekday` (1–7), `.plus({ days })`, `.toFormat()` are all available inside `{{ }}` — no Code node. The "next Monday" formula `(8 - weekday) % 7 || 7` is given as boilerplate (like Ex 03's word-count expression); the learning is in *reading* it and adapting it to Tuesday.
- **No loop, by design.** "Find the next free slot" really wants a loop, which means a Code node — off-limits this early. We sidestep it: compute exactly two candidates (next Mon, next Tue) and choose between them with a nested ternary. Bounded, readable, loop-free. The `none` outcome is the honest admission that two candidates might not be enough — a natural lead-in to the loop discussion.
- **Why Finalise is a separate node.** A Set node evaluates all its assignments against the *input*; an assignment can't read a sibling assignment from the same node. `chosen_weekday` depends on `chosen_date`, so it must live one node later — after `chosen_date` is already on the item. This trips people up; the split makes it explicit.
- **Dates computed, prose generated.** Same rule as Bonus B1/B2: the workflow computes the date deterministically; the LLM only phrases the reply.

## The 3 gaps in variant B (answer key)

1. **Compute Candidates → `cand_tue`** — the `cand_mon` expression with `8` changed to `9`:
   `={{ DateTime.fromISO($json.requested_date).plus({ days: (9 - DateTime.fromISO($json.requested_date).weekday) % 7 || 7 }).toFormat('yyyy-MM-dd') }}`
2. **Requested Date Free? → condition** — `={{ !$json.busy_dates.includes($json.requested_date) }}`, operator *is true*.
3. **Compose Reply → prompt** — branches on `status`; proposes `chosen_date` / `chosen_weekday` on `alternate`.

## Expected result (with the fixture)

`busy_dates = ["2026-06-03", "2026-06-05", "2026-06-08", "2026-06-11"]`, requested `2026-06-03` (a Wednesday).

- Requested date is busy → false branch.
- `cand_mon` = `2026-06-08` (the next Monday) — also busy.
- `cand_tue` = `2026-06-09` (the next Tuesday) — free.
- Result: **status `alternate`, chosen_date `2026-06-09`, chosen_weekday `Tuesday`.** The LLM proposes a Tuesday afternoon.

## Demonstrate all three outcomes

| Edit to `busy_dates` | Outcome |
|---|---|
| Remove `2026-06-03` | Requested date is free → **confirmed** |
| Default (`…-03` and `…-08` busy) | Monday taken, Tuesday free → **alternate** (Tue 06-09) |
| Add `2026-06-09` as well | No Mon/Tue free → **none** |

Run all three live; it's the fastest way to show the routing actually routes.

## Common student errors

| Error | Lesson |
|---|---|
| Leaves the IF at `{{ true }}` | Every date "free"; it confirms busy days. Test with a known-busy date. |
| Puts `chosen_weekday` in Pick Alternate | A Set node can't read its own sibling field. It belongs in Finalise. |
| Re-summarises with the LLM doing date maths | Wrong eventually. Compute in expressions. |
| Uses `weekday` 0-indexed | Luxon is 1 = Monday … 7 = Sunday, not 0-based. |
| Forgets `|| 7` | When the requested day already is that weekday, `% 7` gives 0 and you'd return the same day. |

## Threads

- **Reuses the IF + convergence from Ex 03 and the routing mindset of Ex 04** — recognisable skeleton, new predicate.
- **The "compute, don't ask the LLM" rule** matches Bonus B1/B2.
- **Real Google Calendar** is the production upgrade: replace Set Input + the busy list with a Calendar free/busy node (Service Account or OAuth). The routing graph is untouched — the whole point of the exercise.

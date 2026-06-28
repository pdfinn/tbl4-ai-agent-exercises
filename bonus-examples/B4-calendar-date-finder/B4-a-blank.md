# Bonus B4 — Check a Date, Else Find an Alternate (Blank Starter)

Someone asks to meet on a date. If the calendar is free that day, confirm it; otherwise propose the next Monday or Tuesday afternoon that's open. This is the routing/gate pattern from Ex 03/04 applied to **dates** — and the new skill is n8n's built-in date library, **Luxon**.

## The pattern

```
Requested date + busy list → Compute next Mon & Tue → Free? ─┬─ yes → Confirm ──┐
                                                             └─ no  → Pick Alternate ┴→ Finalise → Reply (LLM)
```

## No real calendar — and that's deliberate

The "calendar" here is a `busy_dates` list in a Set node. Wiring up Google Calendar's free/busy node is a *credential* change, not a *logic* change — and the logic is the lesson. Once this works, swapping the busy list for a real calendar node is a small step (see the extension).

## What you've been given

- A **Manual Trigger** and a **Set node** with `requested_date` (`2026-06-03`) and `busy_dates`.
- Four sticky notes: the pattern, the build steps, the date expressions (paste-ready), and rules/extension.

## Build it

1. **Set ("Compute Candidates")** — carry `requested_date` and `busy_dates` through, then add `cand_mon` and `cand_tue` (next Monday / Tuesday after the requested date). Expressions are in the date-expressions note.
2. **IF ("Requested Date Free?")** — boolean condition `{{ !$json.busy_dates.includes($json.requested_date) }}`, operator *is true*. TRUE = the day is free.
3. **Set ("Confirm Requested")** on the TRUE branch — `status` = `confirmed`, `chosen_date` = the requested date.
4. **Set ("Pick Alternate")** on the FALSE branch — `cand_mon` if free, else `cand_tue`, else `none`.
5. **Set ("Finalise")** — both branches converge here (two connections into one node, as in Ex 03). Add `chosen_weekday` derived from `chosen_date`.
6. **Basic LLM Chain ("Compose Reply")** + **Ollama Chat Model** — write the friendly reply, branching on `status`.

## Luxon in one minute

- `DateTime.fromISO("2026-06-03")` parses a date string.
- `.weekday` is **1 = Monday … 7 = Sunday**.
- `.plus({ days: 5 })` adds days; `.toFormat('yyyy-MM-dd')` formats back to an ISO string; `.toFormat('cccc')` gives the weekday name ("Tuesday").

Next Monday strictly after the requested date is `(8 - weekday) % 7 || 7` days ahead (Monday is weekday 1, and 1 + 7 = 8). For Tuesday, use `9` instead of `8`.

## Rules

- **No Code node.** Luxon works inside `{{ }}` expressions.
- **Compute dates in expressions; let the LLM only write prose.** Date maths must be exact.
- **Test all three outcomes** by editing `busy_dates` (see the rules note).

## Success

With the given input, `2026-06-03` is busy and so is the next Monday (`2026-06-08`), so the workflow proposes **Tuesday 2026-06-09**. Remove `2026-06-03` from the busy list and it confirms the original date instead.

## Extension — if you finish early

- **Real calendar.** Replace the busy list with Google Calendar's free/busy node (needs a credential). The routing logic doesn't change.
- **Add a time.** `.set({ hour: 14 })` to propose "2pm".
- **Widen the search** to the following week when the result is `none`.

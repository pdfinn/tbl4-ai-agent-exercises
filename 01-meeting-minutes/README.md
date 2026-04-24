# Exercise 01 --- Meeting-minutes assistant

A two-part exercise on writing system prompts. You will build an AI assistant
that turns a raw meeting transcript into clean, structured meeting minutes.

The point of the exercise is not the output itself. The point is to feel what
a plain-prose system prompt does well, where it breaks down, and why adding
structure (Markdown or XML) fixes the breakdown.

## What you'll need

* Open WebUI running locally with any chat-capable model (Llama 3.2, Qwen3,
  Mistral, or similar --- 7B and above works best)
* The sample transcript in [`sample-transcript.md`](./sample-transcript.md)

## Part 1 --- Write a plain-prose system prompt

Write a system prompt *in plain English* that makes the model produce good
meeting minutes from a transcript. Your prompt should cover:

* **Role** --- what the model is
* **Output** --- what the minutes should contain
  (summary / decisions / action items / open questions)
* **Edge cases** --- what to do when an owner or deadline is missing, when
  a decision is ambiguous, when a participant walks something back
* **Style** --- tense, tone, spelling, whether to quote participants

Aim for ~100--150 words. Resist the urge to stop at a one-liner.

### Test it

1. Paste your system prompt into Open WebUI's *System prompt* field (under
   Settings --> Controls).
2. Send the sample transcript as a user message.
3. Read the output. Then **run it two more times**. Compare the three runs.

### What to notice

Between runs, watch for:

* The output format drifting (action items sometimes a list, sometimes prose)
* Missing fields (no "open questions" section if there weren't obvious ones)
* Invented owners or deadlines where the transcript was silent
* The model including side-chatter or opinions it was told to omit

Write down two or three concrete inconsistencies you saw. You'll need them
for Part 2.

## Part 2 --- Restructure with Markdown or XML

Take the **same** prompt you wrote in Part 1 and restructure it using either:

* **Markdown** --- headings like `## Role`, `## Output format`, `## Rules`,
  `## Style`; bulleted rules under each heading
* **XML tags** --- `<role>`, `<output_format>`, `<rules>`, `<style>`; rules
  as bulleted content inside each tag

You can also specify the output format itself with a template, e.g.:

```
## Output format

# Summary
<one paragraph>

# Decisions
- <decision 1>
- <decision 2>

# Action items
- **Owner:** <name>  **Due:** <date>  **Task:** <what>
...
```

### Test it again

1. Replace your Part 1 system prompt with the structured version.
2. Send the same transcript three times.
3. Compare to your Part 1 runs.

### What should change

* Output format is now stable across runs
* Missing owners are consistently marked `TBD` or `unassigned` instead of
  being invented or dropped
* A downstream script could actually parse the output into structured fields

This is the payoff: structure lets the model behave the same way every
time, which is what an *automation* needs.

## Reference prompts

Only look at these **after** you've written your own.

* [`reference-prompt-plain.md`](./reference-prompt-plain.md) --- a
  production-quality Part 1 prompt
* [`reference-prompt-structured.md`](./reference-prompt-structured.md) ---
  the same prompt restructured with Markdown
* [`reference-prompt-xml.md`](./reference-prompt-xml.md) --- the same prompt
  restructured with XML tags

## Going further

* Try both Markdown and XML versions. Which does your model follow more
  reliably? (The answer depends on the model family.)
* Add one more constraint to the rules --- e.g. "flag any action item that
  sounds urgent with `[URGENT]`." Does the model pick it up on first try?
* Feed the structured output into an n8n workflow that posts action items
  to a Slack channel or adds them to a spreadsheet.

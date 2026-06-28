# Bonus B5 — An Agent That Remembers You (Half-Built)

The full graph is wired and ready. **Three things are missing** — and they happen to be the exact three pieces that turn a forgetful chatbot into an agent with memory. Fill them in.

```
Message → Read Memory → Extract Memory → ASSISTANT (Agent) → Update Memory → Memory To File → Write Memory → Final
                                          [GAP 1: inject       [GAP 2: decide                   [GAP 3: where
                                           the memory]          what to keep]                    to save]
```

## The 3 gaps

**GAP 1 — Assistant → Options → System Message.** Right now it's empty, so the agent reads nothing and remembers nothing. Give it a short persona **and paste in the remembered facts**:

```
You are a friendly personal assistant with long-term memory. Here is what you
remember about this user from previous conversations (it may be empty the first time):

{{ $('Extract Memory').item.json.data || '(nothing yet)' }}

Greet them by name if you know it, build on what they've told you before, and answer
in 1-3 short sentences.
```

**GAP 2 — Update Memory → Text (prompt).** Empty. This is the "librarian" that decides what's worth keeping. Ask it to output the **complete** updated note list — durable facts only, one per line, merging the new exchange with the old. You'll reference:
- `{{ $('Extract Memory').item.json.data }}` — the old notes
- `{{ $('Set Input').item.json.user_message }}` — what they just said
- `{{ $('Assistant').item.json.output }}` — what the agent replied

**GAP 3 — Write Memory → File Name.** Empty. Save to the **same path Read Memory reads from**: `/data/shared/agent-memory.txt`. If read and write disagree, the memory never comes back.

## What's already done for you

- **Read Memory / Extract Memory** are wired, pointed at `/data/shared/agent-memory.txt`, and set to **Continue On Error** so a missing file on the first run doesn't halt the workflow.
- **Memory To File** already converts the new notes to a text file.
- The **Ollama Chat Model** already feeds both LLM steps.
- **Final** already surfaces `reply`, `memory_before`, `memory_after`.

## Test it

1. **Run #1:** leave the default *"Hi! I'm Mei…"* message. After the gaps are filled, run. **Final → `memory_after`** should list Mei + kopi stall + Tiong Bahru, and `./shared/agent-memory.txt` should exist on your host.
2. **Run #2 (the real test):** change **Set Input → user_message** to *"What should today's special be?"* — no name, no context. Run again. If GAP 1 is right, the Assistant greets Mei by name. That recall **is** the memory.

Seed the file once for a clean first read (optional):

```
cp agent-memory.seed.txt  /path/to/self-hosted-ai-starter-kit/shared/agent-memory.txt
```

## Common slip-ups

| Slip | Symptom |
|---|---|
| GAP 1 paste forgotten | Agent never greets by name; `memory_before` has facts but they're ignored. |
| Read/Write paths differ | `memory_after` looks right, but Run #2's `memory_before` is empty again. |
| Update Memory appends instead of rewrites | File keeps every line ever; duplicates pile up. |
| Storing chit-chat | Memory fills with "hello" and one-off questions instead of stable facts. |

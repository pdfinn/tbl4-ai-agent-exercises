# Bonus B5 — An Agent That Remembers You (Reference)

Working solution. Release at debrief.

## What it is

An **AI Agent** with **long-term memory** stored in a flat text file. Every run does three things in order: **read** the memory file, let the agent **answer using it**, then **write** an updated file back. Restart n8n or come back tomorrow — it still knows the user.

```
Message → Read Memory → Extract Memory → ASSISTANT (Agent) → Update Memory → Memory To File → Write Memory → Final
          (read file)    (binary→text)     answers using       (LLM rewrites    (text→binary)   (overwrite
          /data/shared/   the remembered    the remembered      the memory)                      the file)
          agent-memory.txt facts             facts
```

## The two ideas it teaches

1. **Memory is just text in the prompt.** The Assistant's System Message pastes in the remembered facts: `{{ $('Extract Memory').item.json.data || '(nothing yet)' }}`. The agent has no magic recall — it reads notes you handed it.
2. **Persistence is just a file.** Read at the start, write at the end. That single read/write wrapper is the whole difference between "forgets everything" and "remembers you."

## Why a separate "Update Memory" step

The Assistant *answers*; it doesn't decide what's worth keeping. **Update Memory** is the librarian: it takes the old notes + the latest exchange and rewrites the **complete** note list, keeping durable facts (name, business, location, goals) and dropping small talk. It overwrites the file rather than appending, so memory stays small and current. This mirrors how real assistant memory works — a model summarises salient facts into a store; it doesn't dump the whole transcript.

## Short-term vs long-term (say this out loud)

n8n ships a **Simple Memory** (Window Buffer) node you can hang off an Agent. That's **short-term** memory — it remembers the current chat, but it's volatile (gone on restart) and tied to one session. This exercise does **long-term** memory: durable facts in a file that survive restarts and new conversations. Production assistants use **both** — a chat buffer for the live conversation, a store for what matters long-term.

## The three artefacts

| File | Use |
|---|---|
| `B5-a-blank.workflow.json` | Manual + Set Input + Ollama model + 3 sticky notes. Students build the 7-node memory loop. |
| `B5-b-half-built.workflow.json` | Full graph with 3 gaps: System Message (inject memory), Update Memory prompt, Write path. |
| `B5-c-reference.workflow.json` | Working solution. |

## Setup

The starter kit mounts host `./shared` → container `/data/shared`. Seed the memory file once so the first read is clean:

```
cp agent-memory.seed.txt  /path/to/self-hosted-ai-starter-kit/shared/agent-memory.txt
```

Skipping it is fine — **Read Memory** and **Extract Memory** are set to *Continue On Error*, so a missing file just means "no memory yet" on the first run.

## Recommended session flow (~35 min)

1. **(4 min) Frame it.** "A chatbot forgets the moment the run ends. Watch this one not forget." Run #1, then Run #2 with a context-free message — the agent still greets Mei. *Then* open the graph.
2. **(5 min) Trace the loop.** Read → Extract → Agent → Update → Convert → Write. Point at where memory enters the prompt and where it leaves to disk.
3. **(18 min) Pair build** (from blank) or **fill the gaps** (from half-built).
4. **(4 min) Open the file.** `cat ./shared/agent-memory.txt` on the host. It's plain text. Demystifies "memory" completely.
5. **(4 min) Debrief.** Short-term vs long-term; per-user notebooks; when to use n8n's Simple Memory node instead.

## The 3 gaps in variant B (answer key)

1. **Assistant → System Message** — persona + `{{ $('Extract Memory').item.json.data || '(nothing yet)' }}`.
2. **Update Memory → Text** — "output the complete updated memory, durable facts only, one per line, merge new with old, ≤12 lines," over old memory + `user_message` + `Assistant.output`.
3. **Write Memory → File Name** — `/data/shared/agent-memory.txt` (must match Read Memory).

## Expected result

- Run #1 (`memory_before` empty): `memory_after` ≈
  ```
  - Name: Mei
  - Runs a kopi stall in Tiong Bahru
  - Wants help writing daily specials
  ```
- Run #2 with *"What should today's special be?"*: the reply addresses Mei by name and suggests a kopi-stall special — recall came entirely from the file.

## Common student errors

| Error | Lesson |
|---|---|
| Forgets to paste memory into System Message | The agent "has memory" wired but never reads it. Memory must enter the prompt. |
| Read and Write paths differ | Run #2's `memory_before` is empty — the file was written somewhere else. |
| Update Memory appends | File grows unboundedly with duplicates. Rewrite the whole list each turn. |
| Stores small talk / dates | Memory clutters with noise. Keep stable facts only. |
| Uses `.text` for the Agent output | The **Agent** node returns `output`; the **Basic LLM Chain** returns `text`. Don't mix them up. |

## Notes on the stack

- The **AI Agent** node runs here with only a chat model and no tools — that's fine; it behaves as a memory-aware responder. The moment you add tools, the same memory wrapper still applies.
- `llama3.1:8b` is non-deterministic — the exact wording of the stored facts varies run to run. That's expected; the *facts* should be stable.

## Import instructions

n8n → **Workflows → top-right menu → Import from File** → pick a `.json`. After import, confirm the **Ollama Chat Model** has the `Ollama (local)` credential and that **Read/Write Memory** point at `/data/shared/agent-memory.txt`.

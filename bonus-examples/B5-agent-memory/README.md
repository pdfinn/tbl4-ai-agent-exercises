# Bonus B5 — An Agent That Remembers You

*Instructor-facing overview. Student-facing instructions are in `B5-a-blank.md`, `B5-b-half-built.md`, and `B5-c-reference.md`.*

A standalone bonus exercise answering the recurring student request: *"show me an n8n workflow with an agent that uses memory."* It does so with the simplest honest mechanism — a **flat text file** read before the agent runs and written after — and uses the real **AI Agent** node so it's genuinely an agent, not a chain in disguise.

## Learning goal

By the end students should be able to:

- Use the **AI Agent** node (`@n8n/n8n-nodes-langchain.agent`) with the local Ollama model — the first time the course uses the Agent node rather than a Basic LLM Chain.
- See that **"memory" is just text injected into the prompt**, and **"persistence" is just a file** read at the start and written at the end.
- Read and write a flat file on disk with **Read/Write Files from Disk** + **Extract From File** + **Convert to File**.
- Separate *answering* (the Agent) from *deciding what to remember* (a dedicated "Update Memory" LLM step that rewrites, not appends).
- Distinguish **short-term** memory (n8n's Simple Memory / Window Buffer — volatile, per-session) from **long-term** memory (a durable store).

## The new primitives vs the rest of the repo

| Primitive | First appears here |
|---|---|
| **AI Agent node** | Yes — everything before used Basic LLM Chain. Agent output is `output`, not `text`. |
| **Read/Write Files from Disk** | Used (the read path mirrors B1's file handling; the *write* path is new). |
| **Convert to File** (text → binary) | New — needed to write a string back to disk. |
| **Continue On Error** | New — lets the first run survive a missing memory file. |
| **A read→use→write loop** | The conceptual core: the same shape behind every "agent with memory." |

## Domain

A one-person hawker assistant. The default message introduces **Mei**, who runs a **kopi stall in Tiong Bahru** and wants help with daily specials. Run #1 teaches the agent who she is; Run #2 (a context-free question) proves it remembered. Keeps the Singapore-hawker thread running through B1/B2.

## The memory mechanism, plainly

```
/data/shared/agent-memory.txt   ← a plain text file on the host (./shared)

read it → paste it into the Agent's System Message → Agent answers
       → an LLM rewrites the note list → write it back over the same file
```

No vector DB, no embeddings, no database. That restraint is the lesson: students leave understanding what memory *is* before they ever reach for something heavier.

## Why a separate "Update Memory" step (worth stating in class)

The Agent answers; it shouldn't also be trusted to maintain the store in the same breath. The dedicated step is a "librarian" that keeps durable facts and drops chit-chat, and **overwrites** the file rather than appending so it can't grow without bound. This mirrors real long-term-memory architectures (summarise salient facts into a store) far better than dumping transcripts.

## The three artefacts

| File | Use |
|---|---|
| `B5-a-blank.workflow.json` | Manual + Set Input + Ollama model + 3 sticky notes. Students build the 7-node loop. |
| `B5-b-half-built.workflow.json` | Full graph with 3 gaps: System Message (inject memory), Update Memory prompt, Write path. |
| `B5-c-reference.workflow.json` | Working solution. Release at debrief. |
| `agent-memory.seed.txt` | Optional seed to copy into `./shared/` for a clean first read. |

## Setup (do this once)

The starter kit mounts host `./shared` → container `/data/shared`. Seed the file:

```
cp agent-memory.seed.txt  /path/to/self-hosted-ai-starter-kit/shared/agent-memory.txt
```

It's optional — **Read Memory** and **Extract Memory** are set to *Continue On Error*, so a missing file on the first run simply means "no memory yet."

## Recommended session flow (~35 min)

1. **(4 min) Demo first, explain second.** Run the reference twice — second time with a context-free message — and let them see it recall Mei before you reveal the graph.
2. **(5 min) Trace the read→use→write loop.**
3. **(18 min) Pair build (blank) or fill the gaps (half-built).**
4. **(4 min) `cat ./shared/agent-memory.txt`.** Seeing the plain file demystifies "memory" entirely.
5. **(4 min) Debrief:** short-term vs long-term; per-user files; when Simple Memory is the right tool instead.

## The 3 gaps in variant B (answer key)

1. **Assistant → System Message** — persona + `{{ $('Extract Memory').item.json.data || '(nothing yet)' }}`.
2. **Update Memory → Text** — rewrite the complete note list, durable facts only, merge new with old, ≤12 lines.
3. **Write Memory → File Name** — `/data/shared/agent-memory.txt` (must equal the Read path).

## Common student errors

| Error | Lesson |
|---|---|
| Memory never pasted into System Message | Wired but unread — memory must enter the prompt. |
| Read/Write paths differ | Run #2 forgets again; the file went elsewhere. |
| Update Memory appends | Unbounded, duplicate-laden file. Rewrite each turn. |
| Stores small talk | Keep stable facts only. |
| `.text` on the Agent output | Agent returns `output`; Basic LLM Chain returns `text`. |

## Threads

- **Builds on B1's** file handling (Read/Write Files, Extract From File) and the repo's Ollama wiring.
- **First use of the AI Agent node** — a natural bridge to any future tools-and-agents material.
- **Pairs with the slides' memory discussion** — short-term (buffer) vs long-term (store).

## Import instructions

n8n → **Workflows → top-right menu → Import from File** → pick a `.json`. Confirm the **Ollama Chat Model** has the `Ollama (local)` credential and that **Read/Write Memory** point at `/data/shared/agent-memory.txt`.

# Bonus B5 — An Agent That Remembers You (Blank Starter)

Build a personal assistant that **remembers you between runs**. Not within one chat — *between separate runs, even after a restart*. The trick is the simplest one there is: keep a few notes in a plain text file. Read it before the agent answers; write it back after.

## The pattern

```
Message → Read Memory → Extract Memory → ASSISTANT (Agent) → Update Memory → Memory To File → Write Memory → Final
          (read file)    (binary→text)    answers using it    (LLM rewrites    (text→binary)   (overwrite)
                                                               the notes)
```

Two ideas carry the whole exercise:

1. **Memory is just text you put in the prompt.** The agent "remembers" because you paste yesterday's notes into its System Message.
2. **Persistence is just a file.** Read it at the start, write it at the end. That's the entire difference between a chatbot that forgets and an agent that doesn't.

## What you've been given

- A **Manual Trigger**.
- A **Set node** ("Set Input") with a `user_message`.
- An **Ollama Chat Model** node, ready to wire into your LLM steps.
- Three sticky notes with the build steps.

## Build it

1. **Read Memory** — *Read/Write Files from Disk*, **Read**, path `/data/shared/agent-memory.txt`. Set **On Error → Continue (regular output)** so the first run (no file yet) doesn't halt.
2. **Extract Memory** — *Extract From File*, operation **Text** (`text`), input binary field `data`. Now the notes are a string in `data`. Continue On Error too.
3. **Assistant** — an **AI Agent** node. Connect the **Ollama Chat Model** to its *Chat Model* input. Prompt = **Define**, text = `{{ $('Set Input').item.json.user_message }}`. In **Options → System Message**, give it a short persona **and** paste the memory: `{{ $('Extract Memory').item.json.data || '(nothing yet)' }}`.
4. **Update Memory** — *Basic LLM Chain* + the same model. Have it output the **complete** updated note list: durable facts only, one per line, merging the latest exchange with the old notes. Feed it the old memory, `{{ $('Set Input').item.json.user_message }}`, and `{{ $('Assistant').item.json.output }}`.
5. **Memory To File** — *Convert to File*, **Convert to Text File**, source field `text`.
6. **Write Memory** — *Read/Write Files from Disk*, **Write**, file name `/data/shared/agent-memory.txt` (**same path as Read**), binary field `data`.
7. **Final** — a *Set* node exposing `reply`, `memory_before`, `memory_after`.

## Rules

- **No Code node.** Everything is expressions and built-in nodes.
- **Read and Write must use the identical path.** Disagree and the memory never returns.
- **The agent only knows what you paste into its System Message.** No paste, no memory.
- **Rewrite, don't append.** Tell Update Memory to keep what's still true and add what's new, so the file doesn't grow forever.
- **Durable facts only** — name, business, goals. Not "hello" and not today's one-off question.

## Setup — the memory file

The folder `./shared` on your host is mounted into the container at `/data/shared`. Seed the file once so the first read is clean (optional — Continue On Error covers a missing file):

```
cp agent-memory.seed.txt  /path/to/self-hosted-ai-starter-kit/shared/agent-memory.txt
```

## Success

1. **Run #1** with the default *"Hi! I'm Mei…"* message → `memory_after` lists Mei, her kopi stall, Tiong Bahru. The file appears on your host.
2. **Run #2:** change `user_message` to *"What should today's special be?"* (no name, no context) → the Assistant still greets Mei. It only knows because it **read the file**.
3. Restart n8n, run again — the memory survives.

## Extension — if you finish early

- **Per-user notebooks.** Add a `user_id` to Set Input and build the path from it (`agent-memory-{{ $('Set Input').item.json.user_id }}.txt`). Now two people don't share one memory.
- **Compare to built-in memory.** Hang n8n's **Simple Memory** (Window Buffer) node off the Agent and watch it forget on restart — that's *short-term* memory; your file is *long-term*.
- **Forget on request.** If the user says "forget that," have Update Memory drop the matching line.

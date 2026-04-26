# Exercise 00 — Hello, AI

**The course opens here.** Before any data integration, any JSON extraction, any agent: first prove the AI works.

This exercise is structured differently from Ex 01–07. Instead of a blank / half-built / reference variant, it has **three progressive stages** — each stage adds exactly one node to the previous one. Students see the graph grow.

| Stage | Nodes | What you learn | Time |
|---|---|---|---|
| 1 — Say Hello | Manual Trigger, Basic LLM Chain, Ollama Chat Model | n8n can talk to a local AI model | ~10 min (mostly cold start) |
| 2 — AI Reads Data | + HTTP Request | You can dump a JSON blob into a prompt and let the LLM extract what you need | ~15 min |
| 3 — Email the Answer | + Send Email | End-to-end automation: data → AI → message in your inbox | ~15 min (Gmail App Password setup) |

Total: ~40 minutes. Three "I made something work" moments.

## Prerequisites

- Docker Desktop + Ollama running locally (via `tbl4-local-llm` setup).
- `llama3.1:8b` pulled (`ollama pull llama3.1:8b`).
- n8n running (via `tbl4-n8n` setup).
- The pre-seeded `Ollama (local)` credential in n8n (auto-installed by the tbl4-n8n init container).
- A personal Gmail account (for Stage 3 only — can be deferred).

## Pedagogical intent

### Why AI first, data second

This is a course on **AI agents and automation**. Students should hear the AI respond before they ever touch a JSON path. Stage 1 is deliberately useful-but-trivial: the LLM suggests three hawker dishes. No data flow, no extraction, no magic beyond "the model exists and I can talk to it."

### Why dump the JSON into the prompt

In Stage 2, the student fetches weather data and hands the **entire JSON response** to the LLM with a plain-English question. No `$json.items[0].forecasts[0]...` navigation. The LLM reads the JSON and answers.

This is not a shortcut or a simplification for beginners. It's a **real workplace pattern**. LLMs are good at parsing semi-structured data. For small API responses (under a few KB) this pattern is often the correct choice even in production.

Students who learn to do this first will carry the pattern into their jobs. Students who are forced to master JSON extraction before tasting any AI output often disengage.

### Why three tiny stages instead of one big exercise

Each stage ends with a visible, satisfying result:

- **Stage 1:** a list of hawker dishes in the execution panel.
- **Stage 2:** a one-sentence weather verdict in the execution panel.
- **Stage 3:** an email in your inbox.

Three wins in forty minutes beats one win in forty minutes.

## Instructor session flow

### Before class (5 min of prep)

- Run `ollama list` — confirm `llama3.1:8b` is present.
- Warm the model: `ollama run llama3.1:8b` → any prompt → exit. Otherwise the first Stage 1 run will hit a 30-second cold start and the class will think n8n is broken.
- Import all three stage JSONs into your own n8n so you have references ready.

### Stage 1 (~10 min)

1. Students import `00-stage-1-say-hello.workflow.json`.
2. They click on the **Ollama Chat Model** sub-node, confirm the credential is `Ollama (local)` and model is `llama3.1:8b`. If the credential isn't visible, the tbl4-n8n init container didn't seed — run the setup script.
3. Click *Execute Workflow*.
4. First run: wait. It WILL take 20–40 seconds if the model wasn't pre-warmed. Tell the class this out loud.
5. Look at the **Ask the AI** output panel — three hawker dish suggestions appear.
6. Encourage experimentation: change the prompt. Ask in a different language. Ask for five dishes instead of three. Ask for dishes near a specific MRT station.

### Stage 2 (~15 min)

1. Students open `00-stage-2-ai-reads-data.workflow.json` or build on Stage 1.
2. Core new concept: `{{ JSON.stringify($json) }}` inside the prompt. That expression is the entire "AI reads the JSON" trick. Say it out loud: "`$json` means the data that just arrived from the previous node. `JSON.stringify(...)` turns it into text we can put in the prompt. That's it."
3. Run the workflow. The answer should mention specific areas or conditions pulled from the actual forecast.
4. **Change the question.** Have students replace the prompt with different questions about the same data:
   - "Is it going to rain in Jurong?"
   - "Summarise the next two hours in three bullet points."
   - "Which region has the nicest weather right now?"
5. **Key teaching moment:** the LLM never sees the field names `items[0].forecasts[0].area`. It just sees the JSON as text and figures it out. *This is why you don't need to learn JSON paths first.*

### Stage 3 (~15 min)

1. Students open `00-stage-3-email-the-answer.workflow.json`.
2. The Gmail setup is the real time cost here (2FA + App Password generation). Walk through it with the class — don't leave students to figure it out individually.
3. Replace the placeholder emails in the Email Me node (From + To).
4. Create a new SMTP credential: user = personal Gmail, password = the 16-character App Password (NOT the Gmail password).
5. Run. An email arrives. Everyone celebrates appropriately.

## The "Using AI to help you read JSON" meta-skill

When Stage 2 clicks, students often ask: "Can I always just dump JSON into an AI prompt?"

Answer: **yes, but here's the upgrade path.** If the response is too big or you need the value in a non-prompt field (a filter threshold, a downstream expression), you need to learn JSON paths. For that, see `exercises/README.md` → *Using AI as your JSON copilot* for the prompt patterns students can use to get an AI to write the n8n expression for them.

This is the single most durable skill in the course for non-programmers.

## Variations the instructor can try

- **Different Stage 1 prompts:** "Translate 'Good morning, have you eaten?' into Malay, Tamil, and Mandarin" (showcases model multilinguality) or "Write a two-sentence welcome message for a Singapore AI workshop."
- **Different Stage 2 data source:** use `/environment/psi` instead of the forecast. Prompt: "Is the air quality healthy right now?"
- **Different Stage 3 channel:** students who've completed Ex 02 can swap Email for Google Sheets append (if they're on cloud n8n).

## Why this is not in the a/b/c format

The pedagogy from Ex 01 onwards uses blank / half-built / reference variants. Ex 00 deliberately doesn't — each stage is tiny enough that a blank variant is just "empty canvas" and a half-built variant is "fill in a trivial field." The value is in the **progressive assembly**, not in gap-filling. Students see the graph grow one node at a time; that IS the pedagogy for this exercise.

From Ex 01 onwards, the a/b/c pattern kicks in and stays for the rest of the course.

## Import instructions

From inside n8n: **Workflows → top-right menu → Import from File** → pick one of the `stage-N-*.workflow.json` files. After import, click on the **Ollama Chat Model** node and confirm the credential is attached (select `Ollama (local)` from the dropdown if not).

Run Stage 1 first. When it works, move to Stage 2. When that works, move to Stage 3.

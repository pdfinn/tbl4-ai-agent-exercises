# tbl4-ai-agent-exercises

Supporting exercises for the Vertical Institute *GenAI Automation and Agency*
course. Three groups of exercises:

- **Foundations** (00) — warm-up.
- **Prompt engineering** (01–02) — paste straight into Open WebUI; no n8n.
- **Workflow patterns** (03–07) — n8n workflows realising the four patterns
  from Session 4 (slides 2484–2612), culminating in a research agent that
  audits its own output against IC analytic standards.
- **Optional extensions** (08–09) — sub-agents and model comparison.

## Exercises

### Foundations

0. [Hello, AI](./00-hello-ai/) — three-stage warm-up. First LLM call, first
   HTTP fetch, first email, all in 40 minutes.

### Prompt engineering (Open WebUI)

1. [Meeting-minutes assistant](./01-meeting-minutes/) — write a plain-prose
   system prompt, then restructure with Markdown or XML and compare. (Two
   parts; chat-only, no n8n.)
2. [Research-agent prompt](./02-research-agent/) — write a system prompt that
   audits an intelligence briefing against four US IC analytic standards
   (ICD-203, ICD-206, ICS-206-1, ICD-208), grounding findings in specific
   rules. (Chat-only, no n8n.)

### Workflow primer (optional but recommended)

2b. [Workflow warm-up](./02b-workflow-warmup/) — three-stage primer that
    drills the n8n primitives (`{{ ... }}` expressions, cross-node references,
    the IF node, sub-node wiring) that the pattern exercises silently assume.
    Recommended before Ex 03 if students don't have heavy prior n8n
    experience. ~45 minutes.

### Workflow patterns (n8n)

Each exercise ships in three forms — `a-blank.workflow.json` (trigger only +
sticky notes), `b-half-built.workflow.json` (wired graph with 2-3 deliberate
gaps), `c-reference.workflow.json` (working solution).

3. [Pattern: Prompt Chaining](./03-pattern-chaining/) — summarise → quality
   gate → translate, with retry on the failure branch.
4. [Pattern: Routing](./04-pattern-routing/) — customer-support classifier
   into BILLING / TECHNICAL / GENERAL, three specialist branches.
5. [Pattern: Parallelisation](./05-pattern-parallel/) — document analysed by
   three parallel agents (summary / entities / sentiment), merged into a
   report.
6. [Pattern: Evaluator / Optimiser](./06-pattern-evaluator/) — generate draft,
   score, accept or critique-and-revise.
7. [Research Agent — final lab](./07-research-agent-n8n/) — combines all four
   patterns. Wikipedia-grounded research; output audited against simplified
   ICD policies; revise on audit findings. Uses simplified slide-style XML
   policies in `07-research-agent-n8n/policies/`.

### Optional extensions

8. [Policy Simplifier](./08-policy-simplifier/) — *optional*. A sub-agent that
   converts heavy schema XML into slide-style minimal-tag XML. Demonstrates
   LLM as document-format translator.
9. [Model Rodeo](./09-model-rodeo/) — *optional*. Compare LLMs on the same
   routing workflow. Shows in your hands why "tool use beats reasoning" for
   workflow agents (slide 2619). Skip if your machine can only hold one model.

## How to use

For chat exercises (00 stage 1, 01, 02): paste the system prompt into Open
WebUI's *System prompt* field, paste the user input as a chat message.

For n8n exercises (00 stages 2-3, 03 onward): import the `.workflow.json`
file via **n8n → Workflows → top-right menu → Import from File**. Confirm
the Ollama Chat Model has the `Ollama (local)` credential selected.

Each exercise has its own `README.md` with instructor notes (session flow,
gap answer key, common student errors), and student-facing `a-blank.md` /
`b-half-built.md` files that match the corresponding workflow JSON.

## Pedagogical principles

The course pedagogy emphasises:

1. **Build, break, repair.** Pre-built reference workflows are released only
   at debrief — students who watch demos retain less than students who
   debug. The `a-blank` and `b-half-built` variants force engagement.
2. **The output panel is the classroom.** n8n's defining feature is that
   every node shows its input and output. Teach reading the data panel
   first; everything else follows.
3. **Narrow prompts for workflow agents.** Slide 2846 — workflow-agent
   prompts are not chatbot prompts. They produce structured, reliable output
   that downstream nodes can trust.
4. **No Code node for the first three pattern exercises.** Forces fluency in
   the n8n expression language.

## Stack

- **Ollama** running locally (from `tbl4-local-llm` setup) with `llama3.1:8b`
  pulled.
- **n8n** running locally (from `tbl4-n8n` setup), pre-seeded with an
  `Ollama (local)` credential.
- **Open WebUI** for chat-only exercises (also from `tbl4-local-llm`).

No paid services. No API keys. No web access required for any exercise
except Ex 07 (Wikipedia, no auth).

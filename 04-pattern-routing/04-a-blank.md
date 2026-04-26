# Exercise 04 — Routing (Blank Starter)

Build the Routing pattern from the slides as an n8n workflow.

## The pattern

```
In → Classify ─→ Switch ─┬─ BILLING ─→ Billing specialist ─→ Out
                          ├─ TECHNICAL ─→ Technical specialist ─→ Out
                          └─ GENERAL ─→ General specialist ─→ Out
```

One LLM classifies the message; a Switch dispatches to a specialist branch; each branch has its own prompt tuned for that category.

## Your goal

Build a customer-support triage workflow:
1. Take a customer message as input.
2. Classify it as BILLING, TECHNICAL, or GENERAL.
3. Route it to the appropriate specialist (each branch is its own LLM call with a different system prompt).
4. Produce a draft response from the right specialist.

## What you've been given

- A **Manual Trigger** node.
- Four sticky notes: the pattern, the task, classifier prompt tips, the rules, an extension.

## Build it

### Inputs

A Set node with one field: `customer_message`. Hardcode something like "Hi team, my last invoice charged me twice for the Pro subscription."

### Pipeline

1. **Classify (Basic LLM Chain)** — produces ONE WORD output: `BILLING`, `TECHNICAL`, or `GENERAL`. Crucial: this prompt must be *narrow and specific*. Read the classifier-tips sticky note before writing.

2. **Route (Switch)** — three rules, one per category. Each rule's left value:
   ```
   ={{ $json.text.trim() }}
   ```
   Each rule's right value: the matching one-word category. Operator: *contains* (case-insensitive). Why `.trim()` and `contains`? Because LLMs sometimes append "BILLING\n" with a trailing newline.

3. **Three specialist Basic LLM Chains** — one per category. Each gets its own prompt:
   - `Handle Billing` — billing specialist persona, ask for invoice/order info
   - `Handle Technical` — technical specialist persona, ask for debug info
   - `Handle General` — generalist, friendly, suggest next steps

   Each prompt references the original message via `{{ $('Set Input').item.json.customer_message }}`.

### Models

- `llama3.1:8b`, credential `Ollama (local)`.
- One Ollama Chat Model sub-node feeds all four Chains. Connect it to each via `ai_languageModel`.

## Rules

- **No Code node.** Allowed: Set, Switch, Basic LLM Chain, Ollama Chat Model.
- **Test all three branches.** Change `customer_message` between runs:
  - "I was charged twice for my subscription" → BILLING
  - "The app crashes when I upload a file" → TECHNICAL
  - "Do you offer enterprise plans?" → GENERAL

## Why classifier prompts have to be narrow

A typical chatbot prompt: *"Help the user with their question."* That's wide open. The model can do anything.

A workflow-agent classifier prompt: *"Output exactly one word: BILLING, TECHNICAL, or GENERAL. Do not explain. Do not add punctuation. If unsure, choose GENERAL."* That's narrow on purpose. The Switch downstream needs a deterministic value to route on. If the model writes "I think this is a billing issue", the Switch can't match cleanly.

This is what the slides mean by "you're programming a step, not having a conversation."

## Success

You run the workflow three times with three different messages. Each routes to a different branch. Each specialist produces a noticeably different style of response.

## Extension — if you finish early

- **Add an URGENT category** for outages, security, data loss. Update the classifier prompt AND add a fourth Switch rule.
- **Sub-route inside Technical**: a second classifier asks Apple / Android / Web / Other and routes again. Patterns nest.
- **Replace Manual Trigger with a Form Trigger.** Anyone with the URL can submit a message and get a routed response.

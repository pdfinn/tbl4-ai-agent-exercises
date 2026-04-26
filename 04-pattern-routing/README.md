# Exercise 04 — Pattern: Routing

*Instructor-facing overview. Student-facing instructions are in `a-blank.md` and `b-half-built.md`.*

## Learning goal

Students realise the **Routing** pattern from the slides as a concrete n8n workflow. By the end they should:

- Understand a "narrow and specific" workflow-agent prompt — the classifier whose only allowed output is one of three words.
- Use the **Switch node** to dispatch on text values (not numbers).
- Recognise that *each branch deserves its own prompt*. Specialisation is what makes routing valuable.
- See how the same model (one Ollama Chat Model sub-node) can power four different "agents" by varying the prompt.

## Domain

Customer support triage. The classifier reads a message and chooses BILLING / TECHNICAL / GENERAL. Each branch has a specialist response prompt. Domain is universal — any organisation that takes inbound messages does this in some form.

## The three artefacts

| File | Use |
|---|---|
| `a-blank.workflow.json` | Manual Trigger + 5 sticky notes (pattern, task, classifier tips, rules, extension). |
| `b-half-built.workflow.json` | Full 8-node graph with three gaps: classifier prompt, Switch's GENERAL rule value, Technical handler prompt. |
| `c-reference.workflow.json` | Working solution. |

## Recommended session flow (~45 min)

1. **(5 min) Whiteboard.** Redraw the slide's diagram. Emphasise: *the classifier's output drives the routing*. If the classifier is sloppy ("This sounds like a billing issue"), the Switch can't match. The classifier prompt has to enforce a deterministic output.
2. **(5 min) Demo a sloppy vs. tight classifier.** Run the workflow once with a vague prompt ("classify this message") — show the long-form output that breaks routing. Then with a tight prompt — show the one-word output that works. *That's the lesson.*
3. **(25 min) Pair build.** Watch for:
   - Students forgetting `.trim()` on the Switch's left value. The LLM sometimes returns "BILLING\n" with a trailing newline; trim handles it.
   - Mismatched casing — the Switch is `caseSensitive: false` in the reference; students who flip that and use lowercase rule values get no matches.
   - Students writing long, cluttered specialist prompts. Specialist prompts should be focused: what does *this* role do that the others don't?
4. **(5 min) Try all three inputs.** Have students change `customer_message` to each of the slide's test messages: "I was charged twice", "The app crashes when I upload a file", "Do you offer enterprise plans?" Watch each route correctly.
5. **(5 min) Debrief.** Release reference. Compare specialist prompts. Highlight what makes a good narrow prompt (slide 2846).

## The 3 gaps in variant B (answer key)

1. **Classify prompt** — should be "narrow and specific":
   ```
   =You are a customer support classifier. Read the message and respond with EXACTLY ONE WORD from this list: BILLING, TECHNICAL, or GENERAL.

   Rules:
   - BILLING = anything about charges, refunds, invoices, subscriptions, plans, payments
   - TECHNICAL = bugs, errors, crashes, performance, integration questions
   - GENERAL = pricing inquiries, sales questions, anything else
   - If unsure, choose GENERAL.
   - Do not explain. Do not add punctuation. Output one word, in capitals.

   Message:
   {{ $('Set Input').item.json.customer_message }}
   ```

2. **Switch GENERAL rule rightValue** — `GENERAL` (matches the classifier's allowed output).

3. **Handle Technical prompt** — example:
   ```
   =You are a technical-support specialist. The customer has a technical issue. Ask for the specific information needed to debug (browser version, OS, exact error message, steps to reproduce), and offer a temporary workaround if you can think of one. Be calm and methodical. 4-6 sentences.

   Message:
   {{ $('Set Input').item.json.customer_message }}
   ```
   Anything that's measurably different from billing/general works.

## Progressive destruction prompts

- "Try a message that's clearly TWO categories: 'I was charged for the Pro plan but the app crashes when I try to use it.' Where does the classifier put it?" → Single-output classifier struggles. Lead-in to multi-label classifiers and parallelisation (Ex 05).
- "What if the LLM returns `Billing` (lowercase)?" → Show the case-sensitive trap; either fix in classifier prompt OR loosen Switch.
- "Add an URGENT branch for outages." → Both the classifier and the Switch need updates. Real maintenance lesson.

## Common student errors

| Error | Lesson |
|---|---|
| Classifier outputs prose, not one word | Prompt isn't narrow enough. Add "Output one word in capitals — do not explain." |
| Switch comparison is `equals` instead of `contains` | LLMs sometimes append punctuation or trailing whitespace; `contains` is forgiving. Trim is forgiving on the left side too. |
| Specialist prompts are too generic | If Billing and General read identically, you've defeated the routing pattern. Specialise. |
| Wires the Ollama Chat Model only to Classify | All four Chains need the model. One sub-node, four outgoing connections. |
| Doesn't test all three branches | The exercise looks done after one route works. Make them try three different messages. |

## Mapping back to the slides

- Slide 2520 (*"Pattern: Routing"*) — the abstract pattern.
- Slide 2846 (*"Prompting for workflow agents"*) — the narrow vs. chatbot-style prompt distinction.
- Slide 2998 (*"Exercise 2 — Routing workflow"*) — this exercise's source.

## Threads forward

- **Ex 05 (Parallelisation)** — same fan-out shape, different intent: split a task across parallel branches that all run, instead of routing to one.
- **Ex 06 (Evaluator/Optimiser)** — uses a classifier-style narrow prompt for the evaluator (output: number 1-10).
- **Ex 07 (Research Agent)** — routes drafts to either "publish" or "audit-and-revise" based on a quality classifier.

## Import instructions

From inside n8n: **Workflows → top-right menu → Import from File** → pick one of the `.json` files. After import, click on the Ollama Chat Model node and confirm the credential is `Ollama (local)`.

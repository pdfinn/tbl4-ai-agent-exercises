# Exercise 04 — Routing (Half-Built)

Eight nodes are on the canvas, fully wired. **Three fields are blank** — fill them in.

## Gap 1 — The classifier prompt

The **Classify** node has its prompt blank. This is the most important prompt in the workflow — get it wrong and nothing routes.

Write a *narrow and specific* prompt (slide-style) that:

- Tells the model it's a customer support classifier.
- Lists the exact allowed outputs: `BILLING`, `TECHNICAL`, `GENERAL`.
- Defines each category briefly.
- Provides a fallback ("If unsure, choose GENERAL").
- Constrains the output: ONE WORD, capitals, no punctuation, no explanation.
- References the message with `{{ $('Set Input').item.json.customer_message }}`.

This is the prompt that turns an LLM into a workflow component. Spend time on it.

## Gap 2 — The GENERAL rule

The **Route** node has three rules. The first two (`BILLING`, `TECHNICAL`) have their `rightValue` filled. The third rule's `rightValue` is blank.

Set it so messages classified as the third category route to the third branch. (Hint: the rule's `outputKey` is already named.)

## Gap 3 — The Technical handler prompt

The **Handle Technical** node has its prompt blank. Write a specialist prompt that:

- Establishes the model as a *technical-support specialist*.
- Asks for the right diagnostic info (browser, OS, exact error, steps to reproduce).
- Offers a workaround when the model can think of one.
- Tone: calm, methodical (not the warm tone of billing or the friendly tone of general).
- References the original message with `{{ $('Set Input').item.json.customer_message }}`.
- 4–6 sentences.

The other two specialist prompts (Billing, General) are already filled in — read them as templates.

## Test all three paths

Once your gaps are filled, run the workflow with each of these messages (change `customer_message` in the Set Input node between runs):

| Input | Expected route |
|---|---|
| "I was charged twice for my subscription" | BILLING |
| "The app crashes when I upload a file" | TECHNICAL |
| "Do you offer enterprise plans?" | GENERAL |

If a message routes to the wrong branch, the issue is almost always in your classifier prompt — not the Switch.

## Rule

No Code node.

## Extension — if you finish early

- Add an `URGENT` category for outages, security, data loss. Both the classifier AND the Switch need updates.
- Sub-route inside Technical: Apple / Android / Web / Other.
- Replace the Manual Trigger with a Form Trigger.

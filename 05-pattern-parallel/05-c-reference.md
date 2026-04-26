# Exercise 05 — Parallelisation (Reference, annotated)

*For instructor debrief. Not to be released until all pairs have completed.*

## The graph

```
Manual Trigger
  └─ Set Input (document)
       ├─→ Summarise               (Basic LLM Chain — prose)
       ├─→ Extract Entities         (Basic LLM Chain — structured)
       └─→ Classify Sentiment       (Basic LLM Chain — one word)
                                       │
                                       ├──→ Merge Results (slot 0/1/2)
                                       │
                                       └──→ Compose Report (Set, cross-node refs)

Ollama Chat Model
  └── ai_languageModel ── (fans out to all three Chains)
```

## Why this shape

- **Set Input fans out to three Chains via a single connection with three targets.** This is how n8n expresses "send the same input to N nodes." One outgoing connection, three target nodes.
- **Three branches, three prompt styles.** Summary is prose, Entities is structured, Sentiment is one word. The diversity of output contracts is the whole pedagogical point — same input, three legitimate ways to use an LLM, each with its own prompt discipline.
- **Merge node with `Number Of Inputs: 3`.** This is the new node config of the exercise. Without it, Merge defaults to 2 inputs and one branch is orphaned.
- **`combineByPosition`.** Each input slot's first item pairs with the others' first items, producing one merged item. (`append` would produce three items in a stream; `multiplex` would compute combinations; we want the simplest *one-item-from-each-input-stitched-together*.)
- **Compose Report uses cross-node references, not the merged item directly.** The Merge produces a combined item, but the simplest way to template the final output is to reference each branch by name. Both styles work; the cross-node pattern is more readable.

## Points to surface at debrief

1. **Each parallel branch is itself a workflow agent.** Three different prompts → three different "agents" → three different output contracts. The Merge is what makes them composable.

2. **Output contracts.** This is where students see why a structured output prompt (Entities) matters: downstream code needs to parse it. A free-form prose response from the Entities branch would force the Compose Report to *also* be free-form. Discipline at the boundary keeps the pipeline maintainable.

3. **Logical vs. runtime parallelism.** In n8n v1 execution, the three "parallel" branches actually run sequentially on the same Ollama instance. The graph is parallel; the runtime is not. Worth explicit acknowledgment so students don't expect a 3× speedup. (In production with cloud LLMs or multiple Ollama instances, true concurrency is achievable.)

4. **One Ollama Chat Model sub-node serving three Chains.** Same as Ex 03 and 04. The model is loaded once; three Chains use it.

## Common student errors

| Error | Lesson |
|---|---|
| Wires all three branches to Merge slot 0 | Each branch needs its own slot. Set `Number Of Inputs: 3` first. |
| Forgets to set Number Of Inputs (defaults to 2) | One branch can't connect; workflow is broken. |
| Uses one generic prompt for all three branches | Defeats the parallelisation. Specialise. |
| Compose Report runs three times | Merge mode is wrong (probably `append` or default). Use `combineByPosition`. |
| Sentiment returns prose instead of one word | Prompt isn't narrow. Add explicit constraints. |
| Compose Report references the wrong node names | Name-references are case-sensitive and exact. `$('summarise')` ≠ `$('Summarise')`. |

## Progressive destruction prompts

- **Add a fourth branch (translation).** Update Merge to 4 inputs. Show how the pattern extends naturally.
- **Replace a branch with a non-LLM node.** Swap Sentiment for an HTTP Request to data.gov.sg. The Merge doesn't care — it combines anything. Pattern is generic.
- **What if one branch fails?** Disable Ollama mid-run, see what happens. Lead-in to error handling and graceful degradation.

## Mapping back to the slides

- Slide 2551 (*"Pattern: Parallelisation"*) — the abstract diagram, this exercise's source.
- Slide 2846 (*"Prompting for workflow agents"*) — three different narrow prompts in the three branches.
- The "Document → Summary / Entities / Sentiment" example in the slide (slide 2567 in the diagram) maps directly to this workflow.

## Threads forward

- **Ex 06 (Evaluator/Optimiser)** uses two parallel calls (generate + evaluate) inside an iteration loop.
- **Ex 07 (Research Agent — final lab)** uses parallelisation for the multi-query search step. The pattern shows up there with a different domain.

## On the runtime-order honesty

This is the first exercise where the slide's promised behaviour ("run simultaneously") doesn't quite match n8n's actual execution. Naming this clearly at debrief is important — students who are surprised later (e.g., when they assume parallel = faster) will doubt the rest of the curriculum.

The honest framing: *the pattern is logical parallelism — it tells you how the work decomposes. Whether the runtime serialises or actually runs concurrently is a deployment detail. In single-user local setups, expect serialised. In production with proper concurrency, expect parallel.*

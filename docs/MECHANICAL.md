# As mechanical as it can be

The workbench is built while a large model, reached through an API,
does its reading. That is scaffolding, not the design. Every place a
model is called writes a plain file another tool reads (a logic file,
a yes or no, a list of senses), so each can be done instead by rule, or
by a small model trained for the one job, without the tools around it
knowing: composition is what makes the scaffolding removable. A rule or
a small model is cheaper, faster, the same each time, runs where there
is no network, and can be read. The Writer's Workbench already works
this way: its tagger is an averaged perceptron and its parser a small
biaffine network, each trained once and shipped as weights.

The rule here: **every model call has a mechanical baseline, run
through the bench**, and is replaced when the bench says the
replacement is as good. The bench ([bench/](../bench/)) is the judge:
its gold set, held-out sets and hand judgements are the regression
tests any replacement must pass.

## The calls, and what could do each

| Call | Now | Mechanical, or a small model | What is on hand to build and judge it |
|---|---|---|---|
| Who a sentence reports (`says`) | in every reading | **Done by rule:** `phil/says` (tagger, `/lib/words`, patterns). It names the same person in 10 of 14 passages the readers marked, and found three reports they missed. Left: groups with no reporting verb, reports carried into later sentences. | 43 attributions checked by hand; [RESULTS.md](../bench/RESULTS.md) |
| What kind a premise is (`kind`) | in every reading | **A rule first:** `phil/kind` (an ought or necessity in the formula, then words of duty and virtue, of meaning and definition, of observing, then the past tense). On the 278 gold and breadth readings it tags 741 premises; where the reader tagged one too, they agree on 165 of 245 (67%). The disagreements turn on what a claim says, not its words ("people praise X" is about people; Berkeley's "perceived" is his thesis): a small classifier, trained on judged examples, is the next step | 40 premises drawn for a person to judge, `bench/kind/sample.tsv`: which of reader and rule is right, and the first labels |
| Whether a sentence is true in a situation (`settle`) | one call a disagreement | Textual entailment: a small model, or an NLI model, does it | 362 questions and answers in the breadth run, to measure a small model's agreement |
| Whether a claim is in one sense or two (`senses`) | one call a run | The prover first narrows the question to the claims the argument turns on; the rest is word-sense disambiguation, which contextual embeddings do cheaply | 30 judged runs; 1,112 breadth claims answered one sense |
| Where scope turns (`scope`) | none | **Done by rule:** the prover writes both readings | — |
| What a text claims (`claims`), and its argument (`argue`) | most of the cost | The hard core. A rule can write the skeleton (if, only if, unless, not, every, therefore) from wwb's parse, leaving a model only the atoms; or a small model can be trained on the readings already made, those the prover's checks passed and independent readers agreed on | about 3,300 readings, each with its prover verdict, faithfulness checks and agreement across readers, and its model, prompt and date |
| Joining a long work's parts (`argue -w`) | one or two calls a work | As for `argue` | — |

## The order

1. Rules where the language is regular enough: `says` (done), `kind`
   (a rule done; its judging under way).
2. Small trained models where the question is narrow and the data is
   already here: `settle`'s yes or no, `senses`. They can be trained on
   the large model's answers and judged on the bench, cheaply, on a
   small machine (the NVIDIA Jetson in [STATUS.md](STATUS.md)).
3. The reading itself: the skeleton by rule, then a small model trained
   with the prover as its judge, for exactness: a reading the prover
   cannot read, that the faithfulness checks reject, or that independent
   readers do not agree on, is not a good one. Whether such a model
   reads as well on texts it was not trained on is what the held-out
   sets are for.

Each tool keeps its own way to a model (`wwb/ask`'s ways: the API, a
local model, `/mnt/llm`, a command), so a small model for `senses` and a
large one for the reading can be used side by side while the change is
made; that is configuration, not code.

## What is not on the roadmap

A local agent keeping the workbench's notes, or a graph database. The
research agent owns its research, its notes included, and the corpus
is already a set of files: claims with stable ids, who holds and who
reports each, findings at their sentences. Served as a file tree, that
is the graph; see the issue on notes.

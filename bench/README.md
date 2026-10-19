# The bench: the tools on primary texts of philosophy

Three sets of passages, read by a model through `phil/argue` and judged by
rule, to measure what the tools do on philosophy as it was written, not on
test sentences. Every passage is from a Project Gutenberg edition whose
author and translator died more than seventy years ago, so that the texts
are in the public domain beyond the United States as well; each names its
ebook. Project Gutenberg's header, footer and trademark are not included.

| Set | What | Measures |
|---|---|---|
| `gold/` | 26 canonical arguments, each with what the literature says is wrong with it, or that it is valid as stated | whether a run finds the known fault at its sentence (located), finds something amiss elsewhere (detected), or misses it; and, for the valid ones, false alarms |
| `breadth/` | 100 argumentative paragraphs, four from each of 25 works from Plato to William James, drawn by a fixed seed | where there is no gold: whether runs agree, how far readings agree, how often a passage cannot be read, what is marked as reported and of what kind |
| `pairs/` | three commentaries with the passages of their source they report: Berkeley on Locke, Mill on Kant, Sidgwick on Mill | whether `phil/corpus` holds the commentary's reports to the source's own text |

## The gold set

Each `gold/<id>.md` is a passage, and `gold/<id>.gold` says where it is
from, its class, the sentence the fault is at (`at`, by the number
`wwb/sentences` gives it), the fault in words, and where the literature
says so. The classes:

- **inference**: the fault is in a step (a quantifier shift, composition,
  modal scope, an unstated premise, question-begging, an intensional
  fallacy). The tools decide inference, so they should find it, and at
  its sentence.
- **equivocation**: one word in two senses. The tools see it only if a
  reader gives the two senses two atoms; a hard case, scored apart.
- **valid**: valid as stated; what the literature disputes is a premise,
  which no prover decides. The tools should say valid: anything else is a
  false alarm.

Seven passages are a single sentence, where locating a fault at its
sentence means only that something was found. Gold for an argument is a
reading of it too; the references say whose.

## Running

```sh
export ROOT=/path/to/infernode
bench/run.sh bench/gold results/gold            # argue -n 3 -k 3 on each, 8 at a time
python3 -I bench/score.py bench/gold results/gold
RUNS=2 bench/run.sh bench/breadth results/breadth
python3 -I bench/survey.py bench/breadth/SOURCES results/breadth
bench/pairs.sh bench/pairs results/pairs        # then results/pairs/*/corpus.out
```

`$WWBMODEL` and `$MODEL` choose the model, as for `./phil`. The passages
are rebuilt from the Gutenberg texts by `tools/` (`fetch.sh`, then
`build.py`, `breadth.py`, `pairs.py`, with `PG` naming the texts'
directory); `tools/gold.py` is the gold set's specification.

Results, with the model, the prompt's hash and the date, are in
[RESULTS.md](RESULTS.md).

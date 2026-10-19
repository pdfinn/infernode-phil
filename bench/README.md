# The bench: the tools on primary texts of philosophy

Sets of passages, read by a model through `phil/argue` and judged by
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
| `heldout/`, `heldout-scope/` | five equivocations and four scope shifts, each named by the literature, read by no one while the tools that find them were written | the same as the gold set, on passages the tools were not shaped on |
| `planted/` | 12 short passages written here, each with a fault built into it (an unstated premise, the converse, a quantifier shift, modal scope, a word in two senses) or valid as stated, and each with its encoding (`<id>.key.logic`) | the same as the gold set, on faults no commentary names, so that a model cannot have read them in training |

Every gold file says whether its fault is the literature's (`known
canon`) or was built here (`known planted`), and `score.py` counts the
two apart. The held-out sets are held out from the tools' development,
not from the models' training: their faults are in the literature too,
and they are canon. Only `planted/` is held out from training. The
planted passages are this repository's own writing; each key is
checked by `tests/cases/planted` to prove as its class says (valid,
or invalid as stated; an equivocation is valid on one sense).

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
bench/run.sh bench/planted results/planted
python3 -I bench/score.py bench/gold results/gold bench/planted results/planted   # canon and planted apart
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

## Next

What the bench lacks to be a test rather than a development result, in
the order each closes the most (STATUS.md, items 5 and 6).

1. **A second judge.** `results/gold-judged.tsv` and `kind/sample.tsv`
   judged by a second person who did not write the gold; agreement
   reported as Krippendorff's alpha with the number and the band, not a
   pass; disagreements kept as a third column.
2. **Two model families in one run.** `run.sh` takes two `$WWBMODEL`s
   and binds each in turn at `/mnt/llm`, so each gold passage has
   readings from both; `score.py` and RESULTS.md report agreement
   within a model and across models apart, and a fault found by one
   family only is listed.
3. **Canon and held-out scored apart.** Each `gold/<id>.gold` says
   whether its fault is in the standard literature (Kenny, Geach,
   Moore, the commentaries named) or planted here; RESULTS.md gives
   found-in-canon and found-in-held-out as two numbers, since a reader
   blinded to the corpus is not blinded to its training (THREATS.md).
4. **Keyed sets from outside the project**, each under its licence,
   share-alike in its own directory:
   - forall x: Calgary (CC BY 4.0) with its solutions booklet:
     symbolization exercises with a key, so `argue`'s atoms and
     formulas are scored against an answer and `prove`'s verdict
     against the key's;
   - the Open Logic Project's exercises (CC BY), for `prove` on
     first-order fragments and where it says `undecided`;
   - FOLIO with its corrected labels (arXiv 2606.02837), for `prove`
     against solver-verified items;
   - Benzmüller's ontological-argument benchmark, 294 theorems and 45
     non-theorems in TPTP (arXiv 2609.26806), for `prove -t` on the
     fragment it reaches, coverage stated;
   - the Microtext corpus and SemEval-2018 Task 12, for
     `argue/missing` against the published enthymeme results (Feng and
     Hunter, COMMA 2026, code released);
   - DeepA2 and Argunauts' solver-checked reconstructions (CC BY-SA,
     Apache), for `argue` against expert encodings under shared atoms.
   SEP's reconstructions and the open-access journals under NC-ND are
   used locally and never redistributed; what is published is the
   citation and this repository's own encoding.
5. **Texts after 1910 and outside English translation.** The
   Gutenberg sets are nineteenth-century translation (Chase, Jowett,
   Elwes, Meiklejohn): what is measured is the tools on those
   sentences. The owner's own work (the dissertation run in
   `philosophy-dissertation/analysis`) and open-access papers used
   locally are the held-out set for modern prose.
6. **Decoding settings in every provenance line**, so a run can be
   described as the 2026 reproducibility guidance asks.

Each item is a change to `run.sh`, `score.py` or a `.gold` file and a
section of RESULTS.md, and none changes a tool.

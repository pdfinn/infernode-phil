# Making prove faster without changing what it says

A record of the work on `wwb/prove`'s speed: the rule it was held to, how
that was checked, what was changed, what was tried and gave nothing, what
was turned down and why, and what is left. Read it before trying to make
`prove` faster, so as not to try the same things again. The numbers are in
`tools/prove-bench/README`.

## The rule

Nothing `prove` says may change: no finding, no explanation, no
counterexample, no TPTP. Its virtues are the reason it exists beside Z3, E
and Vampire, so a speed-up that costs one of them is not taken:

- **Exact verdicts.** Valid, invalid, or `argue/undecided` when it cannot
  tell. Never a guess.
- **Explanations in the text's own words.** The case that refutes, the
  fallacy's name, the missing premise, the premises not needed, the ones
  that contradict.
- **The plainest counterexample.** The first case in atom order with each
  atom tried true first, told only as far as it needs to be ("and nothing
  else is true").
- **Self-contained.** Limbo on Dis, inside InferNode, bare metal
  included. No external solver.
- **Small and auditable.**

## How a change is checked

```sh
python3 -I tools/prove-bench/gen.py /tmp/args 1          # 635 arguments
python3 -I tools/prove-bench/stress.py /tmp/stress        # growing sizes
cp /tmp/stress/*.logic /tmp/args/    # leave out the largest; see below
tools/prove-bench/same.sh /tmp/args /tmp/before          # on the old build
# change prove; mk install in appl/cmd
tools/prove-bench/same.sh /tmp/args /tmp/after
tools/prove-bench/same.sh -c /tmp/before /tmp/after      # must say 0 differ
```

Run `tests/run.sh` and every `tests/*_test.sh` as well. The run in October
2026 used 953 files: gen.py's 635 less its cnf30 and cnf40, plus stress
files up to chain-800, wide-1600, cnf-75, steps-800, objs-800 and nest and
paren to 1000. Two rules for the comparison:

- **Take the baseline before installing anything new.** `run.inferno`
  loads `dis/wwb/prove.dis` for each file, so installing in the middle of
  a run mixes the two builds.
- **Time on a quiet machine.** Running alongside another emulator has
  more than doubled times, and a benchmark run under load once gave a
  wrong comparison with Vampire, which had to be withdrawn. Times inside
  one long emulator run also creep up as its heap fills (wide-1600: 150 s
  in the bench run, 24 s alone), so time single files with a fresh `emu`
  each.

**Find the cost before fixing it.** Twice the obvious cause was wrong (see
"Tried, and no help"). Put `sys->fprint(sys->fildes(2), "T %s %d\n", tag,
sys->millisec())` between phases (`readlogic`, `faithful`, `lint`, `check`
and its parts), count decisions, conflicts and propagations in `solve`,
measure, then take the prints out.

## Why outputs can stay the same

`prove` asks the solver two kinds of question:

1. **Whether**: does this follow, can these all be true together.
   `satisfiable`, `entails`, and the askers. The answer is a fact of logic,
   so any correct method gives the same one, and these questions can be
   answered any way at all.
2. **Which case**: `sat`, for the counterexample, and for `compare`'s
   situations. The case depends on the order of the search. Its search
   must decide the same variables in the same order with the same phases,
   though how it finds them can change.

So a change to (1) needs only to be correct. A change to (2) must show the
search makes the same decisions.

## What was done (October 2026)

| Change | Kind | Why the output is the same | Gain |
|---|---|---|---|
| Clause learning (CDCL), replacing the plain search (a9e81e1) | which case | Decides atoms in order, true first, with no restarts until 10,000 conflicts: the first model in that order, as the plain search found | chain-160 13.7 s to 0.24 s |
| S5: one atom per modal subformula, defined once | encoding | The same models over the statements' atoms | Out of memory to 0.06 s |
| `sat` numbers only the atoms its formulas use, in order | which case | An atom no clause holds is only ever decided true, at a level nothing follows from: the same search over the rest, and the same case (atoms unused but before the last needed one are reported true, as before) | Every small question had been the size of the whole vocabulary: wide-1600 150 s to 2.3 s |
| `satisfiable` apart from `sat` | whether | Builds no case (building one costs the vocabulary) | Small |
| Askers: one solver for many questions under assumptions (MiniSat's), each formula behind a guard of its own; a premise once looked at fixed on or off for good | whether | Yes or no only | Gains only with the next change |
| An asker counts only the atoms of the formulas it is given | whether | Atoms found by halving a sorted array | steps-800 15 s to 1.1 s |
| `choose()` starts where every variable before it is known to be set (lowered on backtracking) | which case | The same variable it would have found from the start | kd-105 (25,394 variables) 84 s to 25 s |
| Grounded labelling over attacks and supports indexed once | dialectic | The grounded labelling is the least fixpoint, whatever order it is found in | objs-800 10.6 s to 0.3 s |
| Atoms, predicates and names found by hash | reading | The same index, the same order of duplicates | Reading 6,400 premises 1.3–2 s to 0.12–0.27 s |
| Steps' supports and edges indexed once (a78defe) | structure | The same graph | steps-200 40 s to 0.3 s |

The whole set: 396 s to 74 s, every output the same. Where each stress
family now breaks is in the README.

## Tried, and no help

- **The askers alone.** The first guess was that the explanations
  (`minsupport`, `mincore`, `missing`), asking one question per premise,
  were the square. Moving them to one incremental solver changed nothing
  measurable. The square was in the many small questions of `lint` and the
  circularity check, each sized to every atom. The askers paid off only
  after the sizing was fixed. Measure first.
- **Hashing atom names alone.** Thought to be the cost of reading 6,400
  premises; it was not. The duplicate-name check and `predof`, both walks
  down a list, were. All three are hashed now.

## Considered and turned down

- **Unsatisfiable cores in `minsupport` and `mincore`.** When a trial set
  is still inconsistent, drop everything outside the core at once: far
  fewer questions. **Turned down: it can report a different smallest set.**
  Suppose the conclusion follows from P1 alone or from P2 and P3, in order
  P1, P2, P3. Dropping one at a time keeps a set that depends on that
  order; a core can drop a premise the plain loop would have kept, and
  keep one it would have dropped. The finding (`argue/unused`) would
  change.
- **Model rotation** (Marques-Silva): from a model of a trial set, find
  other premises that must be kept without asking. It is exact (a premise
  needed now is needed in every subset tried later), so it would keep the
  findings. Not done: it adds code to the solver for a gain that shows
  only past thousands of premises. Do it if that ever matters.
- **Restarts and activity from the start.** These are what industrial
  solvers do, and they would carry the random 3-CNF further. **Turned down:
  they lose the plainest case**, unless the case is shrunk again
  afterwards, and no argument in prose is that kind of search. They are
  used only after 10,000 conflicts, where the ordered search would not
  finish anyway.
- **Chronological backtracking or trail saving** (Nadel and Ryvchin 2018;
  Hickey and Bacchus 2020). The ordered search redoes its decisions after
  each backjump (kd-105: 670 conflicts, 750,000 decisions a question).
  Both techniques keep decisions that a backjump would undo, and, done
  right, still find the first model in order. Not done yet: they change
  `analyze` and `backtrack`, the core of the solver. A candidate, under
  `same.sh`.
- **Cone of influence for modal frames.** Put into clauses only the
  definitions that reach the question's atoms. Sound, but the worlds are
  shared through the base atoms, so little would be cut, and it could move
  the case. Not done.
- **Handing modal formulas to KSP or Spartacus.** Turned down as the
  default: it gives up self-containment and the explanations. `prove -t`
  already writes TPTP for anyone who wants another prover.
- **Building worlds as the search needs them** (CEGAR-style, as in
  CEGARBox). This would get past the 2,048-world cap, the reason `prove`
  stops early on the LWB formulas. It is possible within the rule only if
  the new numbering of variables can be shown to give the same case, so
  `same.sh` must show it on the s5 and kd classes first. Not started.

## What is left

- **Which premises are needed.** Dropping each in turn and asking again is
  the square of the premises: 5 of the 6 seconds at 6,400 independent
  premises. Model rotation (above) is the exact remedy.
- **The ordered search's repeated decisions.** Seen on modal frames of
  tens of thousands of variables. Chronological backtracking or trail
  saving (above) is the remedy.
- **Worlds.** The LWB K and KT formulas need more worlds than `prove`
  makes; it says `argue/undecided` rather than guess. Its scores on them
  did not move with any change here.
- **Random 3-CNF past 100 atoms.** A search, not an argument. Left alone.

## Lessons

- An argument in prose has tens of premises. Everything here was found
  by pushing to thousands. That is worth doing, to find out how `prove`
  fails, but it is not a reason to give anything up.
- A benchmark's scoring can hide a wrong answer. Counting "inconsistent"
  as valid once hid a KD frame cut short that called consistent premises
  contradictory (kd-056, kd-102). Read the outputs, not just the totals.
- A comparison with another prover is only as good as its conditions:
  the same machine, quiet, and the other prover built properly. The
  packaged E was a debug build that failed an assertion; it was built
  from source.

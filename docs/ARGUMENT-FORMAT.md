# The logic file, extended: arguments with structure

A design sketch, before code.  Status: built, 1 to 5 below; the real-text benchmark (6) waits for a model.

## Why

`phil/argue` and `phil/prove` take one conclusion per document.  An essay
or a work of philosophy argues in stages: sub-conclusions that later
steps rest on, several lines of support for one claim, objections and
replies to them.  The format has to hold that, stay readable and
editable by hand, and keep every tool a function of the files it is
given.

## Principles

- **Stateless tools, stateful data.**  Every tool reads the files it is
  named and writes text; nothing is remembered between runs.  An
  argument's working state is a directory of plain files the writer
  owns: the document, the logic file, the readings, the answers.  Any
  one can be read, corrected by hand, and the next tool run again.
- **Old files keep their meaning.**  A logic file with one `C` and no
  new fields means what it means now.
- **Text, not JSON.**  One statement to a line, fields separated by tabs.
- **The model proposes, the rules decide.**  A model writes the file;
  `prove` decides what follows and what survives.

## The format

Today:

	atom	patched	the server is patched
	P1	S1	patched -> secure
	A1	-	...
	C	S3	patched

A statement line keeps its first three fields (name, sentence, formula)
and gains an optional fourth: **what it rests on, or what it attacks.**

### Steps: conclusions that later steps rest on

	P1	S1	all x: began(x) -> caused(x)
	P2	S2	began(universe)
	C1	S3	caused(universe)		from P1 P2
	P3	S4	caused(universe) -> some x: creator(x)
	C	S5	some x: creator(x)		from C1 P3

- A statement whose name starts with `C` is a conclusion.  `C` alone is
  the main one; `C1`, `C2`, ... are intermediate.
- `from` names the statements it is drawn from.  Each step is checked
  on its own: does `C1` follow from `P1` and `P2` alone?  A step that
  fails is reported at its sentence, with its counterexample, as now.
- A conclusion with no `from` rests on every step before it and every
  premise and assumption none of those steps draws on; in a file with
  no steps, every premise and assumption, which is what `C` means today.
- A step is checked as a whole argument is: a step that fails is
  `argue/invalid` at its sentence, with its case, fallacy and missing
  premise; a premise it does not need is `argue/unused`; and so on.
  The measure `argue/valid` is given once, for the argument: 1 if every
  step its conclusion depends on holds.
- Convergent support (one claim drawn twice, from different premises,
  standing if either line holds) is left for later: for now each step is
  a statement of its own, and later steps name the one they rest on.

### Objections and replies

	O1	S6	some x: began(x) & !caused(x)	against P1
	R1	S7	all x: began(x) -> caused(x)		against O1

- `O` names an objection, `R` a reply; `against` names what each
  attacks: a premise, a conclusion, a step, or another objection.
- `prove` checks that each attack is one in logic: that the attacker
  contradicts its target, alone or given the premises no objection
  disputes.  An objection
  that does not contradict what it is aimed at is reported
  (`argue/misses`), since it is the commonest fault in a reply: an
  objection to something the author never said.
- Which statements survive is decided by Dung's grounded semantics
  over the attacks that hold: an objection with no answer defeats its
  target; a reply that holds restores it.  `prove` reports what is left
  standing and what is defeated, and whether the main conclusion
  survives.
- Only the attacks the file declares count: the writer, or the model,
  says who answers whom, and `prove` checks that each answer is one.
- A reply that says no more than the premise its objection disputes
  answers by repeating what is in question (`argue/restates`).

### Which logic

	logic	s5

on a line of its own, before the statements; default `classical`.

- `s5`: necessity and possibility, written `[]` and `<>` (or `nec`,
  `pos`, `□`, `◇`).
- `kd`: the standard deontic logic, `O` (ought) and `P` (permitted)
  written `[]` and `<>` with the same decision procedure.
- `s5kd`: both at once. `[]` and `<>` are S5's necessity and
  possibility, `ought` and `permitted` the deontic ones. What is
  necessary holds in every world, the ideal ones among them, so it
  ought to be too, but nothing goes the other way. Readings in
  different logics are compared in it (`prove -c`), and `argue -w`
  joins parts in it. A modal word read in two senses is a fault:
  `argue/equivocates` within a reading, `argue/modal-ambiguous`
  across readings.
- Propositional only to begin with.  Quantified modal logic is beyond a
  small exact procedure; it is refused, with the reason, and can be
  exported with `prove -t` to a specialist prover.

### Positions over a family of claims

	rivals	P10 P11

`prove -p` takes the premises and assumptions as a family and checks
every subset: each smallest set that cannot all be true, and each
coherent position (what to give up), with its plainest case. A `rivals`
line names two alternatives (rival empirical premises, say): sets with
both are left out rather than reported as impossible. The search is
exhaustive and lists sets in `itertools.combinations` order, so it can be
set beside a z3 axiom lab's (`philosophy-formal/containment/axiomlab.py`
does the same). At most 16 claims.

### Several sentences

A statement may cite more than one sentence: `S3,S4`.  A finding about
it is addressed at the first; the faithfulness check reads all.

## The tools, all stateless

| Tool | Reads | Writes |
|---|---|---|
| `phil/argue` | the document | `doc.logic` (and, with `-k`, readings beside it) |
| `phil/argue -s mine.logic` | the document, the writer's own logic file | a cold reading over the same atoms, and `prove -c`'s comparison |
| `phil/prove` | the logic file, the document | findings, each at its sentence; a verdict for each step; what survives |
| `phil/map` (new) | the logic file | the argument as a tree in text, or Argdown for argument-mapping tools |
| `phil/prove -t` | the logic file | TPTP, for Z3, E or Vampire |

`wwbfs` may later serve the same as files at `/mnt/wwb`; it would call
these commands, never hold the only copy of anything.

## Findings added

| Rule | Meaning |
|---|---|
| `argue/invalid` (and the rest) | as for a whole argument, at the step's sentence |
| `argue/countermodel` | the refuting case as a model: truth values, extensions over D, and worlds W with R where the logic is modal |
| `argue/unused-step` | a conclusion nothing later rests on, and not the main one |
| `argue/misses` | an objection or reply that does not contradict what it is aimed at |
| `argue/defeated` | a statement an unanswered objection defeats |
| `argue/survives` | the main conclusion stands (1), falls (0), or neither (-1), for `gate` |
| `argue/restates` | a reply that only repeats the premise its objection disputes |
| `argue/undecided` | a statement the attacks leave neither standing nor fallen |
| `argue/cycle` | steps that rest on each other: circular at the level of the argument |
| `argue/follows`, `argue/needed` | with `-v`: what a valid conclusion follows from, and the case that fails without each |
| `positions/impossible`, `positions/coherent` | with `-p`: each smallest set that cannot all be true, each coherent position |

## Order of work

1. Steps (`from`, several conclusions, cycles), with tests.  Done.
2. `phil/map`: the tree in text; Argdown.  Done; its Argdown is read by
   Argdown's own tools (`argdown map` joins the steps).
3. Objections and replies, and what survives.  Done; `map` draws them
   (in Argdown as attacks).
4. `logic s5` and `kd`.  Done: decided by possible worlds, as many as
   the small-model property needs (S5: one more than the operators; KD: a
   tree as deep as they nest), by the same clause-learning search; `-t`
   writes the standard translation, and `tools/prove-bench` holds the
   verdicts to Z3, E and Vampire.
5. `argue` taught to write the new fields; `argue -s`.  Done.
6. The real-text benchmark.

## Open questions

- Should a step's check use only what its `from` names (strict), or
  also the assumptions (`A`) the writer declared?  Proposed: strict,
  with assumptions only if named, so that every reliance is visible.
- Dung's grounded semantics is skeptical (a claim survives only if it
  is defended against every attack).  Philosophy sometimes wants the
  credulous reading (it survives on some consistent view).  Proposed:
  grounded by default, `-p` for preferred.

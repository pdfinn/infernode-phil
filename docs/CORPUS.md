# The corpus: a field's claims as files

A design sketch, before code. Status: proposed; nothing built. Read
[ARGUMENT-FORMAT.md](ARGUMENT-FORMAT.md) first: everything here extends
the logic file and the tools that read it, and changes none of them.
[REACH.md](REACH.md) says which problems the tools can do something
with and which they cannot; read it before pointing them at one.
[PHIL.md](PHIL.md) is the collection this belongs to, ϕwb, and the two
ways it uses a model: the reading protocol every tool here goes
through, and the driver that composes the investigation.

## Why

`argue` and `prove` read one work. What they found most worth having
was never the verdict. It was the premise the text never states, the
"when" that had to be "only when", the objection nobody answered, the
step the rest of the work did not need. Those are facts about an
argument's place in a debate, and a debate is many works.

The aim is a system that reads a field's works and says what its
claims are, which entail and which contradict which, what each
position must assume, which cases each survives, and what has been
left unanswered. That is what a prover can do for philosophy. It is
not what a prover does for mathematics, and the difference decides the
design:

- In mathematics the formalization is the claim. Here it is a reading,
  and the verdict usually turns on the reading. So every formal claim
  stays pinned to its sentence, several readings are made, and their
  disagreement is a finding, as `argue -k` does now.
- In mathematics the premises are shared. Here they are the dispute.
  Validity is cheap; the work is in pricing premises. So the
  system's main output is a ledger of what each premise costs, not a
  proof.
- Much of the writing argues by analogy, example, consequence or
  authority, which a deductive prover sees as unused premises. Those
  arguments need a form of their own, with the questions that defeat
  them.

"Correct" is taken operationally, as reflective equilibrium made
checkable: a position is the best so far when it is consistent over
the whole graph, survives every recorded case, rests on the fewest
unstated assumptions, and reads the same way under independent
readings. The system never says a conclusion is true. It says what
follows from which readings, and what holding it would cost.

## Principles

Those of ARGUMENT-FORMAT.md, kept whole:

- **Stateless tools, stateful data.** A corpus is a directory of plain
  files its owner can read, correct by hand and run the tools over
  again. No tool remembers anything between runs.
- **Old files keep their meaning.** A work's logic file is the logic
  file of today. The corpus adds files beside it and never changes it.
- **Text, not JSON.** One record to a line, fields separated by tabs,
  the first field a name, as the logic file.
- **The model proposes, the rules decide.** A model proposes that two
  works make one claim, that a scenario refutes a premise, that a step
  argues by analogy. A rule, or a person, decides, and the file says
  which.

And three of its own:

- **Provenance on every line.** A claim names the work and statement
  it came from; a relation names what established it (`prove`, an
  answer, a hand); a verdict names who gave it. Nothing in the corpus
  is anonymous.
- **A person at every judgement.** Where a model's answer decides
  something (an alignment, a case's verdict), the decision is a file a
  person can overwrite, and the tools prefer the person's.
- **Known results before the frontier.** The system is tested on
  debates whose faults are settled in the literature. It earns the
  right to read new work by finding the known faults in old work
  unprompted.

## The corpus directory

	corpus/
		works			the works, one to a line
		readings/<id>/		one directory per work
			logic		its reading: argue -w's, or one written by hand
			logic.parts/	argue -w's parts, as today
			shared.logic	the reading over the shared atoms (written by phil/corpus)
		atoms			the shared vocabulary
		align			which works' atoms are one claim
		claims			the claims, and who asserts, denies, assumes or reports each (phil/corpus)
		ids			every statement's id (phil/corpus)
		questions		the question each work takes itself to answer
		cases/<id>/		scenarios, one directory each
			text		the scenario, in English
			logic		the scenario as a valuation of atoms
			verdicts	who says the scenario is possible, and what it shows
		positions		named sets of claims, and who holds them
		ledger			what each premise costs (written by phil/ledger)
		agenda			what is open (written by phil/agenda)

The works' texts are where `works` says, relative to the corpus. (The
first draft of this design put a work's readings under `works/<id>/`,
beside a file named `works`; a name cannot be both.)

Every file is written by a tool from the files before it, or by hand.
`ledger` and `agenda` are outputs; the rest is state. A tool's output
file is never the only copy of anything it was computed from.

### works

	id	key	kind	date	path	revision	title
	mine	-	secondary	2026	draft.md	v3	the corpus owner's own work in progress
	gross	Gross2006	secondary	2006	gross-law-in-times.md	-	Law in Times of Crisis
	schmitt	Schmitt1922	primary	1922	schmitt-pt-schwab.md	-	Political Theology, tr. Schwab 1985

`key` is the bibliography's, so `wwb/bib` and `wwb/claims` already
know the work. The `id` names the work in every other file.

- `kind`: every work is read for its own argument. A `secondary` work
  is also read for its account of other works, and its attributions
  are checked against them where they are in the corpus (below). A
  `primary` work is one whose account of others is not checked: the
  text under study, whenever written.
- `date`: the reader is told it, so that words are read in the sense
  of their time. "Modern", "emergency", "liberal" and "the state" do
  not mean in 1651 what they mean in 2020, and a reading that uses
  today's atom for yesterday's sense is a misalignment `align` must
  catch: an atom aligned across a century is questioned as any
  alignment is, with the dates shown.
- A translation is a work, named for its translator in the title. Two
  translations of one text are two works, aligned as any two are;
  where they differ, the difference is `align`'s to report, and a
  claim one translation carries and the other does not is a finding
  about the translation (`questions/differ` across translations),
  not about the author.

### atoms and align

A work's atoms are its own, as now. Across works one claim is called
many names, and the thing that makes a corpus more than a pile of
readings is saying which names are one claim. `atoms` is the shared
vocabulary:

	atom	contain_succeeds	emergency powers can be contained within the legal order
	atom	norm_constitutional	normalisation of emergency powers is a constitutional problem

`align` says how each work's atoms map onto it, and how that was
decided:

	same	mine:contain_succeeds	contain_succeeds	answers 3/3
	same	gross:containment_feasible	contain_succeeds	answers 3/3
	negates	dyzenhaus:norm_political	norm_constitutional	hand
	distinct	mine:crisis	koselleck:crisis	answers 1/3 verbal
	rival	gross:extra_legal	dyzenhaus:legal_constraint	hand

- `same`: the work's atom is this shared atom.
- `negates`: it is the shared atom's denial; the join writes `!`.
- `distinct`: they were proposed as one and are not; kept so the
  proposal is not made again, with `verbal` where the works disagree
  only in the word (below).
- `rival`: two claims the corpus treats as alternatives, for `prove
  -p`; the line goes into a family `prove -p` is given as `rivals`.
- The last field says who decided: `answers k/n` (that many of n
  readings answered yes to the question), `hand`, or `prove` (the
  formulas were found equivalent under the works' own premises).

An atom aligned to nothing keeps its work's name prefixed with the
work's id, as `join` renames a colliding atom today (`outmoded_81`).

### claims, and why there is no corpus.logic

`claims` is the index: one line per claim, naming every work that
asserts, denies, assumes or reports it. A claim is a statement's formula
over the shared atoms, as `prove -A -f` writes it, with an even number
of denials before it taken off; a work that states its denial denies it.

	claim	contain_succeeds	denies mine:C	asserts gross:P14	assumes dyzenhaus:A3
	claim	exception_decides	asserts schmitt:P3	reports gross:P7 schmitt	reports mine:P41 schmitt	denies gross:P8

The relations are `asserts` and `denies` (a premise or a conclusion),
`assumes` and `assumes-not` (an assumption), and `reports` and
`reports-not` (a premise with `says`), the last naming whose claim it
reports. Objections and replies are moves in an exchange, not
commitments, and are left out.

The first draft of this design had a `corpus.logic` as well: every work
joined into one stepped file, for `prove` to read as one argument. It is
not built, for two reasons the code made plain. A debate's works
contradict each other by design (one asserts what another denies), so
the corpus taken as one argument is inconsistent, and every verdict on
it says only that; consistency is a property of a position, a work's
or one a person chooses, which is what `prove -p` and the ledger are
for. And `prove` reads a statement's part in the argument from its name
(`C`, `C1`, `P1`, `O1`), so names prefixed with their work (`mine:C12`)
are not read at all. Each work is read over the shared atoms in its own
file (`readings/<id>/shared.logic`), and what a tool needs from several
works together, it builds: `phil/corpus` gives `prove` one work's
commitments and another's claim, and asks whether they entail it.

### Who says what

Half the sentences of a work in political philosophy, or in the
history of any philosophy, expound someone else. Read as the work's
own premises they credit an author with their opponents' views, and
every holders column in the ledger is wrong from the first run. So a
statement line can say whose claim it reports:

	P7	S212	exception_decides	says schmitt
	P8	S213	!exception_decides
	P9	S214	exception_decides	says Agamben2005

- `says` names the work the claim is attributed to: a work id when it
  is in the corpus, otherwise its bibliography key, otherwise a name.
- A `says` statement is reported, not asserted. It is not a premise of
  the work's argument and no step may rest on it. A work that relies
  on what it reports (it endorses Schmitt, or it argues from his
  authority) states the claim again on a plain line of its own, which
  is its assertion; the ledger shows the two side by side, so "asserts,
  following Schmitt" is visible without a third field. A step resting
  on a reported line is `argue/reported-as-premise`: either the reader
  forgot that the work endorses it, or the work argues from authority,
  and then `scheme authority` is the honest reading.
- The reader's instructions name the marks of reporting: "X argues",
  "according to", "on this view", quotation marks, a citation after
  the claim. The faithfulness read-back checks each `says` statement's
  sentence for one of them and each plain statement's sentence for
  none that names another author (`argue/attribution`), as it checks a
  condition turned round.

`phil/corpus` carries attributions into `claims` as `reports`, and
checks scholarship, by rule, each check decided by `prove` (built):

| Finding | Meaning |
|---|---|
| `claims/misattributed` | a work reports a claim of a work in the corpus that no reading of that work asserts |
| `claims/contradicts-source` | a work reports a claim its source, in the corpus, denies |
| `claims/attributed-unread` | a claim attributed to a work not in the corpus: the corpus cannot check it, and says which work would let it |
| `claims/reported-only` | a claim every work in the corpus reports and none asserts: held by someone outside the corpus, or by no one |

The first two are the findings a historian of philosophy wants and no
tool gives: the secondary literature checked against the primary text.
They are only as good as the reading of the primary, which is why a
primary work gets `-k 3` and its readings are kept.

### Kinds of premise

Not all philosophy is pure theory. A premise can be a claim about what
is the case (emergency powers were used so, in these years), about
what ought to be, or about what a word means, and each is tested
differently. A statement line can say which:

	P3	S80	powers_abused	kind empirical
	P4	S81	powers_abused -> constrain	kind normative
	P5	S82	emergency <-> existential_threat	kind conceptual

- `empirical`: refuted by evidence, not by a scenario. `cases` refuses
  to write a case against one. Its cost in the ledger is a source:
  `ledger/unsourced` where the work gives none, which is what
  `wwb/claims` finds for figures and studies, routed here; rival
  empirical premises are `rivals`, so that `prove -p` does not report
  two accounts of the same events as an impossibility.
- `normative`: tested by cases, as a principle is.
- `conceptual`: tested by cases and by the elimination test.

The reader tags the kind; a person may change it. The commonest useful
`split` is of one sentence's empirical content from its normative
content: "emergency powers have been abused, so they should be
constrained" is two premises and a step, and read as one atom it hides
the step the argument turns on.

### questions

The system cannot answer "what is time". It can show that two works
asking it ask different questions, and that a question as posed
presupposes a claim the field disputes. `questions` holds the
question each work takes itself to be answering, in its own terms,
with the atoms the question needs:

	question	contain	can normalisation of emergency powers be contained within the legal order?	norm_constitutional contain_succeeds	mine gross dyzenhaus	readings 3/3
	question	contain	can the political forces that normalise emergency powers be contained at all?	norm_political contain_succeeds	mine	readings 2/3

- The second field names the question; two works under one name are
  claimed to ask the same thing, and the line is made as `align`'s
  are: by readers, settled by question, with provenance.
- The fourth field is what the question presupposes: the atoms any
  answer to it uses. A question whose atoms include a claim the
  corpus disputes presupposes it (`questions/presupposes`), and the
  dispute may be about the question.
- Two works under one name whose restatements `prove` finds not
  equivalent are asking different questions (`questions/differ`), and
  their disagreement about the answer may be no disagreement.

The question is written by a reader asked what the work answers, in
the work's words, through the same protocol as a reading of its
argument, and aligned across works as atoms are.

### cases

A case is a scenario, the method of cases made a file. It is a
counterexample to a claim when it is a possible situation in which the
claim's condition holds and its consequence fails.

	cases/gettier-1/text		Smith has strong evidence that Jones will get the job and ...
	cases/gettier-1/logic
		atom	justified	the belief is justified
		atom	true	the belief is true
		atom	believed	the proposition is believed
		atom	known	the proposition is known
		justified	1
		true	1
		believed	1
		known	0
	cases/gettier-1/verdicts
		possible	1	hand	pdf
		possible	1	model	opus r1
		possible	1	model	opus r2
		shows	!(justified & true & believed -> known)	hand	pdf

- `logic` is a valuation over shared atoms: the case as a prover sees
  it. `prove` checks a position against a case by adding the valuation
  as premises: a position that becomes inconsistent fails the case.
  That part is mechanical.
- `verdicts` records who says the scenario is possible, whether a
  reading of the scenario as that valuation is faithful, and what it
  shows. The first is the judgement no rule makes. Several readers
  give it; a person's line outweighs a model's; the tools report a
  split rather than choosing.

### positions

	position	gross	gross:P1 gross:P4 contain_succeeds !norm_political	gross
	position	dyzenhaus	...	dyzenhaus
	position	mine	...	mine
	position	coherent-7	...	nobody

A named set of claims and who holds it. Works' positions are written by
`phil/ledger` from their logic files; `prove -p` writes the coherent
positions nobody holds.

`prove -p` today tries every subset, which allows 16 claims. A debate
of thirty claims is a thousand million subsets, and `agenda/unoccupied`
and the corpus's inconsistency findings both rest on this. So `-p`
grows into enumeration of the minimal unsatisfiable subsets and the
maximal satisfiable ones, by MARCO (Liffiton, Previti, Malik and
Marques-Silva, "Fast, flexible MUS enumeration", *Constraints* 2016)
over the same clause-learning search, with CAMUS (Liffiton and
Sakallah 2008) as the check: a family is then any size, each
impossibility is still a smallest set at its sentences, and each
coherent position is still what to give up. For families of 16 or
fewer the subsets order is kept, so the comparison with a z3 axiom
lab stands, and `positions/too-many` goes.

## The tools, all stateless

| Tool | Reads | Writes |
|---|---|---|
| `phil/argue -w` | a work | `readings/<id>/logic`, as today |
| `phil/align` (new) | the works' logic files, `atoms`, `align` | proposed `same`, `negates`, `rival` lines, and the questions that settle them; with `-a` the answers, and the lines kept |
| `phil/corpus` (built) | `works`, `atoms`, `align`, the readings | each reading over the shared atoms, `claims`, `ids`; the attribution findings, each decided by `prove` |
| `phil/prove` | a work's reading, or a position built from several | as today: what follows, what survives, `-p` positions; `says` and `kind` read (built) |
| `phil/cases` (new) | the works' shared readings, a claim, `cases/` | a proposed scenario and its valuation, for readers to judge; with `-r`, runs every recorded case against every position |
| `phil/ledger` (new) | `claims`, the shared readings, `cases/`, `prove`'s findings | `ledger`: each premise's holders, commitments, the cases it fails, the works that assume it unstated |
| `phil/agenda` (new) | `ledger`, the shared readings, `align`, `prove -p` | `agenda`: what is open |
| `phil/schemes` (new) | a work's logic file and text | each step's scheme where it is not deductive, and the critical questions, as findings |
| `phil/split` (new) | an inconsistent set or a verbal dispute, `atoms`, `align` | a proposed distinction: one atom made two, with meanings, and what the corpus gains and loses by it |
| `phil/contest` (later) | a position, the shared readings | objections and replies in rounds, checked by `prove` |
| `phil/report` (new) | one work's ledger and agenda lines, the text | a model's reading of them as prose, marked as a model's, as `wwb/review` does for a document's findings |
| `phil/map -W` (new flag) | the shared readings, `claims` | the corpus as a graph: works, the claims they share, attacks across them; in text and in Argdown |
| `phil/pending` (new) | the corpus | the questions and verdicts waiting for a person, each with what it would settle; `-a` records an answer |

Every tool's findings are `file:line: rule: message`, as the rest of
the workbench, so `gate`, `delta`, `tally` and `grade` work on them
unchanged, and a click in Xenith opens the sentence.

### phil/align

The central new tool, and the hardest. Two works' atoms are one claim
only if each work's sentence means the other's. A model proposes
candidates from the atoms' English (the meanings in the `atom` lines,
not the names), and a question settles each, as `argue -k`'s questions
settle readings:

> Work A says: "the legal order can hold emergency powers within
> its own limits" (S45). Work B says:
> "containment of emergency powers within the legal order is feasible"
> (S212). Does A's claim entail B's? Does B's entail A's?

Both yes from a majority of `k` independent readers makes `same`; one
direction only is recorded as a corpus-level premise (`A -> B`) with
provenance `answers`; neither makes `distinct`.

**The elimination test.** Where two works disagree and share a word,
`align -e` asks each reader to restate the two claims with that word
barred. If `prove` finds the restatements equivalent, the works agree;
if it finds them compatible, the dispute was verbal, and `align` writes
`distinct ... verbal` and `agenda` reports it. This is Chalmers's
method of elimination, run by rule over the readers' restatements.

**Faithfulness.** The read-back check `prove` makes on a reading
(a condition turned round, a negation dropped, some made all) runs on
every proposed alignment: a `same` whose two sentences fail it is not
made whatever the answers say.

### phil/cases

Given a claim, a model is asked for a scenario in which the claim's
condition plainly holds and its consequence plainly fails, in the
corpus's own atoms, and for the valuation. `k` independent readers each
write the valuation from the scenario's English alone; a valuation they
agree on is proposed; a split is a question for a person. Nothing is
recorded until `verdicts` has a line, and a person's line is the one
that counts.

`cases -r` runs the suite: every recorded case against every position,
reporting `cases/fails` at the position and the case, and `cases/survives`
as a measure. A case is a test, and a theory that fails one has a
failing test until it is changed or the case is withdrawn.

### phil/ledger

For each claim the corpus disputes, by rule, no model:

- **holders**: who asserts it, denies it, assumes it unstated (from
  `claims`).
- **commitments**: what it entails together with each holder's other
  premises (`prove -v` over that position), and in particular anything
  the holder denies elsewhere (`ledger/self-contradicts`).
- **cases**: the recorded cases it fails.
- **unstated**: how many works rest on it without stating it
  (`argue/assumed` across the corpus).
- **robustness**: how many readings agreed on it (`argue/readings-agree`).

The reader of a paper wants one line: "your conclusion rests on P3;
P3 is denied by Gross (S212) for reason R; P3 with your chapter 2's P7
entails Q, which your chapter 5 denies."

### phil/agenda

What the corpus leaves open, by rule:

| Finding | Meaning |
|---|---|
| `agenda/unanswered` | an objection in some work that no reply in any work answers (grounded semantics over the objections and replies of the works, joined for it) |
| `agenda/unoccupied` | a coherent position from `prove -p` that no work holds |
| `agenda/inconsistent` | a work's position that `prove` finds inconsistent, with the smallest set |
| `agenda/field-assumes` | an assumption more than one work rests on and none states |
| `agenda/verbal` | a disagreement `align -e` found to be in the word only |
| `agenda/untested` | a disputed claim with no recorded case for or against |
| `agenda/decisive` | a case on which two positions differ, and nothing else between them |
| `questions/differ`, `questions/presupposes` | two works answering different questions under one name; a question that presupposes a disputed claim |
| `agenda/value` | a measure on every item above: how many positions closing it would decide, how many works rest on it, how many cases it would settle; the agenda is sorted by it |

Each is a research question with its evidence attached. The list is
the output the frontier work needs: not an answer, but where an answer
would change something; `agenda/value` says how much, by rule, from
the ledger, and is what turns a list into a research programme.

### phil/schemes

A fifth field on a step line names an argument scheme where the step
is not deductive:

	C3	S9	trad_exploited	from P4 P5	scheme analogy

Schemes to begin with: `analogy`, `example`, `consequences`,
`authority`, `sign`, `cause`. Each has its critical questions, from the
informal-logic literature (Walton, Reed and Macagno, *Argumentation
Schemes*, 2008), kept as a rule pack like `diction`'s:

	analogy	1	Are the two cases alike in the respect the conclusion needs?
	analogy	2	Is there a difference between them that bears on it?
	analogy	3	Does the conclusion hold in the case compared to?

`prove` treats a step with a scheme as defeasible: it holds unless a
critical question is answered no (an `O` line against it with the
question's number as its sentence). `argue/unused` no longer reports an
analogy's premises; `schemes/cq` reports each unanswered critical
question at the step's sentence. The model proposes the scheme; a
person or a later reading may change it; the file says which.

How a scheme step meets the attack semantics, so that the two
mechanisms cannot disagree:

- A deductive step is attacked only through its premises or by a
  statement contradicting its conclusion, and `prove` requires the
  contradiction (`argue/misses` otherwise).
- A scheme step is attacked in those ways and in one more: through a
  critical question answered no. Such an `O` line is an attack `prove`
  accepts without a contradiction, because a scheme step's warrant is
  not a formula; the answer is the attack.
- An unanswered critical question is a warning (`schemes/cq`), not an
  attack: the step stands until someone answers no.
- What survives is then decided by grounded semantics over all the
  attacks together, as now. A scheme step defeated by a critical
  question is `argue/defeated`, and a reply restores it as a reply
  restores anything: by attacking the attack, which here means
  answering the critical question yes with a reason (an `R` line
  against the `O`), and `prove` checks that reply as it checks any.

### phil/split

Much of what counts as progress is a new distinction: de re and de
dicto, type and token, the act and its description. Each made an
inconsistent set coherent by splitting one claim in two. `split` is
that move as a tool. Given a smallest inconsistent set from `prove
-p`, or a dispute `align -e` left in conflict, a reader is asked which
one atom, read in two senses, would let the set stand, and what the
two senses are:

	split	emergency	emergency_existential emergency_ideological	readings 2/3
	atom	emergency_existential	a threat to the state's existence
	atom	emergency_ideological	a threat to a particular conception of the state

The lines go into `atoms`; `align` must then place every work's use of
the old atom on one side or the other, by the protocol; `join`
rewrites each reading's shared form; and `ledger` says whether the distinction
earned its keep: the inconsistencies removed, the cases now passed,
against the new assumptions the works need to be read with it. A
distinction that resolves nothing is reported so, and the lines are
left for a person to keep or delete.

### phil/contest (later)

Given a position, one model writes objections against its claims, a
second writes replies, `prove` checks each attack is one
(`argue/misses`) and what survives, and a person judges the moves no
rule can. Rounds are bounded; every move is a line in a file. This is
the self-play the mathematics work has, and here the game is the
dialectic, not the proof. It waits on everything above.

## Measures, for gate

	corpus/survives		= 1
	corpus/assumed		<= 3
	corpus/readings-agree	>= 80
	cases/survives		= 100
	claims/misattributed	= 0
	claims/contradicts-source	= 0
	ledger/unsourced	<= 2
	corpus/stale		= 0

(`corpus/consistent`, in the first draft, is gone with `corpus.logic`:
a debate is inconsistent by design.) `phil/corpus` gives `corpus/works`,
`corpus/claims`, `claims/attributed` (reports checked and held), and
the four attribution measures. A policy over these is what "correct" means to this system, and the
policy file says so in its first line. A position that passes is the
best so far; the ledger shows what it costs.

## The benchmark

Debates whose faults are settled, each a corpus under `tests/corpus/`
with its expected findings as a golden file, in the way `tests/cases`
holds the workbench's cases now. The system passes a benchmark when it
finds the known fault from the texts alone.

| Corpus | Logic | The known result the tools must find |
|---|---|---|
| Justified true belief and Gettier | classical | `cases/fails`: the JTB position fails the two Gettier cases; `agenda/decisive` on them |
| The problem of evil (Mackie) | classical | `positions/impossible`: omnipotent, wholly good, evil exists, and the two bridging premises cannot all be true; each coherent position is a known theodicy or denial |
| Alternate possibilities and Frankfurt | classical | `cases/fails`: PAP fails the Frankfurt case; `argue/readings` splits on whether the case is possible |
| The modal ontological argument (Plantinga) | `s5` | `argue/valid 1` and `argue/needed`: the whole argument rests on "possibly, a maximally great being exists"; `agenda/untested` on it |
| The epistemic regress | classical | `prove -p` gives exactly foundationalism, coherentism, infinitism and scepticism as the coherent positions |
| A planted misattribution: a scripted secondary work reporting that *Political Theology* holds what it denies | classical | `claims/contradicts-source` at the secondary's sentence, naming Schmitt's; `claims/misattributed` on a claim no reading of Schmitt has |
| Chisholm's paradox | `kd` | `positions/impossible`: the four sentences cannot all be true in standard deontic logic; the formalization of the conditional obligation is the premise the ledger prices |
| Containment of emergency powers (the corpus owner's own work, Gross, Dyzenhaus) | `s5kd` | the owner's unstated bridges (`agenda/field-assumes`), and `agenda/verbal` or not on "normalisation" |

The texts: the corpus owner's own work, works out of copyright, and
otherwise short quotations with the rest paraphrased; the golden files
name which. The first six are a morning's hand-writing each; the
last needs the owner's own work, read with `argue -w` as any work
is, and the two other works.

## Order of work

1. **The directory and `phil/corpus`.** `works` with kinds and dates,
   `atoms`, `align` and the `says` and `kind` fields written by hand;
   `phil/corpus` makes each work's shared reading, `claims` with
   `reports`, and `ids`; the attribution checks. No model. **Built**,
   on a test corpus of two works (`tests/data/corpus/sovereign`) whose
   planted faults it finds. `prove` reads `says` and `kind`: a
   reported premise is never a premise, and a step drawn from one is
   `argue/reported-as-premise`; nothing it said of any existing file
   changed (944 arguments, 1,888 files of verdicts and TPTP compared).
   `map` marks a reported premise with whose claim it is; `join`
   carries every field and never makes a report a conclusion's
   implicit premise. **Left of step 1:** `argue`'s instructions do not
   yet ask the model for `says` and `kind` (a prompt change, held to
   PHIL.md's check); the read-back does not yet check a `says`
   statement's sentence for the marks of reporting
   (`argue/attribution`); and the owner's own work with one other is
   still to be written by hand.
2. **`ledger`**, by rule, from what step 1 gives, with premises' kinds
   and `ledger/unsourced`. The first useful output. `delta` over it.
3. **`cases`** and the suite runner; `pending` for the verdicts; the
   Gettier and Frankfurt benchmarks.
4. **`align`**: proposals, questions, the faithfulness check with the
   attribution check in it; the elimination test. `prove -p` by MUS
   enumeration. The Mackie, regress and misattribution benchmarks.
   `questions`, by the same protocol.
5. **`agenda`**, by rule, from everything above; `report` and
   `map -W` over it.
6. **`schemes`**: the fifth field, the rule pack, `prove`'s defeasible
   steps. A political theory work's analogies and examples stop being
   `argue/unused`. `split`, and `agenda/value`.
7. **`contest`.**
8. `wwbfs` serves the corpus at `/mnt/phil/corpus/`, calling these
   tools, never holding the only copy of anything.

Steps 1, 2 and 5 need no model. Steps 3, 4 and 6 use one in the way
`argue -k` does: several readings, a question where they differ, a
rule or a person to settle it.

## Revision

A corpus changes. The owner edits their own work; a second edition of a
work is read; a reading is made again with a better prompt. Every
alignment, case and verdict points at a statement, and statements are
named `C12` and `S240` in a reading that will be replaced.

- **Statements have identity across readings.** `phil/corpus` gives
  each statement an id and writes them all in `ids`:

	id	mine	k3f9a01c2	C12	S240	contain_succeeds->!norm_constitutional

  The id is computed, not kept: `k` and the first eight hexadecimal
  digits of the SHA-1 of the work, the kind of statement (and whose
  claim, for a report) and its formula over the shared atoms as `prove`
  writes it. So a statement whose formula is unchanged keeps its id
  whatever its name and sentence now are, with no state to keep, and a
  changed one has a new id; the test corpus is read again, every
  statement renumbered, and the ids are the same. The reader is given
  the old reading's atoms as its vocabulary, as `argue -w` gives each
  part the atoms before it, so that a formula's atoms persist. Two
  statements of one work with one kind and formula are told apart by
  `.2`, `.3` in the order read.
- **Corpus files name ids, never sentences.** `align`, `claims`,
  `cases/*/verdicts` and `positions` say `mine:k12`. The sentence is
  looked up through `ids` when a finding is reported, so a finding is
  always at the sentence as it now is.
- **What a reread breaks is reported, not silently dropped.** A corpus
  file naming an id now `gone` is `corpus/stale`, at that line, with
  the statement's old formula and the nearest new one, for a person to
  re-place or delete. The measure is in the gate policy at 0.
- **What a move changed is `delta`'s to say.** `ledger` and `agenda`
  are findings lines, so `wwb/delta` over a ledger kept before a move
  gives exactly what the move changed: the case that now fails a
  position, the inconsistency that went, the item whose value rose.
  The driver's loop keeps the ledger before each move for this.

## Cost

A thesis of about 2,400 sentences took several hours with three
readings per part. A corpus of ten such works is days, run once. The
readings are a function of the text, so `readings/<id>/logic` is kept and
reread only when `source`'s revision changes; `-c` continues a cut-off
run as now. `align`'s questions are one call each and there are at most
as many as candidate pairs; `cases` is one call per scenario per reader.
`ledger` and `agenda` are rules and take seconds.

## Why InferNode

The tools are files in, files out, and run anywhere with a shell. The
case for building the corpus and its agent on InferNode is not that it
is distributed or runs on small machines; the cost is in the model
calls, not the host. It is that four things the method needs are
properties of the name space there, and policy everywhere else.

**Blinding by construction.** Everything the runs taught rests on
independence: several cold readings, trust what survives both, a
reader that cannot see the others. Elsewhere a reader is blinded by a
prompt that says not to look, and by hope. Here a reader is a process
whose name space holds the text and the shared atoms and nothing else.
The other readings, the answers, the claim a case was written to
refute, the defender's draft reply: none of these is denied to it,
none of them exists for it. When a reviewer asks how we know the model
did not see the answer, the reply is the reader's name space, listed,
not a promise. This is the strongest reason, and the one that makes
the method's results defensible as results.

**A corpus federated by mount.** A field's works are mostly under
copyright and cannot be pooled. Readings can be. Each party serves its
own works, keeps `source` to itself, and exports its logic files,
alignments and cases; a group mounts all of them into one `corpus/`
with no central store and nobody shipping a text they may not ship.
9P does this with `mount` and `bind`; a web service does it with a
year of permissions code.

**Which model, by bind.** Each reader sees `/mnt/llm`; what is mounted
there is decided outside the tool. Three readings from three different
models, or an attacker and a defender in `contest` that cannot share
blind spots because they are not the same model, with no tool knowing.

**Provenance enforced.** Every model call and every write goes through
the audit log, so the corpus's history is a record the tools did not
have to be trusted to write; "provenance on every line" is checked
against it rather than asked for.

What InferNode does not give: the model ecosystem, which lives in
Python and is reached through `llmsrv` or the host; a community of
contributors, which does not exist yet; first-order proving beyond the
decidable fragments, for which `prove -t` exports to Vampire and E and
should go on doing so. The standing risk of the project is building
platform instead of philosophy, and the guard against it is that
every tool here is a function of files and could be run from a Unix
shell. The name space is used where it changes the method, in the
agent layer, for blinding, model binding and audit, and the benchmark
decides whether any of it is working.

## What this is not

- **Not a judge of truth.** Every verdict is relative to readings the
  files show, and the `argue/assumed` lines are where the argument
  would be had.
- **Not for every kind of philosophy.** A position stated as claims
  with entailments formalizes; one that proceeds by description,
  genealogy or the reframing of a question does not, and the system
  will see little in it. The schemes layer takes in analogy, example
  and consequence. It does not take in everything, and the corpus
  owner should know what their field loses.
- **Not a replacement for the person.** Alignments, case verdicts and
  scheme choices are files a person writes or overwrites, and the
  tools prefer theirs.

## Open questions

- Should `align`'s one-direction entailments (`A -> B` by answers) go
  into the commitments `phil/corpus` gives `prove` as premises? They are readers' claims, not any
  work's. Proposed: yes, as assumptions with `answers` provenance, so
  `prove` can use them and `ledger` can show what rests on them.
- A case's valuation is over shared atoms, but a scenario can turn on a
  distinction no atom draws. Proposed: `cases` may add atoms, and
  `align` must then place them, as after a `split`; a case that adds an
  atom no work uses is a distinction the field lacks, and `split` is
  asked whether it earns its keep.
- Quantified claims. `prove` decides the propositional and the small
  modal fragments and exports the rest. A corpus of metaphysics will
  want the first-order fragment early. Proposed: the TPTP route first,
  with an external prover's verdict recorded with `prove`-style
  provenance (`vampire`), and the decidable fragments grown as the
  benchmarks demand.
- Grounded or preferred semantics for `agenda/unanswered`? Grounded by
  default, as ARGUMENT-FORMAT.md proposes; `-p` for preferred.
- English only. The faithfulness read-back matches English words, so
  Kant in German passes it silently, and the archaic forms of a
  seventeenth-century text may fail it falsely (the OED knows them;
  the read-back does not yet ask). Proposed: a primary work in another
  language enters as its translation, named so, until the read-back
  has that language's words; and the read-back asks `oedwords` for a
  form it does not know before reporting it.
- Should a reported claim (`says`) be available to `prove` at all?
  Proposed: not as a premise of the reporting work; as an assertion of
  the reported work only where that work is in the corpus and its own
  reading has it. A claim known only by report is `claims/reported-only`
  and nothing rests on it.

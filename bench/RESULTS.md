# Results

## The run of 19 October 2026

Claude Opus 5.5 (`claude-opus-5-5`) through the Anthropic API, reading
with `lib/phil/argue` at `a036b21b8816`, judged by `phil/prove` as of
commit `0491dbe`. The gold set read with `argue -n 3 -k 3` (three runs,
three readings each), the breadth sample with `-n 2 -k 3`, the pairs
with `-k 3`. 1,397 calls, 2.53 million tokens in and 0.99 million out
(about $30 at list price); none failed. The readings and the tools'
output are in [results/2026-10-19/](results/2026-10-19/); what a person
judged is in [results/](results/).

In short: the tools find a fault that is a missing step, a bridge the
text needs and never states, nearly every time, and say a valid
argument is valid 23 times in 24. As first run they did not find a
word used in two senses, a shift in the scope of "necessarily", or an
"every ... some" turned round: the readers settled each ambiguity
silently, one way. Attributions are marked accurately. What the prover
says about a sentence beyond its verdict is too noisy to count as a
finding on its own.

A change to the prompt made from those misses, and run again the same
day ([below](#the-prompt-changed-48e3990c5a0a)), turned the "every ...
some" case into a finding, had every reader name the scope of
"necessarily", and drew no new false alarm; the equivocations were
still not found. A step of its own for them, `phil/senses`
([below](#two-senses-philsenses-f4c9d13865f3)), names the shift in
about two runs of three, on the gold set and on five held-out
passages alike, and in the breadth sample's 1,112 claims finds none.

## The gold set

The counts `score.py` gives are not the result. Read side by side, every
class draws findings at much the same rate:

| Class | Runs | Verdict 0 | A finding other than an assumption | Any finding of a fault | Located, gold sentence not the conclusion's |
|---|---|---|---|---|---|
| inference | 39 | 9 | 31 | 37 | 9 of 18 |
| equivocation | 15 | 2 | 13 | 14 | 5 of 12 |
| valid | 24 | 1 | 17 | 24 | - |

A valid passage draws a finding of some fault as often as a faulty
one, so "something was found" says nothing; and a finding about the
conclusion is reported at the conclusion's sentence, which is the gold
sentence of eight passages of thirteen, so "located" there is free.
The verdict is the only automatic measure that tells the classes apart
(9 in 39 against 1 in 24).

So every run was judged by hand: did it put in front of its reader the
step the gold names, as an assumption that is that step, a failure
whose case is that step, or a question about it?
[results/gold-judged.tsv](results/gold-judged.tsv) has each call and
why.

| Class | Runs | Found | Partly | Missed |
|---|---|---|---|---|
| inference, 13 passages | 39 | 18 | 6 | 15 |
| inference, less the three whose gold the run disputed (below) | 30 | 18 | 6 | 6 |
| equivocation, 5 passages | 15 | 0 | 2 | 13 |

| Class | Runs | Valid | False alarm |
|---|---|---|---|
| valid, 8 passages | 24 | 23 | 1 |

**Found, in every run or nearly.** The step Aquinas's reply to the
ontological objection denies (from existing in the understanding to
existing in fact); Aristotle's function argument (crafts and organs
have a work, so man has one) with nothing to carry the analogy;
Descartes's real distinction, from what can be supposed to what is,
shown invalid with its case; Hume on miracles, the unstated premise
that what is not observed has uniform experience against it; Locke's
unstated general premise for property; Mill's composition (two runs
of three); the third way's quantifier shift (two of three), written as
the step the text needs.

**Partly.** The first and second ways: every run flags that the
conclusion's own sentence names God (`own-sentence`), not that the
regress premise is only asserted, which the readers rightly read as a
premise stated.

**Missed.** Boethius's modal scope: every reader wrote the sentence's
"if God foresees it, it must necessarily happen" as foresees → □happens,
which is what it says, and nothing asks whether it should be
□(foresees → happens). Every equivocation: the prompt says the same
claim in other words is the same atom, and the readers gave each word
one sense.

**The false alarm** was a reading that had the assumptions it needed
but left them out of the `from` of the steps that use them; the tool
said so.

**Gold disputed by the run.** Three passages are scored as missed in
every run, and the readings make a case that the gold is wrong for the
passage as given, not the tools:

- `aristotle-chief-good`: in Chase's translation the sentence says that
  "that which all things aim at" is a fair description of the Chief
  Good; it does not plainly assert one good that all things aim at,
  which is what the quantifier-shift charge needs. (Withdrawn: under
  the changed prompt every reader took it to assert that, and the
  prover found the shift. The gold stands.)
- `descartes-cogito`: the passage concludes that the cogito may be
  accepted as a first principle, and states the cogito; its inference
  is not the passage's argument.
- `aquinas-fourth-way`: the gold calls the Platonic premise (the
  maximum in a genus causes all in it) illustrated only; S4 states it,
  and the readers read it as stated.

They are left as they are, and the last two are the first to revise.

## The breadth sample

100 passages, two runs each. Every passage was read; none failed.

| Measure | Value |
|---|---|
| Runs, by verdict | valid 182, not valid 18 |
| Passages whose runs agree on the verdict | 90 of 100 |
| Statements the three readings of a run agree on, on average | 63% |
| Statements per reading, median | 8 |
| Readings with a `says` line | 26 of 200 |
| `kind` fields | empirical 279, conceptual 138, normative 51 |

**Attributions.** 43 `says` lines, every one checked against its
passage: all are reports of the one named (Paul in Aquinas, Socrates
in the *Politics*, Bellarmine in Hobbes, Epicurus in Epictetus, Mill
quoted by James, Dr. Johnson in *On Liberty*, Bentham's "secondary
evil" in Sidgwick, and so on). Every passage with a reporting cue
("says", "according to", "maintains that" and the like) was read too:
no claim given as a named person's was left unmarked. One anonymous
report ("It has been said, that a legislator ...", *Politics*) was not
marked; the prompt asks for a name. The two runs of a passage do not
always both mark a report (Sidgwick on Bentham, Hume on Hesiod).

**Noise.** `argue/negation` was the commonest finding (206 in the kept
readings), most of it one fault: a sentence with "no" or "nothing" in
it, read as several statements, had every statement without a denial
reported. Fixed in `30ccaf7`; on the same readings it now gives 96, no
verdict changes, and every removed finding sampled was a denial of
something the statement does not speak of. `argue/unfaithful` fires in
dialogues where a claim is put in a question and granted in the reply
("HYL. No one can deny it."): the reader cites the reply, whose words
are not the claim's. Not yet fixed.

The 18 verdicts of not valid are not yet read against their passages.

## The pairs

Three commentaries read against the passages of their source they
report, the source's atoms given to the commentary's reader, then
`phil/corpus`. 13 claims reported as the source's:

| | Count |
|---|---|
| held: the source's reading entails it | 7 |
| flagged `claims/misattributed`: neither it nor its denial follows from the source as read | 6 |
| `claims/contradicts-source` | 0 |

Every claim held is one the source makes. Of the six flagged:

- one is the tool's: Locke says in the excerpt that "words become
  general by being made the signs of general ideas", but `argue` reads
  a passage as one argument with one conclusion, and the source's
  reading kept the first paragraph's argument and left the claim out;
- two are claims the source makes elsewhere than in the excerpt (that
  brutes reason only in particular ideas, *Essay* II.xi.11; Kant's
  formula as the ground of obligation);
- three are the commentator's reconstruction of the source: Berkeley's
  "this supposition, that the making use of words implies the having
  general ideas", and Sidgwick's "he must be understood to mean".

So `phil/corpus` held the commentaries to the text it had, correctly.
What it lacks: a source read as everything it asserts, not one
argument; and a name for "the source as read does not say it" that is
not "misattributed", which says more than the tool knows.

## The prompt changed (48e3990c5a0a)

From what the gold set missed, `lib/phil/argue` went from
`a036b21b8816` to `48e3990c5a0a`: a word in two senses is two atoms,
and the reader says which word shifts; "if p, then necessarily q" read
one way is said to be readable the other; the order of all and some is
kept, with relations of two places; a step names the assumptions it
needs. The examples in the prompt are not from the bench. Run the same
day with the prover as of `30ccaf7`: the gold set again (`-n 3`), the
eight passages of the last prompt check, and one breadth passage from
each work (`-n 2`). 711 calls, 1.44 million tokens in and 0.50 million
out (about $16); none failed. Output in
[results/2026-10-19-48e3990c5a0a/](results/2026-10-19-48e3990c5a0a/);
judged in
[results/gold-judged-48e3990c5a0a.tsv](results/gold-judged-48e3990c5a0a.tsv)
by the same rule as before.

| Class | Runs | Found | Partly | Said by the reader only | Missed |
|---|---|---|---|---|---|
| inference, before | 39 | 18 | 6 | 0 | 15 |
| inference, after | 39 | 21 | 4 | 3 | 11 |
| equivocation, before | 15 | 0 | 2 | 0 | 13 |
| equivocation, after | 15 | 0 | 5 | 0 | 10 |
| valid, before | 24 | 23 valid | | | 1 false alarm |
| valid, after | 24 | 24 valid | | | 0 |

- **Every ... some.** Every reader of `aristotle-chief-good` wrote the
  premise as each pursuit aiming at some good and the conclusion as
  some good aimed at by all, in a relation of two places, and the
  prover found it invalid with its case: three runs of three, against
  none.
- **Scope.** Every reader of Boethius wrote the sentence's narrow
  scope and said in a comment that it could be read as the necessity
  of the whole conditional, "the argument turns on this". No finding
  of the tool's says so: a comment is for the person, and the readings
  agree on the formula, so nothing is asked. Counted as said by the
  reader only.
- **Senses.** No reader split a word in the five equivocations. Two
  readings of Mill's proof said that "desirable" changes its sense,
  the second half of that passage's gold. The equivocation runs found
  in part rose from two to five, all through an assumption that
  bridges the shift without naming it.
- **What did not change.** The eight passages of the last prompt check
  kept every verdict and every finding made in all three runs. The
  critic's report of Locke (S4) was read as an objection to Hobbes in
  two runs of three, not as Locke's claim, which loses
  `claims/attributed-unread` on it in a corpus. In the 25 breadth
  passages the verdicts are as often not valid as before (4 runs of
  50 both times); five passages changed a verdict, in both directions,
  as two runs of one passage do (10 of the first run's 100 passages
  disagreed with themselves). Readings agree a little less (63% of
  statements against 68%), fewer premises carry a `kind` (89 against
  120), and three passages lost a `says` line in one run.

The prompt was changed to answer this gold set's misses, so the gains
on it are a development result, not a test: a held-out set of
equivocations and scope shifts is what would show them general. The
change is kept: it found what it was meant to and cost nothing
measured elsewhere beyond the run-to-run noise, except the critic's
report and the fewer `kind` fields, both small.

## Two senses: phil/senses (f4c9d13865f3)

Equivocation was missed in every run of both prompts: a reader writes
each word in one sense, and with `-k` the later readers must use the
first reader's atoms, so a merged sense is never split. `phil/senses`
asks the question on its own. Each atom more than one statement uses
is put to a model afresh, with the statements in words: one sense
throughout, or two, and which statements take the second? The model
does not judge the argument. The prover does: the atom is split for
those statements and the argument proved again; valid as read and
invalid split is `argue/equivocates`, with the case. It was first run
on the kept reading by `argue -e`, a flag since taken out: a reading
is checked by `phil/senses` after `phil/argue`, as by `phil/prove`, and
the bench composes them. Run the same day: alone, on the gold set's
readings made with `48e3990c5a0a` and on the breadth sample's 200; and
`argue -e -n 3` on [heldout/](heldout/), five equivocations the
literature names in texts the bench had not used, none of them seen
while the step was written. 389 calls, 0.77 million tokens in and 0.15
million out (about $6); none failed. Output in
[results/2026-10-19-senses/](results/2026-10-19-senses/); every run
judged by hand in [results/senses-judged.tsv](results/senses-judged.tsv).

| Set | Runs | Found | Named | Related | Missed |
|---|---|---|---|---|---|
| gold equivocations, before (both prompts) | 15 | 0 | 0 | 0 | 15 |
| gold equivocations, `phil/senses` | 15 | 8 | 2 | 0 | 5 |
| held-out equivocations, `argue -e` | 15 | 7 | 2 | 2 | 4 |

Found is `argue/equivocates` on the word the literature names, or one
carrying the same shift; named is `argue/two-senses` on it where the
reading was not valid as read, so splitting it decides nothing.

- **Found.** Berkeley's master argument, "unconceived" as the act of
  conceiving and as what is conceived, in every run; *Principles* 4,
  "perceive" as what is immediately present to sense and as the houses
  and rivers the senses are aimed at (two of three); *Republic* I, "live
  well" as faring well and as functioning well, at S16, the gold
  sentence, in every run. Held out: *Republic* I on pleonexia, "desiring
  more" as grasping at gain and as outdoing in a craft, in every run;
  the *Gorgias*, "evil" and "pain" as worse for the doer and as harmful
  to someone, Vlastos's objection, in every run; the *Euthydemus*, "be"
  as ceasing to exist and as ceasing to be ignorant (one of three).
- **Named, not decided.** The Meno's "know" (two runs), and the
  *Euthydemus*' "learn", Socrates' own diagnosis, and "knowing": the
  readings were not valid as read, so the split changes nothing.
- **Missed.** The *Phaedo*'s opposites (every run), and two runs each of
  two *Euthydemus* sophisms, whose readers answered one sense for
  every claim.

**False alarms.** On the eight valid passages, two runs of 24 flagged
"infinite" in Aquinas's objection from evil (unbounded in extent, as a
contrary that leaves no room for its opposite; unlimited in perfection,
as God's goodness is): not the gold's dispute, but a charge commonly
made against the objection. On the thirteen inference passages, five
findings, each a defensible statement of the gold's own fault (the
second way's "first", the third way's "could have been", Mill's
"desirable"). On the breadth sample, 194 readings had a claim used
twice, 1,112 claims in all: every one was answered one sense, and no
finding was made. Every finding, read against its passage, is one I judged
defensible; none names a shift the text does not make.

So the gap is mostly closed: from none to about two runs in three
naming the shift, held out as well as on the gold, with no false alarm
in the breadth sample. The step costs one call a run.

**A second asker.** Every reading was asked again, by a model afresh
(287 calls, about $3.50; in `ask2-*`). The two askers agree on whether
the argument equivocates on 289 readings of 293 (all 200 of the
breadth sample's), and where they differ it is the first that found
the shift and the second that did not, four times. Splitting where
either says two would have found nothing more: what the step misses is
not chance in the asking. It is in the reading, or in the text. The
*Phaedo*'s asker, in every run, wrote that living and dead "could be
read as contradictories rather than contraries", and answered one
sense because the text says, at S23, that they are opposites with a
process between: it took the extension for a false premise the text
asserts, not a word that shifts, which is a reading the gold could
have allowed. A second asker is not worth its call.

## Bridges between senses (b350a3107fa4)

Of the 13 runs `phil/senses` did not find, six had the shift between
two claims, not within one: the reader had given the two senses two
atoms and written the move between them as a premise, and the asker,
asked only whether each claim kept its sense, said in a comment that
the shift was there ("it lies between two claims, joined by P4") and
answered one sense. The model saw it; the question had no place for
it. So `lib/phil/senses` asks a second question: does a premise or
assumption take a word from one sense to another? The prover decides
such a bridge as it decides a split: taken out (its formula made
always true), does the argument still hold? Needed is
`argue/equivocates`, at the bridge. The asker is now given the whole
argument in words. Run on the same readings as before: 293 calls,
0.78 million tokens in and 0.11 million out (about $5). Output in
[results/2026-10-19-senses-b350a3107fa4/](results/2026-10-19-senses-b350a3107fa4/);
judged in
[results/senses-judged-b350a3107fa4.tsv](results/senses-judged-b350a3107fa4.tsv).

| Set | Runs | Found | Named | Related | Missed |
|---|---|---|---|---|---|
| gold equivocations, without bridges | 15 | 8 | 2 | 0 | 5 |
| gold equivocations, with bridges | 15 | 8 | 1 | 0 | 6 |
| held out, without bridges | 15 | 7 | 2 | 2 | 4 |
| held out, with bridges | 15 | 9 | 3 | 1 | 2 |

- **Gained.** The *Euthydemus*' "be" sophism, found in one run of
  three before, is found in all three, each time at the premise that
  takes "be" from no longer being ignorant to no longer existing; the
  "knowing" sophism is named at its bridge in two runs (missed before;
  the readings were not valid as read, so nothing is decided); the
  *Phaedo*'s "opposites", contradictories against contraries, found
  for the first time (one run); Socrates' own diagnosis of "learn" in a
  third run. Most findings on the *Republic* and the *Gorgias* now come
  twice, as a split claim and as its bridge.
- **Lost.** Three runs found before are not now (Berkeley's master
  argument once, the *Gorgias* once, the Meno's "know" named once):
  asked again, a model does not always answer alike, and with the
  longer question it did not here. Over the 30 runs, found rises from
  15 to 17 and missed falls from 9 to 8; the gain is where bridges
  were the reason, and the losses are of the size the run-to-run
  variation already shows.
- **False alarms.** On the valid passages, two runs of 24 again: the
  objection from evil's "infinite", and Philonous's "pain" in
  Berkeley's heat-pain argument, a quality that causes pain against
  feeling it, the charge commonly made against that argument. On the
  breadth sample, one finding in 200 readings, and a defensible one:
  in the *Consolation*, an assumption moves "counted among thy
  possessions" from "a good to thee" to "belonging to thee", and the
  vicious-servant horn shows only the first.

Kept. A bridge named in a reply (R1) is not yet tested: one reading
of the "knowing" sophism put the move there.

`argue -e` was taken out with this change: a tool that runs another
under a flag is the thing "cat -v considered harmful" warns against.
`phil/senses` reads a reading, any reading, as `phil/prove` does;
`bench/senses.sh` composes it after `phil/argue`.

## Scope: phil/scope

Every reader of Boethius wrote that "if God foresees it, it must
necessarily happen" could be read either way, and no finding said so.
The two readings, the necessity of the consequent (p → □q) and of the
consequence (□(p → q)), are formulas the prover can write itself, so no
model is needed: `prove -s n` writes a reading with its nth such scope
turned over (and `-S` every one at once, where two premises each give
what the other does); `phil/scope` proves each again and says
`argue/scope` where the verdict turns. A reading with the necessity on
the whole that holds is not marked; a premise read as conceptual is
taken as necessary, so that a conceptual antecedent does not make a
difference without a distinction. The same for ought, narrow scope and
wide. It was run, at no cost, over every reading already made, and on a
held-out set: four objections in the *Summa* that argue from God's
knowledge, will or providence to necessity, each answered by Aquinas
with the composite and divided sense or conditional necessity, read
live with `argue -n 3` (48 calls, about $1). Judged in
[results/scope-judged.tsv](results/scope-judged.tsv); output in
[results/2026-10-19-scope/](results/2026-10-19-scope/).

| Set | Runs | Found | Missed |
|---|---|---|---|
| Boethius, the gold set's scope shift, both prompts | 6 | 6 | 0 |
| held out, the *Summa*'s four | 12 | 10 | 2 |

- **Missed**, both by the reading: one wrote "must necessarily be" as
  a predicate, `necbe(x)`, and one wrote the necessity into its atoms'
  names; with no □ there is no scope to turn. The readers of the other
  ten wrote the scope as the sentence has it and said, in a comment,
  that the objection needs that reading; the tool now says so too.
- **On the other passages** (156 gold readings, 200 breadth): every
  finding is a real dependency of the argument on a necessity or ought
  read on a consequent. Five of necessity are in an assumption the
  reader added (Aquinas's first way, Berkeley's *Principles* 4), two in
  Aristotle's "there must necessarily be as many forms of government",
  a necessity of the consequence read on the consequent. Nine are of
  ought: "if the young need sustaining, the union ought to last", the
  narrow reading every argument from facts to duties takes. Real, but
  everywhere in such arguments; a person may want to filter them.

Two of the misses Boethius's readers made at first were fixed on the
way: a necessity nested in a consequent (p → (q → □r)), and the claim
written as ◇¬q → ¬p, which says the same as p → □q.

## The pairs again, sources read for their claims

The first pairs run lost one report to the tool: Locke says in the
excerpt that "words become general by being made the signs of general
ideas", but `argue` read the source as one argument and left the claim
out. `phil/claims` reads a document for everything it asserts and
reports, with no conclusion; `bench/pairs.sh` now reads each source so.
Run the same day: 16 calls, about $0.70. Output in
[results/2026-10-19-pairs-claims/](results/2026-10-19-pairs-claims/).

The sources' readings now hold everything in them: Locke's 18 claims
across its three paragraphs (two or three before), Mill's 14. The
counts did not improve (attributed 5 against 7, flagged 7 against 6),
and why is the next problem, not coverage:

- **Two readers, two forms.** Locke's reader wrote "words become
  general by being made the signs of general ideas" as a conditional
  (signs of general ideas → general); Berkeley's reader wrote his
  report of it as asserting both. The claim is now in Locke's reading,
  and the report is still not entailed by it.
- **One right.** Berkeley's reader gave Locke the claim that beasts do
  not compound their ideas; Locke leaves it open ("if it may be doubted
  whether beasts compound ..."). `claims/misattributed` is right there.
- **Out of the excerpt**, as before: Locke on brutes reasoning in
  particulars (*Essay* II.xi.11), Kant's formula as the ground of
  obligation; and commentators' reconstructions.

So holding a report to its source now turns on the two readers writing
one claim in one form. The vocabulary the commentary's reader is given
fixes the atoms, not how they are combined. What would: the source's
own statements given to the commentary's reader as well, to report
with where they fit; or the question a person asks, put to a model
when a report is not entailed: does the source's sentence say this?

## Attribution by rule: phil/says

The first model call put on the roadmap to be replaced. `phil/says`
finds, with no model, each sentence that gives a claim as someone
else's: a reporting verb with a named subject (Hobbes argues that),
the same after a quotation (says Mill), according to a name, a name's
doctrine or words, as a name calls it, alleged by a name, learnt from
a name; a pronoun given to the last name reported; "it has been said"
to no one named; the writer's own (I hold, it must be said) left out.
The words are tagged by wwb's tagger, an averaged perceptron; a
capitalized word is a name if the tagger says so, if `/lib/words` lists
it with a capital, or if it lists it not at all, and not if it ends
as an abstract noun does (the principle of Utility). It reads a passage
in about a seventh of a second.

Against the readers' `says` fields on the breadth sample (100
passages, two runs each; [results/2026-10-19-says/](results/2026-10-19-says/),
`bench/sayscmp.py`):

| | Sentences |
|---|---|
| a report marked by both | 8 |
| by the rule only | 8 |
| by the readers only | 10 |

Of the passages where the readers marked a report, the rule names the
same person in 10 of 14. Of the eight sentences only the rule marks,
three are reports the readers missed (Jason in the *Politics*, "It has
been said" in the *Politics*, "the argument of Socrates" in the
*Phaedo*), three are the same report a sentence earlier or later than
the readers put it, and two are objections put by no one named ("It
may be replied"). None is wrong. What only the readers mark is a group
with no reporting verb (the sceptics, the devotees, the authorities)
and a report carried into the sentences after it, which no rule over
one sentence reaches. In the gold and pairs passages it also marks
narrated dialogue (said Socrates, replied Cleinias), which is speech
reported, and which a reading of a dialogue may or may not want.

So, for attribution, a rule does most of what the model did, finds
some of what it missed, and costs nothing. The two can be held to each
other: a sentence the rule says reports someone, which a reading takes
as the text's own premise, is the critic's S4 regression found again.

## The order of all and some

The same mechanism as scope: `prove -s` now turns a premise's "every one
has some" (∀x∃y, or ∀x (A → ∃y (C ∧ B))) into "some one for every one"
(∃y∀x, keeping what is said of y alone with the some), and the other
way; `phil/scope` says where the argument turns. Over the readings
already made, at no cost: Aristotle's chief good (every pursuit aims at
some good, so there is a good every pursuit aims at) in 2 of the 3
readings that wrote the quantifiers, the third adding to its conclusion
a predicate nothing supplies; no finding of order in the other 155
gold readings, the 200 breadth readings, or the held-out sets.

## Canon and planted

Every passage scored so far has a fault the literature names: the gold
set (each with a reference), and the held-out sets, which were held out
from the tools' development but not from the models' training. A reader
that finds Aquinas's quantifier shift may be recalling Kenny. So the
gold files now say `known canon`, `score.py` counts canon and planted
apart, and `planted/` is a first set of 12 passages written here, with
faults built in (three unstated premises or converses, two quantifier
shifts, two modal scopes, two equivocations, three valid), each with
its encoding, checked by the prover. Not yet run (an estimated $10 at
the gold run's rate). Rescored, the 19 October gold run is all canon:

| Known | Class | Passages | Runs | Located | Detected | Missed | Valid | False alarm |
|---|---|---|---|---|---|---|---|---|
| canon | inference | 13 | 39 | 28 | 6 | 5 | 0 | 0 |
| canon | equivocation | 5 | 15 | 10 | 4 | 1 | 0 | 0 |
| canon | valid | 8 | 24 | 0 | 0 | 0 | 24 | 0 |

These are `score.py`'s counts, which take any finding of a fault at
the gold sentence as located, whatever it says. The hand judgement of
the same run ([above](#the-prompt-changed-48e3990c5a0a)) is the
measure: 21 of the 39 inference runs found the fault and none of the
15 equivocation runs did. A planted run will be judged by hand too.

## What next

1. Equivocation: `phil/senses` (above) finds it in about two runs of
   three, and a second asker adds nothing; most of what it missed was a
   shift between two claims, which its second question, a bridge
   between senses, is for ([above](#bridges-between-senses-b350a3107fa4)). Next: the
   same question put across works, to
   check `phil/corpus`'s alignments of one work's claim with
   another's, where a shift of sense between authors would hide.
2. Scope: `phil/scope` (above) finds it in 16 runs of 18, with no
   model; and the order of all and some the same way (above). Next: a
   held-out set from more than one author, and whether ought findings
   should be marked apart.
3. `argue/unfaithful` in dialogues: a claim put as a question and
   granted in the reply should be read from both.
4. For `phil/corpus`: a source is read for everything it claims
   (`phil/claims`, above); a report and its source are now held apart
   by the form two readers give one claim. Next: give the commentary's
   reader the source's statements, not only its atoms.
5. The gold set: revise `descartes-cogito` and `aquinas-fourth-way`;
   add held-out scope shifts before the next prompt change, as the
   equivocations now are.

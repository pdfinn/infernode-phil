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
"necessarily", and drew no new false alarm; the equivocations are
still not found.

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

## What next

1. Equivocation is the gap. Asking the reader did not close it; the
   next try is structural: a second, adversarial reading that is asked
   only whether any word changes its sense, whose answer splits the
   atom and is checked like any other reading.
2. A reader's comment that a sentence "could be read the other way" is
   the tool's to act on: write the other reading too, and let
   `phil/settle` ask the question it already asks when readings differ.
3. `argue/unfaithful` in dialogues: a claim put as a question and
   granted in the reply should be read from both.
4. For `phil/corpus`: a source read as everything it asserts, not one
   argument; and a finding name for "the source as read does not say
   it" that is not `misattributed`.
5. The gold set: revise `descartes-cogito` and `aquinas-fourth-way`;
   add held-out equivocations and scope shifts before the next prompt
   change.

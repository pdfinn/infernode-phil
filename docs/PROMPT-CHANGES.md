# Prompt changes, and how each was checked

The prompts in `lib/phil` are the code of every reading-shaped tool.
PHIL.md, "How a prompt change is checked", says a change is made only
with a record: the scripted tests unchanged, live runs before and
after with the same model, and what each finding did. This is that
record, newest first.

## senses: a new prompt (October 2026)

`lib/phil/senses` at `f4c9d13865f3`, new, with `phil/senses` and
`argue -e`. It asks of each atom more than one statement uses whether
the text means it in one sense throughout or in two; the prover decides
whether the argument turns on it. Its examples (end, right, free) are
from no passage of the bench.

**Scripted.** `tests/senses_test.sh`, new. `tests/run.sh`,
`argue_test.sh`, `read_test.sh` and `runner_test.sh` pass unchanged:
`argue` without `-e` sends the same requests as before.

**Live.** Claude Opus 5.5 through the Anthropic API. Alone on the gold
set's 78 readings (argue `48e3990c5a0a`) and the breadth sample's 200;
`argue -e -n 3 -k 3` on the five passages of `bench/heldout`. 389 calls,
770,378 tokens in and 147,174 out; none failed. A first attempt (52
calls) asked about no claims, because InferNode's sed broke on the
readings' symbols; fixed in `fd40062` and run again.

- Gold equivocations: shift found (`argue/equivocates`) in 8 runs of
  15, named where the reading was not valid in 2 more; none before.
- Held out: found in 7 of 15, named in 2, a related shift in 2.
- False alarms: 2 runs of 24 on the valid passages, both "infinite" in
  Aquinas's objection from evil, a charge commonly made; none in the
  breadth sample (1,112 claims, all one sense).

Details and each run's judgement: [bench/RESULTS.md](../bench/RESULTS.md),
`bench/results/senses-judged.tsv`.

## argue asks for senses, scope and order (October 2026)

`lib/phil/argue` from `a036b21b8816` to `48e3990c5a0a`. Four
instructions, from what the bench's gold set missed
([bench/RESULTS.md](../bench/RESULTS.md)): a word used in two senses
is two atoms, and the reader says which word shifts; "if p, then
necessarily q" can be [](p -> q) or p -> []q, and a reader who takes
one says the other was possible; the order of all and some is kept,
with an atom of two places where the sentence relates two things; a
step names the assumptions it needs in its `from`. The examples are
new (a bank, free; serves(x, y)), not the bench's passages.

**Scripted.** `tests/run.sh` (40 cases), `argue_test.sh`,
`read_test.sh`, `runner_test.sh` and `format_test.sh` pass unchanged.

**Live.** Claude Opus 5.5 through the Anthropic API, the prover as of
`30ccaf7`. The eight passages of the last check, `argue -n 3 -k 3`,
against that check's "after" runs; the gold set, `-n 3`, against the
bench's run of the same morning; one breadth passage from each of 25
works, `-n 2`. 711 calls, 1,439,891 tokens in and 498,471 out; none
failed.

| Passage | Verdict, three runs, before | after | `says` lines, before / after | Findings in every run, lost / gained |
|---|---|---|---|---|
| agents | 1 1 1 | 1 1 1 | 0 / 0 | none / none |
| circle | 1 1 1 | 1 1 1 | 0 / 0 | none / none |
| evil | 1 1 1 | 1 1 1 | 0 / 0 | none / none |
| firstway | 0 0 0 | 0 0 0 | 0 / 0 | none / none |
| kalam | 1 1 1 | 1 1 1 | 0 / 0 | none / none |
| hobbes | 1 1 1 | 1 1 1 | 0 / 0 | none / none |
| trust | 1 1 1 | 1 1 1 | 3 / 3 | none / none |
| critic | 0 0 0 | 0 0 0 | 12 / 10 | none / none |

- **The critic.** In two runs of three, S4 ("Locke replies that people
  keep their promises without a sovereign") was read as an objection
  to Hobbes's claim, `O1 ... against P1`, not as a premise `says
  locke`. Both are true to the sentence; the objection form carries no
  attribution, so `phil/corpus` loses the report. Not fixed: an
  objection or reply may need a `says` field of its own.
- **The gold set.** Judged by hand: inference faults found in 21 runs
  of 39 (18 before), in part in 4, named only in the reader's comment
  in 3 (Boethius's scope, in every run), missed in 11 (15); the
  quantifier shift in `aristotle-chief-good` found in every run (none
  before); equivocations found in part in 5 runs of 15 (2), none
  wholly; valid passages valid in 24 of 24 (23).
- **Breadth.** On the 25 passages, as many runs not valid (4 of 50);
  five passages changed a verdict, both ways, within the run-to-run
  disagreement already measured; readings agree on 63% of statements
  (68%); 89 `kind` fields (120); three passages marked a report in
  one run fewer.

Kept: it found what it was aimed at, with no false alarm, and its
costs elsewhere are small. The gains are measured on the set the
change was made from; they are not yet shown on held-out passages.

## argue asks for says and kind (October 2026)

`lib/phil/argue` from `deb947963d6f` to `a036b21b8816` (the first
twelve digits of its SHA-1, as each reading's last line gives them).
Two instructions added: a claim a sentence gives as someone else's is a
premise with `says` and whose it is, and is written again as a plain
premise only where the text also holds it; a premise whose kind is
plain gets `kind empirical`, `normative` or `conceptual`.

**Scripted.** `tests/run.sh` (40 cases), `argue_test.sh`,
`read_test.sh` and `runner_test.sh` pass unchanged.

**Live.** Claude Opus 5.5 through the Anthropic API. Eight passages,
each read with `argue -n 3 -k 3` (three runs, three readings a run)
before the change and again after: the five arguments of
`tests/data/argue/phil` (agents, circle, evil, firstway, kalam),
`tests/data/argue/says/trust.md`, and the two works of
`tests/data/corpus/sovereign` (hobbes, critic). 154 calls in all,
279,121 tokens in and 48,343 out; none failed.

| Passage | Verdict, three runs, before | after | `says` lines, before / after | Findings in every run, lost / gained |
|---|---|---|---|---|
| agents | 1 1 1 | 1 1 1 | 0 / 0 | none / none |
| circle | 1 1 1 | 1 1 1 | 0 / 0 | none / none |
| evil | 1 1 1 | 1 1 1 | 0 / 0 | none / none |
| firstway | 0 0 0 | 0 0 0 | 0 / 0 | none / none |
| kalam | 1 1 1 | 1 1 1 | 0 / 0 | none / none |
| hobbes | 1 1 1 | 1 1 1 | 0 / 0 | none / none |
| trust | 1 1 1 | 1 1 1 | 0 / 3 | none / none |
| critic | 0 0 0 | 0 0 0 | 0 / 12 | see below |

- **Attributions.** After the change every run marked exactly the
  sentences that report: trust's S1 as Hobbes's; the critic's S1, S2
  and S3 as Hobbes's and S4 as Locke's, the attributions a person
  reading by hand gives. No sentence of the six passages that report no
  one was marked. Before, trust's S1 was left out with a comment ("S1
  reports Hobbes's view and is not used"), and the critic's reports were
  read as the critic's own premises: S1 (Hobbes's claim) and S2 (what
  the critic says Hobbes holds, its denial) side by side, then Hobbes's
  claim defeated by Locke's reply as an objection.
- **Kinds.** 26 `kind` fields after: 17 empirical, 8 conceptual, 1
  normative. Not yet checked against a person's judgement.
- **The critic's findings.** Lost: those of the misreading (P1
  defeated by O1, the readings' premises inconsistent, the conclusion
  surviving 0). Gained: the conclusion does not follow, with its case,
  and "was the same thing named two ways?". The passage's last
  sentence ("So the argument's conclusion is false") is ambiguous:
  every run took it as the denial of Hobbes's first claim, said so in a
  comment, and as read it does not follow from the critic's evidence
  about industry. The tool's verdict is the honest one for that
  reading. The ambiguity is the test text's, written for the corpus
  tests, and is left in.
- **End to end.** The two works' readings after the change, aligned by
  hand (their readers had chosen the same atoms), given to
  `phil/corpus`: it finds the planted contradiction (S2), the
  misattribution (S3) and the source not in the corpus (S4), and holds
  the correct report (S1), as on the readings written by hand.

It also found two faults in `phil/corpus`, fixed with it: a formula's
canonical form lost the blank in `ought p`, and `claims/reported-only`
was decided by spelling, so a claim held in other words was called
held by no one and a denial was counted as held by whoever asserted
what it denies. It is now decided by `prove`: a reported claim is
held if some work's own commitments, the reporter's included, entail
it.

**How the runs reached the API.** InferNode's TLS does not trust the
certificate authority of the proxy this session's network goes
through, so the runs used `$wwbmodel` set to `openai
http://127.0.0.1:port/v1` and a relay on the host that forwarded each
request to the Anthropic API with the host's own HTTPS. The key stayed
in the relay; InferNode held none, and the readers were blinded as
always. On a machine whose network does not intercept TLS, the API is
reached directly (`anthropic`) and needs none of this.

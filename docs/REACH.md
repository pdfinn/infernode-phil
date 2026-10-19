# What the tools can reach

Which philosophical problems `argue`, `prove` and the corpus of
[CORPUS.md](CORPUS.md) can do something with, what they do with each,
and which they cannot touch. Written so that nobody takes a verdict
for more than it is, and so that the toolkit is pointed at work it
can help with.

## The rule of thumb

The tools reach a problem to the extent that three things hold:

1. The claims in dispute can be stated as propositions, or as one-place
   predicates of named things, with entailments among them.
2. The dispute is about which of those claims to hold, not about what
   it would mean to hold them.
3. What would count against a claim can be stated as a situation: a
   case in which some claims hold and others fail.

Where all three hold the toolkit does real work. Where one fails it
does the part that is left, and says so. Where none holds it has
nothing to say, and silence from it is not a verdict.

Validity is the cheap part and the tools never pretend otherwise:
`argue/valid 1` means the conclusion follows from the readings'
premises, not that the premises are true. What is not cheap, and
what the tools are for, is the bookkeeping that a debate needs and
nobody keeps: which premise does the work, which is never stated,
which objection was never answered, which case which theory fails,
and which disagreement is in the words.

## What `prove` decides

The exact procedures, so that the tables below can be read:

| Fragment | Decided? | How |
|---|---|---|
| Propositional | yes | cases, with clause learning |
| Propositional modal: S5, K, KT, KD, S5 with KD | yes | possible worlds, as many as the small-model property needs |
| Monadic first-order (one-place predicates, at most 4) | yes | a domain of 2^k individuals |
| Bernays–Schönfinkel (no `some` inside an `all`, once the conclusion is denied) | yes | one individual per `some` |
| Other first-order (relations, `some` within `all`) | partly | three individuals tried, then a Herbrand proof to four levels; otherwise `argue/undecided` |
| Quantified modal | no | refused, with the reason; `prove -t` exports TPTP for Vampire or E |
| Counterfactual, temporal, probabilistic, higher-order | no | not expressible; a reading that writes them as `->` is a misreading (below) |

A verdict of `argue/undecided` is a verdict: the tools say when they
cannot tell, and never guess.

## Within reach now

Problems the tools as built do something useful with, and what.

| Problem | Logic | What the tools give |
|---|---|---|
| Any argument from stated premises to a conclusion (a paper's, a chapter's, a thesis's) | classical, modal | valid or not, the refuting case, the missing premise, the unstated assumption, the premises not needed, circularity, the step nothing rests on |
| Inconsistent sets: the problem of evil (Mackie), the free-will trilemma (determinism, alternate possibilities, responsibility), the epistemic regress | classical | `prove -p`: every smallest set that cannot all be true, every coherent position and what it gives up; each is a known view or a new one |
| Chisholm's paradox and the paradoxes of standard deontic logic | `kd` | the four sentences found jointly inconsistent, the smallest set named; which formalization of the conditional obligation removes it |
| Ought implies can, and arguments mixing necessity with obligation | `s5kd` | what follows from the bridge principle and what does not; a modal word read two ways (`argue/modal-ambiguous`) |
| The modal ontological argument (Plantinga, Hartshorne) | `s5` | valid in S5; `argue/needed` shows the whole weight on "possibly, a maximally great being exists"; the same argument in K or KT, undecided or invalid |
| The knowledge argument (Mary), the zombie argument, the Chinese room as an argument | classical, modal | the deductive skeleton checked; the ledger shows the dispute sits in one premise ("Mary learns a new fact", "zombies are conceivable, so possible") |
| Analyses tested by cases: justified true belief and Gettier, alternate possibilities and Frankfurt, double effect and the trolley variants, Twin Earth and externalism, the violinist and the right to life | classical | a proposed analysis is a biconditional; each case is a valuation; `cases -r` says which analysis fails which case (`cases/fails`), and which case decides between two (`agenda/decisive`) |
| Syllogistic and monadic arguments: "all persons have a right to life; the fetus is a person" and their kin | monadic | decided exactly, with the individual that refutes |
| Objection and reply: a debate between two works, or an author's own objections | classical, modal | which attacks are attacks (`argue/misses`), which replies only restate, what survives under grounded semantics (`argue/defeated`, `argue/survives`) |
| Verbal disputes: compatibilist and libertarian "free will", "the same person" in personal identity, "knowledge" across the contextualist debate | classical | `align -e`: the claims restated with the word barred; equivalent, compatible, or still in conflict (`agenda/verbal`) |
| A field's unstated premises: what every work in a debate assumes and none argues | any | `agenda/field-assumes` over the corpus |
| What a premise costs: who holds it, what it commits them to, which case it fails | any | `ledger`, by rule, from the corpus |
| Positions nobody has taken: a coherent set of the debate's claims no work holds | classical | `prove -p` against `positions`: `agenda/unoccupied` |

Two notes on the table. The analyses row is the method of cases, and
the method of cases is how conceptual analysis has been done since
Plato; so analysis of the "what is knowledge" kind is within reach to
exactly the extent that it proceeds by cases, which is far. And the
first row is most of what any paper does; a tool that gets it right
over a whole thesis is already more than a reader can do in an
afternoon, which is what ARGUE-IN-PRACTICE.md records.

## At the edge

Problems the tools reach in part, with the part they miss named.

- **Relational first-order arguments.** The cosmological argument's
  "every event has a cause" together with "there is no infinite
  regress": the first is relational, the second is not first-order at
  all (well-foundedness). `prove` tries cases, seeks a proof, and says
  `argue/undecided`; `-t` sends it to Vampire, which may not do better.
  The reading is still useful: it shows which sentence carries the
  regress premise and whether anything else rests on it.
- **Quantified modal logic.** Necessitism, essentialism, the Barcan
  formulas, de re against de dicto: refused, exported. This is where
  much of analytic metaphysics lives, and the toolkit does not reach
  it. The propositional skeleton of such an argument can be read, with
  the quantifiers hidden in atoms, and the faithfulness check will say
  where that hides too much (`argue/quantifier`).
- **Counterfactuals.** "If the match had been struck it would have
  lit" is not `struck -> lit`; the material conditional makes every
  counterfactual with a false antecedent true. A model asked to read a
  text will write `->`, and `prove` will give a verdict that the text
  does not deserve. The toolkit has no conditional logic. Read
  `argue/converse` and the read-back of every conditional with this in
  mind, and treat an argument that turns on a counterfactual as out of
  reach.
- **Non-normal modal operators.** Van Inwagen's "no one has any choice
  about" is not a normal box: whether it agglomerates (`N p & N q ->
  N(p & q)`) is the disputed point (McKay and Johnson). `prove` reads
  any box as normal, so it decides that dispute by fiat, in the
  argument's favour. A reading that writes such an operator as `[]`
  has settled a question the text did not. The ledger can show which
  premise the agglomeration is, if the reading writes it out as one;
  it cannot be told to withhold it.
- **Arguments with numbers, induction or infinity.** The sorites, Zeno,
  arguments from infinite regress, the paradox of the heap. A finite
  sorites of n steps is propositional and `prove` shows that the
  tolerance premise is what fails; the problem, which is what
  tolerance means, is not touched.
- **Probabilistic and decision-theoretic arguments.** Fine tuning,
  Bayesian arguments for and against theism, Sleeping Beauty, Newcomb,
  Pascal's wager, the doomsday argument. The toolkit has no
  probabilities and no utilities. It can read the deductive skeleton
  ("if the probability is low then design", "one-boxing dominates")
  and check it, which is sometimes where the fault is, and it can hold
  the cases. The arithmetic it cannot do.
- **Higher-order arguments.** Gödel's ontological argument, as
  Benzmüller and Woltzenlogel Paleo checked it: higher-order modal
  logic in Isabelle. Out of reach here; the result (modal collapse)
  is the kind of finding this toolkit is for, found by a tool it is
  not.
- **Arguments that persuade without proving.** Analogy, example,
  consequences, authority. Today `prove` sees their premises as
  `argue/unused`. With the schemes layer of CORPUS.md they become
  defeasible steps with critical questions. The critical questions are
  the toolkit's contribution; whether the analogy is apt is a judgement
  it records and does not make.

## Out of reach

By kind, not by logic. No extension of `prove` changes these.

- **Whether a premise is true.** Always. The ledger prices a premise;
  it does not pay for it. `argue/assumed` names the claims the author
  would be asked to defend; the defence is theirs.
- **Whether an intuition is right.** A case's verdict ("this is
  possible", "this is not knowledge") is what the method of cases runs
  on, and the toolkit records it with its source. It cannot generate
  one with any authority, and a model's verdict is one more reader's,
  not a measurement.
- **How much a cost counts.** The ledger says a position fails two
  cases and assumes one unstated premise; another fails none and
  assumes four. Which is better is theory choice, and the gate policy
  that encodes a preference says so in its first line.
- **Description, genealogy, hermeneutics.** Phenomenology, the
  Foucauldian history of a concept, Wittgensteinian dissolution,
  Heidegger. Writing that proceeds by making a reader see something
  differently rather than by entailment formalizes to nothing, and the
  toolkit will say the work argues little. That is a limit of the
  toolkit, not a finding about the work. Political theory and
  intellectual history that argue through narrative are in this
  class, and a corpus of them will show mostly `argue/unused-step`.
- **What an author meant.** Readings are interpretations; the tools
  make several and report where they split (`argue/readings`). Which
  reading is Kant's is a scholarly question the split sharpens and
  does not settle.
- **Reframing a question.** The move that makes a problem go away by
  drawing a distinction (type and token, de re and de dicto) can be
  recorded as a new atom and the ledger will say whether it resolves
  more than it costs. No rule proposes it. If a model proposes one, it
  is a proposal with that provenance.
- **Aesthetics, particularist ethics, most of what is called
  continental philosophy,** for the reasons above together.

## What the toolkit guarantees

The claims it does make, which hold whatever the problem:

- Every verdict is exact over the reading it was given, or
  `argue/undecided`. No verdict is a guess.
- Every formal statement is pinned to the sentence it was read from,
  and the read-back check reports the misreadings it can see: a
  condition turned round, a negation lost, some made all. Silence from
  it is not proof of a faithful reading.
- Several independent readings are made where it matters, their
  disagreements are findings, and what settles them is a file a person
  can read and overwrite.
- Every judgement in the corpus says who made it: a rule, a reading
  (with its model, prompt and date), a person.
- A claim a work reports is never credited to it, and a secondary
  work's account of a primary one in the corpus is checked against
  that work's own reading.
- In English. The faithfulness read-back knows English words, current
  and obsolete, and no others; a work in another language is read
  through a named translation.

And the claim it never makes: that a conclusion is true. The nearest it
comes is the gate policy's measures, which are stated as a preference,
not a proof.

## Reading this before choosing a problem

For a new investigation, the question to ask first is which row of the
tables above the problem falls in. If it is in the first table, the
toolkit will carry it, and the benchmark in CORPUS.md shows the kind of
result to expect. If it is at the edge, decide which part the tools
will do and say the rest is by hand. If it is out of reach, use the
workbench's other tools, which read prose as prose, and leave `argue`
alone: a reading of a work that does not argue by entailment is noise
with a verdict attached.

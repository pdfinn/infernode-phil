# Where ϕwb stands

What is finished, what is not, and what published work says about the
hard parts. Carried from the Writer's Workbench's STATUS.md when the
tools moved, October 2026; update it as things move.

## Not finished, hardest first

1. **Faithful translation in `argue`.** The prover judges the argument the
   model wrote down. Several readings, compared, and a question where they
   differ, catch a misreading the model does not repeat. One it makes
   every time is now looked for by rule: `prove` reads each statement back
   into English from the atoms' meanings and sets it beside its sentence,
   finding a condition turned round (if, when, only if, every, only;
   if and only if made one way), a denial dropped or added (not, never,
   no, un-), most or some made all, either-or read inclusively or a plain
   or exclusively, and an atom none of whose words the sentence has.
   `argue -k` keeps the reading with fewest such mismatches, so a
   misreading most readings share no longer wins by votes. On a battery
   of tricky sentences it finds 12 of 13 planted misreadings and nothing
   in the right reading; what gets through is a paraphrase the words cannot
   show (an antonym, a synonym), which only a second, independent reader
   would catch.
2. **Exactness in `prove`.** Done as far as logic allows: the decidable
   fragments are decided, a proof is sought for the rest, and what is
   neither proved nor refuted is said to be undecided.
3. **A corpus.** `argue` and `prove` read one work; what they found
   most useful (unstated premises, objections unanswered, the reading
   a verdict turns on) are facts about a work's place in a debate.
   [CORPUS.md](CORPUS.md) is the design for reading a field's works as
   one: shared atoms, aligned claims, cases as a test suite, a ledger of
   what each premise costs, and the open questions, with a benchmark of
   settled debates to pass first. Proposed; step 0 of PHIL.md, the move, is done.

## What the research says

### Faithful formalization

- In every published LLM-plus-prover pipeline, almost every error is in the
  translation, not the proving: LINC (Olausson et al., EMNLP 2023),
  Logic-LM (Pan et al., 2023), SatLM (Ye et al., NeurIPS 2023). Dominant
  errors: implicit facts left out ("Harry is a person"), predicates too
  coarse to link, the same predicate with different arities, quantifier
  scope, exclusive versus inclusive or.
- Feeding the solver's errors back (what `argue` does now) fixes syntax,
  not meaning (Logic-LM). Separating translation from proving invites the
  model to write the conclusion in as an axiom ("Do LLMs Game
  Formalization?", Kim, Poiroux & Bosselut 2026).
- What works without a second model: several independent translations over
  one fixed vocabulary, compared for logical equivalence by the solver, the
  largest agreeing group kept and disagreement reported (CLOVER, Ryu et al.,
  ICLR 2025; Li et al., NeurIPS 2024); where readings differ, the solver
  builds a situation that tells them apart and one yes-or-no question
  settles it. Structural checks catch the rest: a conclusion that is an
  assumption, a verdict that rests on assumptions, an atom used once, a
  predicate with two arities. DeepA2 (Betz & Richardson 2022) is the
  nearest prior design to `argue`.
- Agreement among samples of one model is not proof of faithfulness: a
  model can be consistently wrong.

### Decision procedures

- One-place predicates only (no equality between variables): pushing the
  quantifiers inward (miniscoping, Behmann 1922) gives a sentence true in
  some model of at most c + e individuals, c the constants and e the
  existential quantifiers after negation normal form; grounding over that
  many decides it exactly. The textbook bound is 2^k for k predicates.
- ∃*∀* sentences (Bernays–Schönfinkel, EPR): Skolem constants only, so
  grounding over the constants and those decides exactly.
- Otherwise: a model finder over growing domain sizes (Mace4, Paradox) and
  a proof search (resolution with a given-clause loop, as in Prover9, E,
  Vampire; or a connection tableau, leanCoP), each with a limit, and an
  honest "undecided" when neither finishes. TPTP's SZS statuses (Theorem,
  CounterSatisfiable, ContradictoryAxioms, GaveUp) are the vocabulary.

## Done

1. `argue`: **done:** structural checks on every logic file (argue/unlinked,
   empty, impossible, begs, arity); several readings over one vocabulary
   (`argue -k`), compared by the prover (`prove -c`), the agreement
   reported, the best supported reading kept. Each disagreement becomes
   one yes-or-no question about a situation that separates the readings
   (`# question S1: Suppose ... Is S1 true then?`), put to the model
   afresh or left for a person (`argue -q`); the answers (`prove -c -a`)
   rule readings out before the best supported one is kept.
2. `prove`: **done:** the monadic (2^k) and ∃*∀* fragments decided exactly,
   the smallest counterexample found by trying fewer individuals first.
   Elsewhere, a Herbrand proof: the premises and the denied conclusion
   Skolemized, all taken over the named individuals and Skolem terms a
   level at a time (Gilmore's method, with the case-trier as the
   propositional engine), so a valid argument there is `argue/proved`;
   one refuted only by infinitely many individuals stays `argue/undecided`,
   and premises no finite case satisfies are inconsistent only when a
   proof shows it. TPTP output (`prove -t`), and every test argument's
   verdict held to Z3's (`tests/prove_z3_test.sh`).

## Later, to one side

- **Small models with the argument tools.**  A gpt-oss-20b model on an
  NVIDIA Jetson AGX is available to test `argue` and `prove` on real text
  (the benchmark the translation step still lacks), and free compute for
  fine-tuning with `prove` as the reasoning gate: an exact reward for a
  faithful translation and a correct verdict, and `tools/prove-bench`'s
  generator for graded examples.  Whether a model so trained reasons
  better without the tool is the question to measure.  Separate from the
  workbench's own work; the training belongs in infernode-os-llm.

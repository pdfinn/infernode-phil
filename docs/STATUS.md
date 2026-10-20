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
   settled debates to pass first. Step 1 is built: the corpus directory,
   `phil/corpus` holding each work's reports to what the reported work
   holds (by `prove`), and `phil/claims` reading a source for everything
   it claims. `phil/tree` lays a corpus out as files (a directory a
   claim, named by a hash of its formula, listing who asserts, denies,
   assumes and reports it) beside `notes/`, which is the researcher's:
   step 1 of [the namespace sketch](https://github.com/pdfinn/infernode-phiwb/issues/1),
   with no server. Measured on three commentaries and their sources
   ([bench/RESULTS.md](../bench/RESULTS.md)): a report and its source
   now turn on the form two readers give one claim. The rest (cases,
   ledger, agenda, the benchmark of settled debates) is not built.
4. **The bench** ([bench/](../bench/)). The tools on primary texts:
   26 canonical arguments with what the literature says is wrong with
   them, 100 passages from 25 works, three commentaries with their
   sources, and held-out sets for equivocation and scope. What it found
   and what was done about it is [bench/RESULTS.md](../bench/RESULTS.md):
   a missing step found nearly every time; a valid argument called valid
   23 times in 24 or better; attributions marked accurately; the noisiest
   check (`argue/negation`) halved.
5. **Independent readers.** `argue -k 3` reads with one model three
   times. Three samples of one model agree where its error is
   systematic, the question `settle` would ask is never asked, and the
   vote is unanimous and wrong. The mechanism for readers of different
   models is built (a different server at `/mnt/llm` for each,
   CORPUS.md) and is not yet how a bench run is made. What is wanted:
   two model families in every gold run, agreement reported within a
   model and across models apart; a reader of another kind (the
   skeleton by rule, MECHANICAL.md) counted as more than a third
   sample; and the bench scoring canon passages, whose faults a model
   may have read in the literature, apart from held-out ones.
6. **A second judge.** Every gold run was judged by the one person who
   wrote the gold (RESULTS.md says so: "a development result, not a
   test"). What is wanted: a second annotator over
   `results/gold-judged.tsv` and the `kind` sample, agreement reported
   (Krippendorff's alpha, with the bands named and their arbitrariness
   admitted), and keyed sets from outside the project beside the gold:
   forall x's exercises with its solutions booklet (CC BY 4.0), the
   Open Logic Project's, the corrected FOLIO labels, Benzmüller's
   ontological-argument benchmark (294 theorems and 45 non-theorems in
   TPTP) for the fragment `prove` covers, and the Microtext corpus for
   `argue/missing`. See bench/README.md, "Next".
7. **Sources.** Nothing here says whether a reference is on record, a
   canonical citation names a passage that exists, or a quotation
   matches its edition; `claims/attributed-unread` says which work
   would let a check run and stops there. [SOURCES.md](SOURCES.md) is
   the design, and [THREATS.md](THREATS.md) what the whole collection
   must defend against.

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
- The 2026 work on faithfulness has gone where the read-back went:
  VERGE found that on FOLIO only 29% of conclusions reach unanimous
  agreement among sampled formalizations (arXiv 2601.20055); a
  round-trip translation back to English is now standard and an
  October 2026 paper shows it misses premise sets that are jointly
  contradictory (arXiv 2610.20573), which `prove` reports as
  `argue/inconsistent`; another found a plain reverse translation
  "amplified the problem" and asks per-clause questions instead (arXiv
  2607.13303), which is what `settle`'s situation questions are. FOLIO's
  own labels were found flawed and re-annotated (arXiv 2606.02837); a
  bench that uses FOLIO uses the corrected set.
- Argument reconstruction scored on validity and faithfulness together,
  the pair `prove` over `argue` embodies: Ryu, Betz and colleagues'
  "Argument Reconstruction as Supervision" (arXiv, March 2026) reports
  a fine-tuned 8-billion-parameter open model at 95% validity against
  61% for a frontier commercial model. That is the case for the Jetson
  item below, with `prove` as the exact reward.

### Independence of readings

- Model judges are not independent. Across ten judges the average
  pairwise error correlation was 0.21, so ten behave like three or four
  independent ones, and the correlation is higher among frontier models
  of different providers; 28% of comparisons flipped under a
  confounder-aware aggregation (arXiv 2609.22512; CARE, ICML 2026).
  Model-to-model agreement on argument schemes and spans was found
  higher than human-to-human (Lindahl, *SEM 2025), which is a sign of
  shared bias as much as of skill. `argue -k` across one model inherits
  all of this; across models by bind, less; a reader that is a rule,
  none.
- Krippendorff's alpha bands (0.80 reliable, 0.667 tentative) are the
  norm in humanities annotation and are criticised as arbitrary; report
  the number and the band, not a pass.
- Reproducibility guidance for model use in the humanities (2026) asks
  for model name and version, access date, the full prompt and the
  decoding settings. The provenance line has the first four; the
  settings are the field to add (THREATS.md).

### Missing premises

- No published system has a prover compute the missing premise. Feng
  and Hunter (COMMA 2026) have a model propose implicit premises and a
  SAT solver confirm entailment, lifting three-class accuracy on the
  Microtext corpus from 0.426 to 0.555, code released; a two-agent
  debate holds the SemEval-2018 Task 12 premise-selection result.
  `argue/missing` computes up to three bridging premises by rule;
  measured on Microtext it would be the first comparison of the two
  ways.
- Fallacy detection is span classification (MAFALDA, 23 classes:
  GPT-3.5 at F1 0.138 against a human 0.186); none derives the name
  from the form, as `prove` does for affirming the consequent, denying
  the antecedent and the generalization from named cases.

### Proof assistants in philosophy

- Benzmüller and colleagues hand-formalize in Isabelle/HOL and, in
  September 2026, ported Gödel's and Scott's ontological arguments to
  Lean 4 and TPTP as a benchmark: 294 theorems and 45 non-theorems, of
  which five higher-order provers and cvc5 prove 227 within 10 s and
  232 within 60 s and none of the non-theorems (arXiv 2609.26806); a
  machine-checked faithfulness theorem for first-order modal embeddings
  (arXiv 2607.10880); three years of teaching with the method (arXiv
  2610.08214). No model is used anywhere in it. The benchmark is
  higher-order modal; `prove -t` could be measured on the fragment it
  reaches, with coverage stated.
- The cautionary tale: Oppenheimer and Zalta's 2011 Prover9
  simplification of the ontological argument turned out, on the
  project's own page, to be an artefact of how definite descriptions
  were eliminated. A sound prover over an unfaithful translation proves
  the wrong thing, which is why the read-back exists.

### Computational reflective equilibrium

- The nearest work to the ledger is Beisbart, Betz and Brun's formal
  model of reflective equilibrium (Ergo 8(15), 2021) and its Python
  packages `rethon` and `theodias` (github.com/re-models, 1.0.0, August
  2024), the latter Betz's theory of dialectical structures: positions
  over a sentence pool, an achievement function, the trolley case study
  (Rechnitzer, Synthese 2022). Later papers find the model raises
  agreement without uniqueness (Freivogel 2023) and that results depend
  on the simulation's setup (Freivogel and Cacean 2024). It is
  hand-built and propositional, with no text pinning and no attribution;
  the corpus is what would feed it. CORPUS.md, "Kin".
- Nothing encodes a philosophical debate across authors over shared
  atoms with attribution. AIFdb holds argument maps by the thousand
  (domains mostly not philosophy); IBM Debater's datasets are claim and
  evidence spans; Archelogos (scholar-written analyses of Plato and
  Aristotle, to 2003) is prose; the PhilPapers Survey is positions
  without arguments.

### Attribution, kinds, settling, senses

- Attribution and reported speech: PARC 3.0 (about 20,000 attribution
  relations) with BERT at macro-F1 82.6 on content spans, and poor
  transfer across corpora; hedge detection F1 60 to 68 classically.
  `says` by rule matched readers in 10 of 14 passages. None of it is
  evaluated on philosophy.
- Argument-scheme classification tops out at macro-F1 0.72 on one small
  set (EthiX, 686 arguments, 8 schemes) and 0.44 on another (USTV, 505
  arguments, 38 schemes), tested on ten arguments a scheme (ArgMining
  2025). `kind`'s 67% agreement with readers sits in that range; the
  disagreements are about what a claim says, not its words, which is
  why the next step is a small classifier on judged examples.
- Natural-language inference is ripe for `settle`: a DeBERTa-v3-small
  cross-encoder reports 91.65 on SNLI and 87.55 on MNLI-mismatched, and
  an xsmall binary model trained on 782,000 pairs including adversarial
  ones runs on a laptop. The 362 settle questions and answers in the
  breadth run are the test set.
- No philosophy-specific word-sense inventory exists. `senses`' two
  senses per atom, kept per corpus under `terms/` (issue #1), would be
  the first.

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

3. `senses`: **done, measured:** a claim used in two senses, or a
   premise that takes a word from one sense to another, put to a model
   as one narrow question and decided by the prover (split, or taken
   out, and proved again). From no equivocation found to about two runs
   in three, on the gold set and held out alike; no false alarm in 200
   breadth readings but one, defensible.
4. `scope`: **done, measured:** where an argument turns on the scope of
   a necessity or an ought (`p → □q` or `□(p → q)`), decided by the
   prover alone, no model. Boethius's foreknowledge argument in 6 runs
   of 6, the held-out objections in the *Summa* in 10 of 12.

## Later, to one side

- **Small models with the argument tools.**  A gpt-oss-20b model on an
  NVIDIA Jetson AGX is available to test `argue` and `prove` on real text
  (the benchmark the translation step still lacks), and free compute for
  fine-tuning with `prove` as the reasoning gate: an exact reward for a
  faithful translation and a correct verdict, and `tools/prove-bench`'s
  generator for graded examples.  Whether a model so trained reasons
  better without the tool is the question to measure.  Separate from the
  workbench's own work; the training belongs in infernode-os-llm.

## Deferred

- `./phil` and `./wwb` set up a command's session by hand: the network,
  factotum with the host's keys, and llmsrv for a command that asks a
  model. InferNode's login profile does the same from the session's own
  settings (`/lib/ndb/llm`, the proxy, `/mnt/audit`), and a runner could
  use it (`sh -l`); but the profile starts more than a command needs
  (speech, `/n`). Left for later, by decision (October 2026).

# argue and prove in practice

What `phil/argue` and `phil/prove` showed when run over real philosophy, and
how to use them well. Learned in October 2026 from passages of a
dissertation in political philosophy and from formal work on the same
author's arguments. The text, and what the tools found in it, stay with
the work itself, out of this repository: what is here is what the runs
taught about the tools. The goal was to test the tools, not to revise
the work.

## What they are good for

- **Unstated premises.** This was the most valuable result, and it was
  consistent. Every passage turned out to rest on a link the text never
  states, and `argue/assumed` named it. In one passage it was "using
  emergency powers outside the classical grounds shows the standards have
  been loosened". In another it was "suspending provisions of law is what
  the extraordinary measures are". Independent readings agreed on these
  gaps, which is the best evidence that they are the text's and not the
  reader's.
- **Interpretive choices that decide a verdict.** "Exceptions were
  permitted *when* the state was threatened" states a sufficient condition.
  The argument needs "*only* when". `argue/converse` catches the shift at
  the sentence, and the guidance now has the model write the converse as a
  visible assumption.
- **Where a paragraph's "thus" comes from.** A conclusion drawn with
  "thus" may rest on the paragraph before it, or on nothing it states.
  Three readings of one passage split three ways on exactly that, and the
  comparison isolated it as the one place they differed.
- **Which sentences do no work.** `argue/unused` and `argue/unlinked` show
  that examples and analogies (a philosophical illustration, a
  contemporary case) carry no deductive weight. This is not a fault in
  the text. It shows which sentences persuade and which prove.
- **Objections and replies.** A reply that only restates the premise in
  question (`argue/restates`) and an objection left unanswered are found
  reliably. The second was the most useful finding of the formal work.
- **Exhaustive positions** (`prove -p`). Over a family of axioms it gives
  every impossibility and every coherent position, as a z3 axiom lab does,
  with each set at its sentences.

## What they are not for

- **Truth.** Valid means only that the conclusion follows from the
  readings' premises.
- **Arguments by analogy, illustration or historical narrative.** These
  are the commonest kinds in the humanities, and propositional logic
  sees them as unused premises. Read `argue/unused` on them as "this
  persuades but does not prove", not as a fault.
- **One reading.** A single reading is one model's interpretation. The
  verdict often turns on a choice the text leaves open.

## How to use them

1. **Small units, or `-w`.** Give `argue` one paragraph, or one argument
   of a few paragraphs. A chapter given whole is flattened. For a chapter
   or an article, use `argue -w`: it reads the work section by section,
   lets each part rest on what earlier parts concluded, and checks the
   whole as one argument in steps (below).
2. **Always several readings:** `argue -k 3`. Of four passages, the three
   cold readings agreed on the verdict for only one. Shared vocabulary and
   the questions brought most of them together. The disagreements that
   remain are the findings.
3. **Shared vocabulary is essential.** `argue -k` gives later readings the
   first reading's atoms. Without that, nearly every apparent disagreement
   is one claim under two names (`trump_emergency`, `trump_invokes`;
   `unresolvable`, `!resolvable`), and the questions become nonsense.
   When readings are made by hand or by another program, give them all
   the same atom lines.
4. **Let the questions settle it** (`-q` to see them, `prove -c -a` with
   answers). Watch for `argue/answers-split`: it means every reading is
   partly right. Then make the reading by hand, taking each statement from
   the reading that answered it right.
5. **In Xenith, add `-x`.** Findings then give the sentence's characters
   (`file:#q0,#q1`), not its line, so a click selects the sentence even
   where a whole paragraph is one line of the source.
6. **Then `prove -v` on the reading kept.** It says what the conclusion
   follows from, and for each premise the case in which the conclusion
   fails without it.
7. **Read `argue/assumed` first.** Those are the claims the author would
   be asked to defend. Then read `argue/converse`, `argue/negation` and
   `argue/unfaithful`, the places where the reading may not be the text.
8. **For the writer's own reading,** `argue -s mine.logic` sets a cold
   reading beside it, in the writer's atoms.
9. **For many interacting claims,** state them as P lines (with `rivals`
   for alternatives) and use `prove -p`, not one conclusion at a time.

## Real readings, through the API and the Claude CLI

The findings above were first made with readings written by hand in the way
`argue -k` writes them. Afterwards the same four passages went through a real
model, `argue -k 3`, by three ways: `llmsrv`, the API called directly
(`wwbmodel=anthropic`), and the host's Claude CLI (`wwbmodel='os claude -p'`).
The key was in factotum. Each passage took under a minute.

- The real readings found the same unstated links as the hand-made ones in
  all four passages (`argue/missing` named one in the words of the reading
  that had stated it).
- **Runs vary.** One run of a passage had its three readings split on the
  conclusion and asked a question. The next run had them agree on every
  statement. Run `argue -k 3` more than once on a passage that matters, and
  trust what survives both runs.
- **The CLI read less carefully than the API.** Through `claude -p` the
  instructions arrive as part of the question, not as a system prompt. Its
  readings disagreed more, and its kept reading of the classical passage
  left the conclusion unlinked. The API and `llmsrv` readings agreed on
  every statement.
- **Models reason before answering**, even when told to answer yes or no and
  nothing else. `argue` now takes the last line that is only yes or no.
  Before that, a reasoned answer was silently dropped and the question went
  unanswered.
- **A model may write the file twice**, a draft and then a correction. The
  prover reports the duplicate names, and the file goes back to the model,
  which then writes it once.

## Which model

Opus 5.5, Sonnet 5.5 and Haiku 5.5 each read the four passages twice
(`argue -k 3` through the Claude CLI, so every model got the instructions the
same way, as part of the question).

- **Opus** wrote the unstated links as assumptions, where `argue/assumed`
  shows them. In both runs of the classical passage it gave exactly the two
  links found by hand. In one of two runs of another passage it gave
  that passage's two links.
- **Sonnet** was as fast and agreed with itself more often. But it tended to
  read the missing link into a sentence, usually the conclusion's own,
  which makes the reading valid with nothing assumed. Its classical reading
  was valid both times only because of that. `argue/own-sentence` now
  flags it.
- **Haiku** took more than twice as long, its readings agreed least, and
  one of them was a file the prover could not read, which stopped the
  comparison (argue now sends every reading back when that happens).
- **Some findings held for every model in every run,** and some splits
  did too. Those belong to the text, not to the model.

Use Opus for the readings. With Sonnet, read `argue/own-sentence` before
trusting a valid verdict.

**Through llmsrv, repeated.** The same comparison was run again through
`llmsrv`, with the key in factotum and the model chosen per session
(`argue -m opus`). Here the instructions arrive as a system prompt.
- **Sonnet** improved most. On the classical passage it wrote both
  unstated links as assumptions in one of two runs, as Opus did, instead
  of reading them into the conclusion's sentence. Opus and Sonnet took
  the same time (about 50 seconds a passage). Haiku took almost twice as
  long and its readings agreed least.
- **A conclusion's gap** was now often written as an assumption, giving
  valid with `argue/assumed`. Other runs left it open,
  giving invalid with `argue/missing`. Both name the same gap. Which you
  get depends on whether the assumption question is answered yes, and
  models lean towards yes.
- **The first modal finding on real text:** a conclusion's "must" was
  read as a plain condition by two readings and as an obligation by the
  third, so `argue/modal-ambiguous`.
- **The CLI was never the weaker model, only the worse request.** By
  default `claude -p` wraps every request in Claude Code's own system
  prompt and tool definitions, a coding agent's, so argue's instructions
  arrive as part of the question. Given them as its system prompt and its
  tools off (`--system-prompt {system} --tools ''`, or through
  InferNode's claude-gate and llmsrv, which do the same), the CLI read as
  well as the API. On the classical passage both Opus runs and both
  Sonnet runs wrote both unstated links as assumptions, and the readings
  disagreed no more than through the API. Opus and Sonnet are close; use
  Opus where the text is hardest.

## A whole chapter

`argue -w -k 3 -r a-b` read a chapter of 17 parts with Opus in about
forty minutes. Inside sections it found what it finds in single
passages; across them, the chapter's conclusion resting on a few earlier
steps, one of which did not follow, so that the conclusion fell with it
(`argue/defeated`). Most sections' conclusions bore on nothing after
them: that is what a survey looks like, and the output says so in one
line. What made it work: the parts must share a vocabulary, a later part
must be able to rest on an earlier part's conclusion, and the joining
step must be allowed to say that the main conclusion is a part's own.

## What the run changed in the tools

- Readings that put the main conclusion at different sentences are asked
  which one it is (`M`), instead of a question about one sentence's
  content.

- Readings that differ in an assumption are now asked about it, one
  question for each such assumption ("does the text's argument take this
  for granted?", `U1`). The real runs had met this twice, with the verdict
  decided by an assumption nothing asked about. Models lean towards yes to
  such a question, so the answer chooses the reading, but it doesn't prove
  the text relies on it.

- `prove -c` says when the answers rule out every reading, and keeps the
  reading that agrees with most of them. It asks each question once.
- A step drawn at no sentence of its own is not reported as an unstated
  assumption.
- `argue/unlinked` gives one line per statement.
- "Not just X but Y" is not a negation. "Either ... or" inside a condition
  is not questioned as exclusive.
- `argue`'s instructions cover "when" against "only when", and say that
  examples and statements of what the work will do are not premises. With
  these, the three readings of one passage agreed on every statement,
  where before they had disagreed on one of five.

## A whole thesis

`argue -w -k 3` on a doctoral thesis of about 2,400 sentences, its
chapters pulled in by `\input`, through the Claude CLI (Opus): 105 parts
of up to 30 sentences, three readings each, then one call to join them.
It ran for several hours. A container restart cut the first attempt
short at part 38, which is why `-c` exists: the parts finished are kept
and only the rest are read.

What the run changed:

- **The closing sentences were the opening ones.** The joining prompt
  shows the work's first and last sentences; without `-r`, the "last"
  were the first part's, because the regular expression meant to find
  the last part matched the first (Inferno's is not greedy).
- **The thesis stated twice was called circular.** The model took the
  abstract's statement of the thesis as the main conclusion; a chapter
  argued the same claim as a step, and `prove` said the conclusion only
  restated it. `join -t` now makes the step argued the conclusion and
  notes where else it is stated.
- **The parts contradicted each other, and nothing said so.** Each
  step's premises were consistent; read together they were not. Two
  parts had declared one atom name for two different claims, and
  `join` kept the first meaning, so the second part's formulas spoke of
  the first part's claim. `prove` now reads a stepped file's premises
  and assumptions together and names the smallest set that contradicts;
  `join` gives an atom a later part declares with another meaning a
  name of its own (`outmoded_104`). The first account of this, that the
  joining model had misused the atom, was wrong: a read-back of the
  joining's own assumptions in their atoms' meanings was added for it,
  and is kept as a safeguard, but this contradiction came from `join`.
- **A suggestion drawn from that contradiction.** `argue/missing`
  proposed the same contradictory set to every failing step, since from
  a contradiction anything follows. A set that contradicts is no longer
  proposed.

- **A kept reading lacked what the answers affirmed.** Where the answers
  to the questions split the readings, argue kept the one that agreed
  with most; on one part that reading lacked the assumption an answer
  had said the text takes for granted, and was invalid where the
  answers made it valid. The assumption is now added to it.
- **A thesis stated in the abstract was called circular again.** Read
  as a part of its own, the abstract became a step, and the joining
  drew the main conclusion from it and from a chapter's step with the
  same claim. A conclusion that restates a step argued elsewhere is
  proved by it; only one that restates a premise or an assumption is
  circular.

Re-read and re-joined with these fixes, the whole holds: the main
conclusion follows, by assumptions the text never states, and the
steps that fail lie off its path. Three joinings of the same parts
chose the same main conclusion and agreed on most of the steps it
rests on.

## Still open

- **Modal words.** "May" (possibility, permission, or hedge) splits
  readings between propositional and modal logic, and the modal reading
  can turn a valid argument invalid. Questions about modality are not
  asked yet.

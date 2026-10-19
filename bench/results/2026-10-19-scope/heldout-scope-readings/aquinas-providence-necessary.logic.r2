# the argument of aquinas-providence-necessary.md as claude-opus-5-5 read it: check that it says what the text says
# the argument of aquinas-providence-necessary.md: check that it says what the text says
logic	s5
# The modal logic here is propositional, so the argument is written for a single thing foreseen, taken as typical of all things foreseen.
# "Of necessity", "necessarily follows" and "cannot be frustrated" are all read as alethic necessity and impossibility.
atom	eternal	the providence of God is eternal
atom	cause_pre	the thing foreseen has a per se cause, present or past, namely divine providence, which pre-exists
atom	follows_nec	the effect necessarily follows from (flows of necessity from) its cause
atom	happens	the thing foreseen happens
atom	frustrated	divine providence is frustrated
# S2: an effect that has a per se cause, present or past, which it necessarily follows, happens from necessity.
P1	S2	cause_pre ∧ follows_nec → □happens	says aristotle
P2	S2	cause_pre ∧ follows_nec → □happens
# S3: the providence of God, since it is eternal, pre-exists.
P3	S3	eternal
P4	S3	eternal → cause_pre
C1	S3	cause_pre	from P3 P4
# S3: the effect flows from providence of necessity, because divine providence cannot be frustrated.
P5	S3	¬◇frustrated
P6	S3	¬◇frustrated → follows_nec
C2	S3	follows_nec	from P5 P6
# S4: the thing foreseen happens from necessity. "Imposes necessity" is read as []happens.
C	S4	□happens	from P2 C1 C2
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

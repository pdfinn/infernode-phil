# the argument of aristotle-chief-good.md as claude-opus-5-5 read it: check that it says what the text says
# S1 reports P1 as common opinion ("it is thought") with no named source, so it is written as a plain premise.
# The conclusion swaps the quantifier order of the premise: "every pursuit aims at some good" becomes "some good is aimed at by every pursuit".
atom	pursuit(x)	x is an art, a science reduced to a teachable form, an action or a moral choice
atom	good(y)	y is a good
atom	aims(x, y)	x aims at y
P1	S1	∀x (pursuit(x) → ∃y (good(y) ∧ aims(x, y)))
# "the Chief Good is that which all things aim at", read as: there is a good at which every pursuit aims
C	S1	∃y (good(y) ∧ ∀x (pursuit(x) → aims(x, y)))	from P1
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

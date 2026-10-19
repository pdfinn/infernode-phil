# reading 3 of aristotle-chief-good.md by claude-opus-5-5
# S1: "it is thought" reports common opinion with no named author, so P1 is a plain premise.
# Read as: every pursuit aims at some good, so some one thing, the Chief Good, is aimed at by all.
# This is a some/all order shift; it is written as the text gives it.
atom	pursuit(x)	x is an art, a science reduced to a teachable form, an action, or a moral choice
atom	good(x)	x is a good
atom	aims(x, y)	x aims at y
atom	chief(y)	y is the Chief Good
P1	S1	∀x (pursuit(x) → ∃y (good(y) ∧ aims(x, y)))
C	S1	∃y (chief(y) ∧ good(y) ∧ ∀x (pursuit(x) → aims(x, y)))	from P1
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

# the argument of aristotle-chief-good.md as claude-opus-5-5 read it: check that it says what the text says
# Aristotle, Nicomachean Ethics I.1. "It is thought" reports common opinion with no named author.
# The text argues from it, so it is written as a plain premise.
# The step from "everything aims at some good" to the aptness of the description is left as the text gives it.
atom	art(x)	x is an art
atom	science(x)	x is a science reduced to a teachable form
atom	action(x)	x is an action or moral choice
atom	aims_good(x)	x aims at some good
atom	apt_description	"that which all things aim at" is a common and by no means a bad description of the Chief Good
P1	S1	∀x (art(x) ∨ science(x) ∨ action(x) → aims_good(x))
C	S1	apt_description	from P1
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

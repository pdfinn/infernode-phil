# the argument of aristotle-function.md as claude-opus-5-5 read it: check that it says what the text says
atom	carpenter_work	the carpenter has certain works and courses of action
atom	cobbler_work	the cobbler has certain works and courses of action
atom	members_work	eye, hand, foot and generally each of man's members has manifestly some special work
atom	man_work	the whole Man, as Man, has some work of his own and is not left by Nature without a work
P1	S1	carpenter_work ∧ cobbler_work	kind empirical
P2	S1	members_work	kind empirical
# The rhetorical question rests on an analogy: if the crafts and each member have a work, so must man as a whole.
A1	-	carpenter_work ∧ cobbler_work ∧ members_work → man_work
C	S1	man_work	from P1 P2 A1
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

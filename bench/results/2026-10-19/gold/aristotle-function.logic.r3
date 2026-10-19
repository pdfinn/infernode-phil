# reading 3 of aristotle-function.md by claude-opus-5-5
# S1 is one rhetorical question making an argument from analogy.
# Its "as ... so too" states the step from the members to the whole Man.
# The first half implies it would be absurd for crafts to have works while Man has none.
# That implied step is given as an assumption, since the text does not state it outright.
atom	carpenter_work	the carpenter has certain works and courses of action
atom	cobbler_work	the cobbler has certain works and courses of action
atom	members_work	eye, hand, foot and generally each of man's members manifestly has some special work
atom	man_work	Man as Man, the whole Man as distinct from his members, has some work of his own and is not left by Nature without a work
P1	S1	carpenter_work	kind empirical
P2	S1	cobbler_work	kind empirical
P3	S1	members_work
P4	S1	members_work → man_work
A1	-	carpenter_work ∧ cobbler_work → man_work
C	S1	man_work
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

# the argument of aristotle-function.md as claude-opus-5-5 read it: check that it says what the text says
# Aristotle's function argument, put as a rhetorical question: the expected answer is that
# man as man has a work of his own, as the crafts and the bodily members do.
atom	craftsmen_have_work	carpenter and cobbler have certain works and courses of action
atom	members_have_work	eye, hand, foot, and generally each of man's members, has manifestly some special work
atom	man_has_work	Man as Man, the whole Man as distinct from his members, has some work of his own
P1	S1	craftsmen_have_work	kind empirical
P2	S1	members_have_work	kind empirical
# The inference rests on the analogy signalled by "while ... none" and "as ... so too";
# the text never states it as a general principle.
A1	-	craftsmen_have_work ∧ members_have_work → man_has_work
C	S1	man_has_work	from P1 P2 A1
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

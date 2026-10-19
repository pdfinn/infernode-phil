# the argument of aristotle-function.md as claude-opus-5-5 read it: check that it says what the text says
# Aristotle's function argument: the whole of it is in S1, a rhetorical question put as an argument from analogy.
# The rhetorical question is read as asserting that Man has a work of his own.
atom	carpenter_work	carpenter and cobbler have certain works and courses of action
atom	members_work	eye, hand, and foot, and generally each of his members, has manifestly some special work
atom	man_work	the whole Man, as Man, has some work of his own (is not left by Nature without a work)
P1	S1	carpenter_work	kind empirical
P2	S1	members_work	kind empirical
# The "so too" step from crafts and members to the whole Man is never stated as a general principle; the text plainly relies on it.
A1	-	carpenter_work ∧ members_work → man_work
C	S1	man_work	from P1 P2 A1
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

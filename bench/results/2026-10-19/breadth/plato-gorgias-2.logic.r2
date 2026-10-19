# the argument of plato-gorgias-2.md as claude-opus-5-5 read it: check that it says what the text says
# S2 is phrased as what Callicles "surely does not think"; I read it as the claims that two men are not better than one and the slaves are not better than their master.
# S3's "if they are not the stronger" is taken as the conclusion Socrates draws: the better are not the stronger.
atom	better_is_stronger	the better are the stronger (the superior)
atom	slaves_stronger	Callicles' slaves are stronger than he is
atom	slaves_better	Callicles' slaves are better than he is
atom	two_stronger	two men are stronger than one
atom	two_better	two men are better than one
P1	S2	¬slaves_better
P2	S2	¬two_better
P3	S2	slaves_stronger	kind empirical
A1	-	two_stronger
A2	-	better_is_stronger → (slaves_stronger → slaves_better) ∧ (two_stronger → two_better)	kind conceptual
C	S3	¬better_is_stronger
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

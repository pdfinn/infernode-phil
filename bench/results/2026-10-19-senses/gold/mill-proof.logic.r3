# the argument of mill-proof.md as claude-opus-5-5 read it: check that it says what the text says
# "desirable" changes sense. In S3, by analogy with "visible" and "audible" (S1-S2),
# it means capable of being desired. In S5-S6 it means worthy of desire, a good.
# Each sense gets its own atom, and they are not joined, so the step to "a good" is left as the text gives it.
# S1-S2 only illustrate, and S4 is background; both are left out.
atom	desired_own	each person, so far as he believes it attainable, actually desires his own happiness
atom	desirable_able	each person's happiness is desirable in the sense of capable of being desired (as visible = can be seen)
atom	own_good	each person's happiness is a good to that person (desirable as worthy of desire)
atom	general_good	the general happiness is a good to the aggregate of all persons
atom	happiness_end	happiness has made out its title as one of the ends of conduct
atom	criterion_morality	happiness is one of the criteria of morality
P1	S3	desired_own → desirable_able	kind conceptual
P2	S5	desired_own	kind empirical
C1	S6	desirable_able	from P1 P2
# S6 moves from "desired" to "a good"; that is the second sense of "desirable", and no premise links the two.
C2	S6	own_good	from C1
C3	S6	general_good	from C2
A1	-	general_good → happiness_end
A2	-	happiness_end → criterion_morality
C	S7	happiness_end ∧ criterion_morality	from C3 A1 A2
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

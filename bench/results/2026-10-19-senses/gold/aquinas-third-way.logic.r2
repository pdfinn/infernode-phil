# reading 3 of aquinas-third-way.md by claude-opus-5-5
# Aquinas, the third way (S1 only introduces it and is left out).
# S2-S11 are written in plain propositional logic: the modal force sits inside the atoms as given.
# S4's step from each_sometime_not alone is the familiar quantifier shift (each thing is at some time not, so at some time nothing is). It is written as drawn only from P3 so that the prover sees the gap.
atom	generated_corrupt	things are found in nature to be generated and to corrupt
atom	contingents_exist	there are things in nature possible to be and not to be
atom	all_contingent	everything is possible not to be
atom	each_sometime_not	each thing that is possible not to be at some time is not
atom	once_nothing	at one time there could have been (was) nothing in existence
atom	begin_needs_existing	that which does not exist only begins to exist by something already existing
atom	now_nothing	even now there would be nothing in existence
atom	necessary_exists	there exists something the existence of which is necessary
atom	all_caused	every necessary thing has its necessity caused by another
atom	infinite_regress	there is a going on to infinity in necessary things which have their necessity caused by another
atom	self_necessary	there exists some being having of itself its own necessity, not receiving it from another
atom	god	there exists what all men speak of as God
P1	S2	generated_corrupt	kind empirical
P2	S2	generated_corrupt → contingents_exist
C1	S2	contingents_exist	from P1 P2
P3	S3	each_sometime_not
C2	S4	all_contingent → once_nothing	from P3
P4	S5	begin_needs_existing
P5	S5	begin_needs_existing ∧ once_nothing → now_nothing
C3	S6	once_nothing → now_nothing	from P4 P5
P6	S6	¬now_nothing	kind empirical
C4	S7	¬all_contingent	from C2 C3 P6
# S7 passes from "not all beings are merely possible" to "something necessary exists" without saying so.
A1	-	¬all_contingent → necessary_exists
C5	S7	necessary_exists	from C4 A1
P7	S8	necessary_exists → all_caused ∨ ¬all_caused
P8	S9	¬infinite_regress
# The text assumes that if every necessary thing were caused by another, the chain would go on to infinity.
A2	-	all_caused → infinite_regress
# The text assumes that a necessary thing whose necessity is not caused by another is a being necessary of itself.
A3	-	necessary_exists ∧ ¬all_caused → self_necessary
C6	S10	self_necessary	from C5 P7 P8 A2 A3
P9	S11	self_necessary → god	kind conceptual
C	S11	god	from C6 P9
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

# reading 3 of aquinas-third-way.md by claude-opus-5-5
# The modal words (possible to be and not to be, could have been, impossible, must exist)
# are carried inside the given atoms, so no modal logic line is used.
# S3 to S4 moves from "each thing at some time is not" to "at one time nothing was".
# No premise bridging that step is stated, so none is added.
atom	generated_corrupt	things in nature are found to be generated and to corrupt
atom	contingents_exist	we find in nature things that are possible to be and not to be
atom	all_contingent	everything is possible not to be
atom	each_once_not	each thing, being possible not to be, at some time is not
atom	once_nothing	at one time there was nothing in existence
atom	something_began	something began to exist after a time when nothing was in existence
atom	now_nothing	even now there is nothing in existence
atom	necessary_exists	there exists something the existence of which is necessary
atom	self_necessary	there exists some being having of itself its own necessity, not receiving it from another
atom	only_caused_necessity	every necessary thing has its necessity caused by another
atom	infinite_regress	there is an infinite series of necessary things having their necessity caused by another
atom	god	God exists
A3	-	each_once_not → once_nothing
P1	S2	generated_corrupt	kind empirical
P2	S2	generated_corrupt → contingents_exist
P3	S3	all_contingent → each_once_not
C1	S4	all_contingent → once_nothing	from P3
P4	S5	once_nothing → ¬something_began
P5	S6	once_nothing ∧ ¬something_began → now_nothing
C2	S6	once_nothing → now_nothing	from P4 P5
P6	S6	¬now_nothing	kind empirical
# Assumption: what is not merely possible is necessary.
A1	-	¬all_contingent → necessary_exists	kind conceptual
C3	S7	¬all_contingent ∧ necessary_exists	from C1 C2 P6 A1
P7	S8	necessary_exists → only_caused_necessity ∨ self_necessary
P8	S9	¬infinite_regress
# Assumption: if every necessary thing had its necessity caused by another, there would be an infinite series of them.
A2	-	only_caused_necessity → infinite_regress
C4	S10	self_necessary	from C3 P7 P8 A2
P9	S11	self_necessary → god	kind conceptual
C	S11	god	from C4 P9 A3
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

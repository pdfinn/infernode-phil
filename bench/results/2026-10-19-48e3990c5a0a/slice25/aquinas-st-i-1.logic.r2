# the argument of aquinas-st-i-1.md as claude-opus-5-5 read it: check that it says what the text says
# S2 (the animal/man contrast) only illustrates S1 and is left out.
# S1's "may" is read as a plain claim about meaning, not as a modal.
# "Figure" in S4 is read as "nature".
atom	incl_less_common	something may be included in the meaning of a less common term which is not included in the more common term
atom	distinct_q_person	it is one thing to ask the meaning of "person" in general and another to ask the meaning of "person" as applied to God
atom	person_indiv_subst	"person" in general signifies the individual substance of a rational nature
atom	indiv_distinct	the individual in itself is undivided but is distinct from others
atom	person_signifies_distinct	"person" in any nature signifies what is distinct in that nature
P1	S1	incl_less_common	kind conceptual
A1	-	incl_less_common → distinct_q_person
C1	S3	distinct_q_person	from P1 A1
P2	S4	person_indiv_subst	kind conceptual
P3	S5	indiv_distinct	kind conceptual
A2	-	person_indiv_subst ∧ indiv_distinct → person_signifies_distinct
C	S6	person_signifies_distinct	from P2 P3 A2
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

# the argument of aquinas-st-i-1.md as claude-opus-5-5 read it: check that it says what the text says
atom	less_common_term_includes_more	something may be included in the meaning of a less common term which is not included in the more common term
atom	animal_questions_differ	it is one thing to ask the meaning of the word animal, and another to ask its meaning when the animal in question is man
atom	person_questions_differ	it is one thing to ask the meaning of "person" in general, and another to ask the meaning of "person" as applied to God
atom	person_individual_rational_substance	"person" in general signifies the individual substance of a rational figure
atom	individual_undivided_distinct	the individual in itself is undivided, but is distinct from others
atom	person_signifies_distinct	"person" in any nature signifies what is distinct in that nature
atom	human_person_flesh_bones_soul	in human nature "person" signifies this flesh, these bones and this soul, the individuating principles of a man, which belong to the meaning of a particular human person though not to "person" in general
P1	S1	less_common_term_includes_more	kind conceptual
C1	S2	animal_questions_differ	from P1
P2	S4	person_individual_rational_substance	kind conceptual
# S4 is introduced with "For" as the ground of S3, read together with the general point of S1
C2	S3	person_questions_differ	from P1 P2
P3	S5	individual_undivided_distinct	kind conceptual
C	S6	person_signifies_distinct ∧ human_person_flesh_bones_soul	from P2 P3
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

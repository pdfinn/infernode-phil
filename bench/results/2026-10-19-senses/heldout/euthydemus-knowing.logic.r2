# the argument of euthydemus-knowing.md as claude-opus-5-5 read it: check that it says what the text says
# Sophist's argument (Euthydemus): you know something, so you are knowing; you do not know some things, so you are not knowing; hence you are and are not knowing.
# "knowing" shifts sense: the sophist uses it unqualified ("a knower" outright),
# while Socrates (S4, S8) restricts it to "knowing of what I know" and "not knowing of what I do not know".
# The qualified senses get their own atoms; the sophist's conclusion uses only the unqualified one.
atom	knows_something	you know something
atom	knowing	you are knowing (unqualified, as the sophist uses it)
atom	knowing_of_known	you are knowing of the knowledge which you have (Socrates' qualified sense)
atom	knows_all	you know all things
atom	ignorant_something	there are things which you do not know
atom	not_knowing_of_unknown	you are not knowing of that which you do not know (Socrates' qualified sense)
P1	S2	knows_something	kind empirical
P2	S3	knows_something → knowing	kind conceptual
P3	S4	knows_something → knowing_of_known	kind conceptual
P4	S5	knowing → knows_all	kind conceptual
P5	S6	ignorant_something	kind empirical
P6	S6	ignorant_something → ¬knows_all	kind conceptual
P7	S7	ignorant_something → ¬knowing	kind conceptual
P8	S8	ignorant_something → not_knowing_of_unknown	kind conceptual
C	S9	knowing ∧ ¬knowing	from P1 P2 P5 P7
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

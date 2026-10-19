# the argument of euthydemus-perish.md as claude-opus-5-5 read it: check that it says what the text says
# The sophist's argument (Euthydemus): "to be" shifts sense between S7 and S9.
# In S7 "to be what he is" is predicative (to be ignorant / not wise);
# in S9-S10 "to be" / "not to be" is existential (to exist / to perish).
# The two senses get separate atoms; S9 is written as the bridge the text asserts.
atom	wish_wise	you wish Cleinias to become wise
atom	wise	Cleinias is wise as yet
atom	wish_not_ignorant	you wish him to become wise and not to be ignorant
atom	wish_no_longer_what_he_is	you wish him to be what he is not, and no longer to be what he is (predicative "be": no longer to be ignorant)
atom	wish_perish	you wish him no longer to be, i.e. to perish (existential "be")
atom	good_friends	you are good lovers and friends of your favourite
P1	S2	wish_wise	kind empirical
P2	S4	¬wise
P3	S6	wish_not_ignorant	kind empirical
P4	S7	wish_wise ∧ ¬wise → wish_no_longer_what_he_is
C1	S7	wish_no_longer_what_he_is	from P1 P2 P4
# S9: the equivocation on "to be" is in this step: predicative "no longer be what he is" is taken to mean existential "no longer be"
P5	S9	wish_no_longer_what_he_is → wish_perish
C2	S9	wish_perish	from C1 P5
P6	S10	wish_perish → ¬good_friends	kind normative
C	S10	¬good_friends	from C2 P6
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

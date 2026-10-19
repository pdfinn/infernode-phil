# the argument of phaedo-opposites.md as claude-opus-5-5 read it: check that it says what the text says
# Quantified reading of the argument from opposites. S4 and S17 say "of necessity",
# but modality is not combined with quantifiers here, so it is dropped.
# The worked examples (S6, S8, S10, S27) only illustrate and are left out.
atom	has_opposite(x)	x has an opposite
atom	generated_from_opposite(x)	x is generated out of its opposite
atom	souls_exist_below	our souls exist in the world below
P1	S17	∀x (has_opposite(x) → generated_from_opposite(x))
P2	S31	has_opposite(life)
C1	S39	generated_from_opposite(life)	from P1 P2
A1	-	generated_from_opposite(life) → souls_exist_below
C	S41	souls_exist_below	from C1 A1
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

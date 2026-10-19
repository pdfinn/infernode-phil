# the argument of aquinas-st-i-4.md as claude-opus-5-5 read it: check that it says what the text says
# S1 is only a heading. S2 is written as the objection the reply answers.
# S4 also states an order (nutritive, then sensitive, then intellectual),
# which is not argued for here; only the claim that the soul is in the
# embryo is formalised.
atom	from_mother	the vital functions observed in the embryo are from the soul of the mother
atom	from_semen	the vital functions observed in the embryo are from the formative power of the semen
atom	from_own_soul	the vital functions observed in the embryo are from its soul
atom	from_extrinsic	the vital functions such as feeling, nourishment, and growth are from an extrinsic principle
atom	soul_in_embryo	the soul is in the embryo
O1	S2	¬from_own_soul ∧ (from_mother ∨ from_semen)	against C
P1	S3	¬from_extrinsic	kind conceptual
# The text relies on the mother's soul and the semen's power counting as extrinsic principles.
A1	-	from_mother → from_extrinsic
A2	-	from_semen → from_extrinsic
C1	S3	¬from_mother ∧ ¬from_semen	from P1 A1 A2
R1	S3	¬from_mother ∧ ¬from_semen	against O1
# The text relies on this: if the vital functions are not from an extrinsic
# principle, they are from the embryo's own soul, and then the soul is in it.
A3	-	¬from_extrinsic → from_own_soul
A4	-	from_own_soul → soul_in_embryo
C	S4	soul_in_embryo	from P1 A3 A4
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

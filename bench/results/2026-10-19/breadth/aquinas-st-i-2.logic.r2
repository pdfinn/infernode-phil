# the argument of aquinas-st-i-2.md as claude-opus-5-5 read it: check that it says what the text says
atom	common_form	the Father and the Son have a common form: the same nature is in both
atom	excess	one participates in the form more perfectly than the other
atom	alike	the Son may be said to be like the Father
atom	equal	the Son may be said to be equal to the Father
P1	S2	equal → alike ∧ ¬excess	kind conceptual
P2	S3	common_form → alike	kind conceptual
P3	S3	excess → ¬equal	kind conceptual
P4	S4	common_form
P5	S4	¬excess
# The text never says outright that a common form shared in perfect equality makes things equal; S4 relies on it.
A1	-	common_form ∧ ¬excess → equal	kind conceptual
C1	S4	alike	from P2 P4
C2	S4	equal	from A1 P4 P5
# "we say ... like, to exclude Eunomius ... equal, to exclude Arius": read as the claim that the Son is both like and equal to the Father.
C	S4	alike ∧ equal	from C1 C2
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

# the argument of aquinas-st-i-3.md as claude-opus-5-5 read it: check that it says what the text says
logic	s5
# Aquinas: coercion is repugnant to the will. S1 states the thesis; S5 draws it as the conclusion, so S1 is not given a separate line.
atom	violent	the thing is coerced or violent
atom	against_incl	the thing is against the inclination of the thing
atom	will_inclination	the very movement of the will is an inclination to something
atom	according_will	the thing is according to the inclination of the will
atom	voluntary	the thing is voluntary
atom	natural	the thing is natural
atom	according_nature	the thing is according to the inclination of nature
P1	S2	□(violent ↔ against_incl)	kind conceptual
P2	S3	will_inclination
# S4 is introduced with "therefore", but nothing stated before it yields it, so it is given as a definitional premise.
P3	S4	□(natural ↔ according_nature)	kind conceptual
P4	S4	□(voluntary ↔ according_will)	kind conceptual
P5	S5	¬◇(violent ∧ natural)
# Unstated link: because the will is an inclination, what accords with it cannot also be against the thing's inclination.
A1	-	will_inclination → □(according_will → ¬against_incl)
C	S5	¬◇(violent ∧ voluntary)	from P1 P2 P4 A1
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

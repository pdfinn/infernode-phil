# the argument of hume-motivation.md as claude-opus-5-5 read it: check that it says what the text says
atom	morals_influence	morals have an influence on the actions and affections: they excite passions, and produce or prevent actions
atom	reason_influence	reason alone has an influence on actions and affections
atom	morals_from_reason	morals are derived from reason, i.e. the rules of morality are conclusions of our reason
P1	S2	morals_influence	kind empirical
P2	S3	¬reason_influence
# S1 also asserts, citing an earlier proof, that reason alone can never have such influence
A1	-	morals_from_reason ∧ ¬reason_influence → ¬morals_influence
# S1 draws the same conclusion that S4 states; it is recorded once, at S4
C	S4	¬morals_from_reason	from P1 P2 A1
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

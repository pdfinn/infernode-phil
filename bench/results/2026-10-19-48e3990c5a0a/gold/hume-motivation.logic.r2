# reading 2 of hume-motivation.md by claude-opus-5-5
atom	morals_influence	morals have an influence on the actions and affections (excite passions, produce or prevent actions)
atom	reason_influence	reason alone has an influence on the actions and affections
atom	morals_from_reason	morals (the rules of morality) are derived from reason, i.e. are conclusions of our reason
P1	S1	morals_influence
P2	S1	¬reason_influence
# S1 rests on an unstated link: what is derived from reason alone could have no influence that reason alone lacks.
A1	-	morals_from_reason ∧ morals_influence → reason_influence
C1	S1	¬morals_from_reason	from P1 P2 A1
P3	S2	morals_influence	kind empirical
P4	S3	¬reason_influence
C	S4	¬morals_from_reason	from P3 P4 A1
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

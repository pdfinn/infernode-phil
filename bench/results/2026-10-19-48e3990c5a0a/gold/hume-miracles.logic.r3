# reading 2 of hume-miracles.md by claude-opus-5-5
# S4 and S5 only illustrate the criterion in S3, so they are left out.
# S2 is a rhetorical question restating S1 (events agreeing with the laws need a miracle to prevent them); it is read as support for P2, not as a separate premise.
atom	miracle(x)	x is a miracle
atom	violation(x)	x is a violation of the laws of nature
atom	in_common_course(x)	x ever happens in the common course of nature (has been observed in some age or country)
atom	uniform_against(x)	there is a uniform experience against x
atom	proof_against(x)	there is a direct and full proof against the existence of x
atom	superior_opposite(x)	there is an opposite proof, superior to the proof against x
atom	credible(x)	x is rendered credible
P1	S1	∀x (miracle(x) → violation(x))	kind conceptual
# P2 reads "a firm and unalterable experience has established these laws" as: whatever violates them has uniform experience against it.
P2	S1	∀x (violation(x) → uniform_against(x))
P3	S3	∀x (in_common_course(x) → ¬miracle(x))	kind conceptual
# A1: what never happens in the common course of nature has uniform experience against it. S5's "never been observed in any age or country" relies on this without stating it.
A1	-	∀x (¬in_common_course(x) → uniform_against(x))
C1	S6	∀x (miracle(x) → uniform_against(x))	from P3 A1
P4	S7	∀x (uniform_against(x) → proof_against(x))
P5	S7	∀x (miracle(x) ∧ credible(x) → superior_opposite(x))
C	S7	∀x (miracle(x) → proof_against(x))	from C1 P4
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

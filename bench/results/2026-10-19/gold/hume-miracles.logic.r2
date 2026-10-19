# reading 2 of hume-miracles.md by claude-opus-5-5
atom	miracle(x)	x is a miracle
atom	violates_laws(x)	x is a violation of the laws of nature
atom	common_course(x)	x ever happens in the common course of nature (has been observed in some age or country)
atom	uniform_against(x)	there is a firm, uniform experience against x
atom	proof_against(x)	there is a direct and full proof, from the nature of the fact, against x
atom	credible(x)	x is rendered credible
atom	superior_opposite_proof(x)	there is an opposite proof, superior to the proof against x
# S1 states the definition and that firm experience established the laws; it anticipates the conclusion reached formally at S6-S7.
P1	S1	∀x (miracle(x) ↔ violates_laws(x))	kind conceptual
P2	S1	∀x (violates_laws(x) → uniform_against(x))	kind empirical
# S2 is a rhetorical restatement; S4 and S5 are illustrations and are left out.
P3	S3	∀x (common_course(x) → ¬miracle(x))	kind conceptual
# The S6 step ("otherwise the event would not merit that appellation") relies on: whatever lacks uniform experience against it has happened in the common course of nature.
A1	-	∀x (¬uniform_against(x) → common_course(x))
C1	S6	∀x (miracle(x) → uniform_against(x))	from P3 A1
P4	S7	∀x (uniform_against(x) → proof_against(x))	kind conceptual
C2	S7	∀x (miracle(x) → proof_against(x))	from C1 P4
P5	S7	∀x (proof_against(x) ∧ credible(x) → superior_opposite_proof(x))
C	S7	∀x (miracle(x) → proof_against(x) ∧ (credible(x) → superior_opposite_proof(x)))	from C2 P5
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

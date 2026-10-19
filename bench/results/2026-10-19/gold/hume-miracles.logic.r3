# reading 2 of hume-miracles.md by claude-opus-5-5
atom	miracle(x)	x is a miracle
atom	violates(x)	x is a violation of the laws of nature
atom	observed(x)	x ever happens in the common course of nature (has been observed to happen)
atom	uniformagainst(x)	there is a uniform (firm and unalterable) experience against x
atom	proofagainst(x)	there is a direct and full proof against x
atom	superiorproof(x)	there is an opposite proof, superior, in favour of x
atom	credible(x)	x is rendered credible
P1	S1	∀x (miracle(x) → violates(x))	kind conceptual
P2	S1	∀x (violates(x) → uniformagainst(x))	kind empirical
P3	S3	∀x (observed(x) → ¬miracle(x))	kind conceptual
# S4 and S5 illustrate S3 and are left out; S2 is a rhetorical question and is left out.
# A1: the text takes "never observed" to mean that experience is uniformly against the event.
A1	-	∀x (¬observed(x) → uniformagainst(x))
C1	S6	∀x (miracle(x) → uniformagainst(x))	from P3 A1
P4	S7	∀x (uniformagainst(x) → proofagainst(x))	kind conceptual
P5	S7	∀x (proofagainst(x) ∧ credible(x) → superiorproof(x))
C	S7	∀x (miracle(x) → proofagainst(x) ∧ (credible(x) → superiorproof(x)))	from C1 P4 P5
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

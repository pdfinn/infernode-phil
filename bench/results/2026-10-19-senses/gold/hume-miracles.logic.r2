# reading 2 of hume-miracles.md by claude-opus-5-5
atom	miracle(x)	x is a miracle
atom	violates(x)	x is a violation of the laws of nature
atom	observed(x)	x has ever happened in the common course of nature (been observed in some age or country)
atom	uniform(x)	there is a uniform (firm and unalterable) experience against x
atom	proof(x)	there is a direct and full proof against the existence of x
atom	credible(x)	x is rendered credible
atom	superior(x)	there is an opposite proof for x which is superior
# S1 definition: a miracle is a violation of the laws of nature
P1	S1	∀x (miracle(x) ↔ violates(x))	kind conceptual
# S1: the laws are established by firm and unalterable experience, so a violation has such experience against it
P2	S1	∀x (violates(x) → uniform(x))
# S3: nothing that ever happens in the common course of nature is esteemed a miracle
P3	S3	∀x (observed(x) → ¬miracle(x))	kind conceptual
# S6 draws "uniform experience against every miracle" from S3 (S4-S5 only illustrate); this step needs that an event never observed has uniform experience against it, which the text plainly relies on
A1	-	∀x (¬observed(x) → uniform(x))
C1	S6	∀x (miracle(x) → uniform(x))	from P3 A1
# S7: uniform experience amounts to a proof
P4	S7	∀x (uniform(x) → proof(x))	kind conceptual
# S7: such a proof is not destroyed, nor the miracle made credible, except by a superior opposite proof
P5	S7	∀x (proof(x) ∧ ¬superior(x) → ¬credible(x))
C	S7	∀x (miracle(x) → proof(x))	from C1 P4
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

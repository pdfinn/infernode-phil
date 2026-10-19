# reading 2 of gorgias-polus.md by claude-opus-5-5
atom	more_disgraceful	doing wrong is more disgraceful than suffering wrong
atom	exceeds_pain	doing wrong exceeds suffering wrong in pain
atom	exceeds_evil	doing wrong exceeds suffering wrong in evil
atom	more_evil	doing wrong is a greater evil than suffering wrong
# S18: Polus's earlier claim that doing wrong is more disgraceful but suffering wrong is more evil.
P1	S18	more_disgraceful ∧ ¬more_evil	says polus
# S15/S20: the more disgraceful exceeds in pain or in evil or both.
P2	S20	more_disgraceful → exceeds_pain ∨ exceeds_evil	kind conceptual
# S22-S25: the injurers do not suffer more than the injured.
P3	S24	¬exceeds_pain	kind empirical
# S34: it is agreed that doing injustice is more disgraceful.
P4	S34	more_disgraceful
C1	S30	exceeds_evil	from P2 P3 P4
# S32: an excess of evil makes doing injustice the greater evil.
P5	S32	exceeds_evil → more_evil	kind conceptual
C	S36	more_evil	from C1 P5
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

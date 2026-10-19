# reading 3 of kant-practical-2.md by claude-opus-5-5
atom	maxims	the principle of happiness may furnish maxims
atom	laws	the principle of happiness can furnish laws of the will (practical laws can be founded on it)
atom	empirical	the knowledge of happiness rests on mere empirical data
atom	variable	every man's judgement on happiness depends on his particular, very variable point of view
atom	general_only	the principle of happiness can supply only general rules, not universal ones
atom	necessary_rules	the principle of happiness can give rules which must hold good always and necessarily
atom	object_first	an object of choice is the foundation of the rule and must precede it
atom	refers_felt	the rule refers to nothing but what is felt, to experience, and is founded on it
atom	endless_variety	the variety of judgement must be endless
atom	same_all	the principle of happiness prescribes the same practical rules to all rational beings
P1	S2	empirical ∧ variable	kind empirical
P2	S2	empirical ∧ variable → general_only
P3	S2	general_only → ¬necessary_rules	kind conceptual
P4	S2	¬necessary_rules → ¬laws
C1	S2	¬laws	from P1 P2 P3 P4
P5	S3	object_first
P6	S3	object_first → refers_felt
P7	S3	refers_felt → endless_variety
P8	S4	endless_variety → ¬same_all
C2	S4	¬same_all	from P5 P6 P7 P8
# S5: a law is objectively necessary only because it holds for everyone with reason and will; read as laws -> same_all
P9	S5	laws → same_all	kind conceptual
P10	S1	maxims
C	S1	maxims ∧ ¬laws	from P10 C1 C2 P9
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

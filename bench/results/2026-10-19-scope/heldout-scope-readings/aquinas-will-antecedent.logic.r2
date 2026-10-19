# reading 2 of aquinas-will-antecedent.md by claude-opus-5-5
# Objection 3 argues in two routes: through the antecedent cause (S2-S3) and through the necessity of the conditional (S4).
# "necessary absolutely" is read as []comes: the thing's coming to pass is necessary.
logic	s5
atom	wills	God wills the thing
atom	comes	the thing comes to pass
atom	will_cause	the thing is related to the divine will as to an antecedent cause
atom	nec_by_cause	the thing is necessary by its antecedent cause
P1	S2	nec_by_cause → □comes	kind conceptual
P2	S3	wills → will_cause
P3	S3	will_cause → nec_by_cause
P4	S4	wills → comes
# "every true conditional statement is necessary", applied to this conditional
P5	S4	(wills → comes) → □(wills → comes)	kind conceptual
C1	S4	□(wills → comes)	from P4 P5
C	S5	wills → □comes	from P1 P2 P3 C1
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

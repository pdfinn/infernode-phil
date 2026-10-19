# the argument of aquinas-will-antecedent.md as claude-opus-5-5 read it: check that it says what the text says
logic	s5
# Necessity is read throughout as alethic (what must be), so [] is used.
atom	wills	God wills a thing
atom	comes	the thing God wills comes to pass
atom	nec_by_cause	the thing is necessary by its antecedent cause, the divine will
# S2's example of animals dying is an illustration and is left out.
P1	S2	nec_by_cause → □comes	kind conceptual
P2	S3	wills → nec_by_cause
P3	S4	wills → comes
# "every true conditional statement is necessary", applied to this conditional.
P4	S4	(wills → comes) → □(wills → comes)
# S5 could mean that the willed thing is necessary once willed, wills -> []comes, or that the whole is necessary, [](wills -> comes). It is taken as the former, since "necessary absolutely" is said of what God wills.
C	S5	wills → □comes	from P1 P2 P3 P4
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

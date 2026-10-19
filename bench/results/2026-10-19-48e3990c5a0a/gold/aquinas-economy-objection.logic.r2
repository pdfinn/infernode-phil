# the argument of aquinas-economy-objection.md as claude-opus-5-5 read it: check that it says what the text says
# Objection 2 from Aquinas (ST I q.2 a.3); the objector's argument is written as it is put.
# S2 states a general principle of parsimony; here it is applied to the case of God.
atom	natural_reduced	all natural things can be reduced to one principle which is nature
atom	voluntary_reduced	all voluntary things can be reduced to one principle which is human reason, or will
atom	accounted_other	everything we see in the world can be accounted for by other principles, supposing God did not exist
atom	no_need_god	it is superfluous / there is no need to suppose God's existence
P1	S2	accounted_other → no_need_god	kind conceptual
P2	S4	natural_reduced
P3	S4	voluntary_reduced
# The step from S4 to S3 plainly relies on everything in the world being either natural or voluntary.
A1	-	natural_reduced ∧ voluntary_reduced → accounted_other
C1	S3	accounted_other	from P2 P3 A1
C	S5	no_need_god	from C1 P1
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

# the argument of aquinas-economy-objection.md as claude-opus-5-5 read it: check that it says what the text says
atom	superfluous_many	it is superfluous to suppose that what can be accounted for by a few principles has been produced by many
atom	accounted_other	everything we see in the world can be accounted for by other principles, supposing God did not exist
atom	natural_reduced	all natural things can be reduced to one principle which is nature
atom	voluntary_reduced	all voluntary things can be reduced to one principle which is human reason, or will
atom	need_god	there is need to suppose God's existence
P1	S2	superfluous_many	kind conceptual
P2	S4	natural_reduced
P3	S4	voluntary_reduced
A1	-	natural_reduced ∧ voluntary_reduced → accounted_other
C1	S3	accounted_other	from P2 P3 A1
A2	-	superfluous_many ∧ accounted_other → ¬need_god
C	S5	¬need_god	from P1 C1 A2
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

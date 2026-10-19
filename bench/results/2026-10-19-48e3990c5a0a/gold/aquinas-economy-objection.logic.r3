# the argument of aquinas-economy-objection.md as claude-opus-5-5 read it: check that it says what the text says
# The whole passage is the second objection (Obj. 2); its argument is written as given.
atom	few_suffice	everything we see in the world can be accounted for by other principles (fewer than many), supposing God did not exist
atom	no_need_god	it is superfluous / there is no need to suppose God's existence
atom	natural_reduce	all natural things can be reduced to one principle, which is nature
atom	voluntary_reduce	all voluntary things can be reduced to one principle, which is human reason or will
# S2 states the general parsimony principle; applied here to God as a superfluous extra principle.
P1	S2	few_suffice → no_need_god
P2	S4	natural_reduce
P3	S4	voluntary_reduce
# Unstated: everything we see in the world is either natural or voluntary, so these two reductions cover it all.
A1	-	natural_reduce ∧ voluntary_reduce → few_suffice
C1	S3	few_suffice	from P2 P3 A1
C	S5	no_need_god	from P1 C1
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

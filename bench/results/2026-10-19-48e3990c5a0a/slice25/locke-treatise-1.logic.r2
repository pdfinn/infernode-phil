# the argument of locke-treatise-1.md as claude-opus-5-5 read it: check that it says what the text says
logic	kd
atom	end_continuation	the end of conjunction between male and female is not barely procreation but the continuation of the species
atom	young_need_parents	the young are to be sustained by those that got them till they are able to shift and provide for themselves
atom	last_while_needed	the conjunction between male and female lasts, even after procreation, so long as is necessary to the nourishment and support of the young
atom	god_set_rule	this rule is one the infinite wise maker hath set to the works of his hands
atom	creatures_obey	the inferior creatures steadily obey this rule
# S3 carries the argument: the end of conjunction is the continuation of the species, so conjunction ought to last as long as the young need support.
# The link from those grounds to the "ought" is left implicit in the text, so it is supplied as A1.
P1	S3	end_continuation	kind conceptual
P2	S3	young_need_parents
A1	-	end_continuation ∧ young_need_parents → O last_while_needed
C	S3	O last_while_needed	from P1 P2 A1
# S4 says the rule is God's and that the inferior creatures obey it. Nothing in the argument for C is drawn from it.
P3	S4	god_set_rule ∧ creatures_obey
# S5-S7 (grass-eaters, beasts of prey, birds) illustrate S4 and are left out.
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

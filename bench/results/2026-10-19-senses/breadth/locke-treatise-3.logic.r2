# the argument of locke-treatise-3.md as claude-opus-5-5 read it: check that it says what the text says
atom	natural_power	there is another power in every commonwealth which one may call natural
atom	answers_natural	that power answers to the power every man naturally had before he entered into society
atom	distinct_governed	in a commonwealth the members are distinct persons in reference to one another and are governed by the laws of the society
atom	one_body	in reference to the rest of mankind, the members of a commonwealth make one body
atom	in_nature	that body is still in the state of nature with the rest of mankind, as every member of it before was
atom	public_manages	controversies between any man of the society and those out of it are managed by the public
atom	whole_repairs	an injury done to a member of the body engages the whole in the reparation of it
P1	S3	distinct_governed
P2	S3	one_body ∧ in_nature
P3	S3	one_body ∧ in_nature → answers_natural
P4	S3	answers_natural → natural_power	kind conceptual
C1	S3	natural_power	from P2 P3 P4
# S4's "Hence" draws the public management of outside controversies from the community being one body in the state of nature; the link is not stated.
A1	-	one_body ∧ in_nature → public_manages ∧ whole_repairs
C2	S4	public_manages ∧ whole_repairs	from P2 A1
C	S5	one_body ∧ in_nature	from P2
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

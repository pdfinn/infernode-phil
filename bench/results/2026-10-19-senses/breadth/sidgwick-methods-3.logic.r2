# the argument of sidgwick-methods-3.md as claude-opus-5-5 read it: check that it says what the text says
atom	easy	it is easy to state clear principles for determining the gravity of crimes, taking the intention only into account
atom	intends_right	sometimes, as with the patriotic rebel, the intention of the criminal is to do what is right and good
atom	no_harm_intended	in many cases the criminal, though knowing he does wrong, does not intend to cause any actual harm to any sentient being
atom	secrecy_not_less_grave	we do not commonly think that a crime is rendered less grave by being kept perfectly secret
atom	secondary_part	a great part of the harm done by a crime is the secondary evil of the alarm and insecurity it causes
atom	secrecy_cuts	this part of the harm is cut off by complete secrecy
atom	secrecy_difficulty	secrecy presents a difficulty for grading crimes by intention
atom	not_practical	the secrecy difficulty is not a practical one
atom	punish_after_discovery	we are not called upon to punish a crime until it has been discovered
atom	secondary_caused	once a crime is discovered the secondary evil has been caused, and is all the greater because of the previous secrecy
atom	not_designed	the secret crime was not designed for discovery
atom	secondary_not_intended	the secondary evil caused by the crime was not intended by the criminal
atom	legal_fiction	grading heinousness by the loss of happiness such acts would generally cause if unpunished, supposing the criminal aware of this, forces a utilitarian theory into an intuitional form by a legal fiction
P1	S2	intends_right	kind empirical
P2	S2	no_harm_intended	kind empirical
A1	-	intends_right ∨ no_harm_intended → ¬easy
P3	S3	secrecy_not_less_grave	kind empirical
P4	S3	secondary_part	says bentham
P5	S3	secondary_part
P6	S3	secrecy_cuts
A2	-	secrecy_not_less_grave ∧ secondary_part ∧ secrecy_cuts → secrecy_difficulty
C1	S3	secrecy_difficulty	from P3 P5 P6 A2
O1	S4	punish_after_discovery ∧ secondary_caused ∧ not_practical	against C1
P7	S5	not_designed
P8	S5	not_designed → secondary_not_intended
R1	S5	secondary_not_intended	against O1
P9	S6	legal_fiction
A3	-	secrecy_difficulty → ¬easy
C	S1	¬easy	from P1 P2 A1 C1 A3
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

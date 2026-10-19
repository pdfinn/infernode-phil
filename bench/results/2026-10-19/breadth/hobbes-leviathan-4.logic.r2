# reading 2 of hobbes-leviathan-4.md by claude-opus-5-5
logic	s5
atom	learned_from_aristotle	from Aristotle's Civill Philosophy they have learned to call all manner of Common-wealths but the Popular, Tyranny
atom	tyrant_meant_monarch	a Tyrant originally signified no more simply but a Monarch
atom	monarchy_abolished	afterwards in most parts of Greece that kind of government (monarchy) was abolished
atom	tyrant_signifies_hatred	the name Tyrant began to signifie, with the thing it did before, the hatred which the Popular States bare towards it
atom	fault_in_despite	it is naturall to all men to conceive some great Fault to be signified in any Attribute that is given in despight, and to a great Enemy
atom	displeased_with_administrators	the same men are displeased with those that have the administration of the Democracy or Aristocracy
atom	call_anarchy_oligarchy	they call readily the one Anarchy, and the other Oligarchy, or the Tyranny of a Few
atom	offended_by_arbitrary	that which offendeth the People is no other thing but that they are governed as the Publique Representant thinks fit, that is, by an Arbitrary government
atom	evil_names_to_superiors	they give evill names to their Superiors
atom	arbitrary_government	there is such Arbitrary government
atom	war_perpetual	Warre must be perpetuall
atom	force_from_arms	it is Men and Arms, not Words and Promises, that make the Force and Power of the Laws
P1	S1	learned_from_aristotle	kind empirical
P2	S3	tyrant_meant_monarch	kind conceptual
P3	S3	monarchy_abolished	kind empirical
P4	S3	monarchy_abolished ∧ fault_in_despite → tyrant_signifies_hatred
P5	S3	fault_in_despite	kind empirical
C1	S3	tyrant_signifies_hatred	from P3 P4 P5
P6	S4	displeased_with_administrators → call_anarchy_oligarchy	kind empirical
P7	S5	offended_by_arbitrary	kind empirical
P8	S5	offended_by_arbitrary → evil_names_to_superiors
# "such Warre must be perpetuall": read as necessity of the conditional (the war follows of necessity)
P9	S5	□(¬arbitrary_government → war_perpetual)
P10	S5	force_from_arms
C	S5	evil_names_to_superiors	from P7 P8
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

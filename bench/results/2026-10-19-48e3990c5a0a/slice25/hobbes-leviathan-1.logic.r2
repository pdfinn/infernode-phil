# the argument of hobbes-leviathan-1.md as claude-opus-5-5 read it: check that it says what the text says
logic	kd
atom	laws_to_addressees	laws are laws to every one to whom the command is directed, and to none else
atom	unjust_contrary_law	nothing is reputed unjust that is not contrary to some law
atom	laws_rules_just	laws are the rules of just and unjust
atom	subjection_cw_only	our subjection is to the common-wealth only
atom	only_cw_makes_laws	none can make laws but the common-wealth
atom	obey_needs_signs	a man knows not otherwise (than by sufficient signs) how to obey commands
atom	commands_signified	commands are to be signified by sufficient signs
atom	definition_evident	in the definition there is nothing that is not at first sight evident
atom	acknowledge_deductions	whatsoever can from this definition by necessary consequence be deduced is acknowledged for truth
P1	S2	laws_to_addressees	kind conceptual
P2	S3	unjust_contrary_law
P3	S3	unjust_contrary_law → laws_rules_just
C1	S3	laws_rules_just	from P2 P3
P4	S4	subjection_cw_only
P5	S4	subjection_cw_only → only_cw_makes_laws
C2	S4	only_cw_makes_laws	from P4 P5
P6	S4	obey_needs_signs	kind empirical
P7	S4	obey_needs_signs → commands_signified
C3	S4	commands_signified	from P6 P7
# S1 is supported by S2-S4 ("For every man seeth"); the link from the listed points to the evidence of the whole definition is unstated
A1	-	laws_to_addressees ∧ laws_rules_just ∧ only_cw_makes_laws ∧ commands_signified → definition_evident
C4	S1	definition_evident	from P1 C1 C2 C3 A1
# "And therefore" in S5 relies on: if the definition is evident, its necessary consequences ought to be acknowledged true
A2	-	definition_evident → O acknowledge_deductions
C	S5	O acknowledge_deductions	from C4 A2
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

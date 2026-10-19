# the argument of hobbes-leviathan-1.md as claude-opus-5-5 read it: check that it says what the text says
logic	kd
atom	addressed_variously	some Lawes are addressed to all the Subjects in generall, some to particular Provinces, some to particular Vocations, and some to particular Men
atom	laws_to_addressees	Lawes are Lawes to every of those to whom the Command is directed, and to none else
atom	nothing_unjust_unless_contrary	nothing is reputed Unjust that is not contrary to some Law
atom	laws_rules_just	Lawes are the Rules of Just and Unjust
atom	subjection_cw_only	our Subjection is to the Common-wealth only
atom	only_cw_makes_laws	none can make Lawes but the Common-wealth
atom	know_obey_only_by_signs	a man knows not otherwise how to obey Commands than by sufficient Signs
atom	commands_signified	Commands are to be signified by sufficient Signs
atom	def_evident	in the definition of Law there is nothing that is not at first sight evident
atom	acknowledge_deductions	whatsoever can from this definition by necessary consequence be deduced is acknowledged for truth
P1	S2	addressed_variously	kind empirical
P2	S2	addressed_variously → laws_to_addressees
C1	S2	laws_to_addressees	from P1 P2
P3	S3	nothing_unjust_unless_contrary
P4	S3	nothing_unjust_unless_contrary → laws_rules_just
C2	S3	laws_rules_just	from P3 P4
P5	S4	subjection_cw_only
P6	S4	subjection_cw_only → only_cw_makes_laws
C3	S4	only_cw_makes_laws	from P5 P6
P7	S4	know_obey_only_by_signs
P8	S4	know_obey_only_by_signs → commands_signified
C4	S4	commands_signified	from P7 P8
# The text says S2-S4 show the definition is evident ("For every man seeth"); the link from these parts to the whole definition is unstated.
A1	-	laws_to_addressees ∧ laws_rules_just ∧ only_cw_makes_laws ∧ commands_signified → def_evident
C5	S1	def_evident	from C1 C2 C3 C4 A1
# S5 "And therefore" draws the conclusion from the definition's evidence; the conditional is unstated.
A2	-	def_evident → O acknowledge_deductions
C	S5	O acknowledge_deductions	from C5 A2
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

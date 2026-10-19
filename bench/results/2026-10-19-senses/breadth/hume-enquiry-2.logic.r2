# the argument of hume-enquiry-2.md as claude-opus-5-5 read it: check that it says what the text says
# S2 states a plan, but it is drawn ("therefore") from S1, so it is kept as the conclusion.
# "it is every moment necessary for us to treat" is read as a plain claim, not modal.
atom	obscure	the ideas of power, force, energy or necessary connexion are more obscure and uncertain than any other ideas occurring in metaphysics
atom	constantly_treated	it is every moment necessary for us to treat of these ideas in all our disquisitions
atom	fix_meaning	we shall endeavour in this section to fix, if possible, the precise meaning of these terms and thereby remove some part of the obscurity of this species of philosophy
P1	S1	obscure	kind conceptual
P2	S1	constantly_treated
A1	-	obscure ∧ constantly_treated → fix_meaning
C	S2	fix_meaning	from P1 P2 A1
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

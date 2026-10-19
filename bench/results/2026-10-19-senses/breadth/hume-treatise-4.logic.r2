# the argument of hume-treatise-4.md as claude-opus-5-5 read it: check that it says what the text says
# Hume's elimination: the act of mind in a promise is not resolving, desiring or willing the performance, so it is willing the obligation.
# S4's "must necessarily" is read as the force of the inference, not as a modal claim.
atom	resolution	the act of the mind exprest by a promise is a resolution to perform any thing
atom	resolution_obliges	a resolution to perform alone imposes an obligation
atom	produces_obligation	the act of the mind which enters into a promise produces its obligation
atom	desire	the act of the mind exprest by a promise is a desire of such a performance
atom	bind_without_desire	we may bind ourselves without such a desire, or even with an aversion, declared and avowed
atom	willing_action	the act of the mind exprest by a promise is the willing of that action which we promise to perform
atom	future	a promise always regards some future time
atom	will_present_only	the will has an influence only on present actions
atom	willing_obligation	the act of the mind exprest by a promise is the willing of that obligation which arises from the promise
atom	common_speech	it is conformable to our common ways of thinking and expressing ourselves that we are bound by our own consent and the obligation arises from our mere will
P1	S1	¬resolution_obliges	kind conceptual
P2	S4	produces_obligation
A1	-	resolution ∧ produces_obligation → resolution_obliges
C1	S1	¬resolution	from P1 P2 A1
P3	S2	bind_without_desire
A2	-	desire → ¬bind_without_desire
C2	S2	¬desire	from P3 A2
P4	S3	future	kind conceptual
P5	S3	will_present_only
A3	-	willing_action → ¬(future ∧ will_present_only)
C3	S3	¬willing_action	from P4 P5 A3
A4	-	resolution ∨ desire ∨ willing_action ∨ willing_obligation
C	S4	willing_obligation	from C1 C2 C3 A4
# S5 supports the conclusion from ordinary usage, but the conclusion is not drawn from it.
P6	S5	common_speech	kind empirical
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

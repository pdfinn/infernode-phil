# reading 3 of hume-treatise-2.md by claude-opus-5-5
atom	convincing_causal	the two principles have been found sufficiently convincing with regard to our most certain reasonings from causation
atom	evidence_probable	with regard to conjectural or probable reasonings the two principles acquire a new degree of evidence
atom	convinced	men are once fully persuaded of the two principles: that nothing in any object, considered in itself, affords a reason for drawing a conclusion beyond it, and that even after observing frequent or constant conjunction we have no reason to infer beyond what we have experienced
atom	loose	men are thrown loose from all common systems
atom	receive_extraordinary	men will make no difficulty of receiving any system, however extraordinary it may appear
atom	vulgar_imperfect	every vulgar hypothesis on this subject is imperfect
atom	readers_reject	the generality of readers will be apt to reject this reasoning as chimerical
# S1 is a prediction about readers, given as background, not used in the argument.
P1	S1	readers_reject	kind empirical
P2	S2	vulgar_imperfect
# S3 is read as a two-step chain: full conviction throws men loose from common systems, and being thrown loose leaves them open to receiving any system.
P3	S3	convinced → loose
P4	S3	loose → receive_extraordinary
P5	S4	convincing_causal
P6	S4	evidence_probable
# The main conclusion is taken to be the overall conditional in S3; it is not clearly marked as drawn, so this choice is uncertain.
C	S3	convinced → receive_extraordinary	from P3 P4
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

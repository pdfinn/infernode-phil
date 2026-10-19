# the argument of berkeley-heat-pain.md as claude-opus-5-5 read it: check that it says what the text says
atom	heat_pain	the most vehement and intense degree of heat is a very great pain
atom	matter_senseless	material substance is a senseless, unperceiving being
atom	matter_pain	material substance is capable of being the subject of pain
atom	matter_heat	material substance is the subject of the greatest heat perceived by sense
P1	S3	heat_pain	kind conceptual
P2	S7	matter_senseless → ¬matter_pain	kind conceptual
P3	S11	matter_senseless
C1	S15	¬matter_pain	from P2 P3
# The text relies on this: since intense heat is a pain, whatever is the subject of that heat is the subject of pain.
A1	-	heat_pain → (matter_heat → matter_pain)
C	S17	¬matter_heat	from C1 P1 A1
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

# the argument of aristotle-ethics-1.md as claude-opus-5-5 read it: check that it says what the text says
atom	shame_virtue	Shame is a Virtue
atom	shame_feeling	Shame is much more like a feeling than a moral state
atom	shame_fear_disgrace	Shame is defined to be a kind of fear of disgrace
atom	shame_blush	they who feel Shame grow red
atom	fear_pale	they who fear death turn pale
atom	shame_physical	Shame is in a way physical
atom	fear_physical	fear of danger is in a way physical
P1	S2	shame_fear_disgrace	kind conceptual
P2	S2	shame_blush	kind empirical
P3	S2	fear_pale	kind empirical
A1	-	shame_blush → shame_physical
A2	-	fear_pale → fear_physical
C1	S3	shame_physical ∧ fear_physical	from P2 P3 A1 A2
P4	S3	shame_physical → shame_feeling
C2	S3	shame_feeling	from C1 P4
P5	S1	shame_feeling → ¬shame_virtue
C	S1	¬shame_virtue	from C2 P5
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

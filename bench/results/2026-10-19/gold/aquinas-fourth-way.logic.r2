# the argument of aquinas-fourth-way.md as claude-opus-5-5 read it: check that it says what the text says
atom	gradation	among beings there are some more and some less good, true, noble and the like
atom	maximum	there is something which is truest, something best, something noblest
atom	uttermost_being	there is something which is uttermost being
atom	max_is_cause	the maximum in any genus is the cause of all in that genus
atom	cause_all	there is something which is to all beings the cause of their being, goodness, and every other perfection
atom	god	there is God
P1	S2	gradation	kind empirical
# S3: more and less are predicated according as things resemble a maximum; read as: if there is gradation, there is a maximum
P2	S3	gradation → maximum
C1	S3	maximum	from P1 P2
# S3: those things that are greatest in truth are greatest in being, cited to Metaph. ii
P3	S3	maximum → uttermost_being	says aristotle
P4	S3	maximum → uttermost_being
C2	S3	uttermost_being	from C1 P4
P5	S4	max_is_cause
# applying the general principle to the genus of being
A1	-	max_is_cause ∧ uttermost_being → cause_all
C3	S5	cause_all	from C2 P5 A1
# "this we call God"
P6	S5	cause_all → god	kind conceptual
C	S5	god	from C3 P6
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

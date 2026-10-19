# the argument of aquinas-will-necessary.md as claude-opus-5-5 read it: check that it says what the text says
logic	s5
# The passage is only "Objection 1" (Aquinas): it argues from Augustine that God's will imposes necessity on what is willed.
# The "must" of "He must therefore be asked to will it" (S3) is a practical must about prayer. Nothing is drawn from it, so it is left out.
atom	god_wills	God wills that a person be saved
atom	saved	that person is saved
P1	S2	saved → god_wills	says augustine
# In S3 "if He wills it, it must necessarily be" could mean [](god_wills -> saved), the necessity of the whole conditional.
# It could also mean god_wills -> []saved, the necessity of the consequent. The objection needs the second reading, so that reading is written here.
P2	S3	god_wills → □saved	says augustine
P3	S3	god_wills → □saved
C	S1	god_wills → □saved	from P3
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

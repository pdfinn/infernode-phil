# reading 2 of aquinas-will-necessary.md by claude-opus-5-5
logic	s5
atom	god_wills	God wills the thing (in Augustine's case, that someone be saved)
atom	comes_to_be	the thing willed comes to be (in Augustine's case, the person is saved)
# S2-S3 quote Augustine; the objection then argues from them, so each is given once as his report and once as a plain premise.
P1	S2	comes_to_be → god_wills	says augustine
P2	S3	god_wills → □comes_to_be	says augustine
# S3 "if He wills it, it must necessarily be" is read as necessity of the consequent: god_wills -> []comes_to_be.
# It could instead be read as necessity of the whole, [](god_wills -> comes_to_be).
# The objection needs the first reading.
P3	S2	comes_to_be → god_wills
P4	S3	god_wills → □comes_to_be
# The whole passage is Objection 1. Its thesis (S1), that God's will imposes necessity on the things willed, is taken as the main conclusion.
C	S1	god_wills → □comes_to_be	from P4
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

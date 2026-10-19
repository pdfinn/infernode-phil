# the argument of aristotle-ethics-2.md as claude-opus-5-5 read it: check that it says what the text says
logic	kd
# S1 (etymology of "just" and "judge") is an aside and is left out.
atom	taken_added	from one of two equal magnitudes somewhat has been taken and added to the other
atom	exceeds_twice	the latter exceeds the former by twice that portion
atom	taken_only	the portion had been merely taken from the former and not added to the latter
atom	exceeds_once	the latter would have exceeded the former only by that one portion
atom	greater_over_mean_one	the greater exceeds the mean by one portion
atom	mean_over_less_one	the mean exceeds by one portion that magnitude from which the portion was taken
atom	rule	we obtain a rule to determine what one ought to take from him who has the greater, and what to add to him who has the less
atom	add_to_less	the excess of the mean over the less is added to the less
atom	take_from_greater	the excess of the greater over the mean is taken from the greater
P1	S2	taken_added → exceeds_twice	kind conceptual
P2	S2	taken_only → exceeds_once	kind conceptual
P3	S2	taken_added → greater_over_mean_one ∧ mean_over_less_one	kind conceptual
C1	S3	rule	from P1 P3
# The text states the rule in S4 as what the rule obtained in S3 prescribes; this link is unstated.
# "must" in S4 is read in the sense of what ought to be done, as S3 frames it ("what one ought to take").
A1	-	rule → O add_to_less ∧ O take_from_greater
C	S4	O add_to_less ∧ O take_from_greater	from C1 A1
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

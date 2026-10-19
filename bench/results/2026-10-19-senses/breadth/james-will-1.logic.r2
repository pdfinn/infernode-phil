# the argument of james-will-1.md as claude-opus-5-5 read it: check that it says what the text says
# Mill's argument (S1-S4) is reported as his, not as the author's own premise.
# S5-S7 are the author's reply to Mill: substance may be idle for the past, but that does not settle the future.
# S9's "therefore" rests on S8 together with an unstated link from the feeling of confidence to the liking (A1).
atom	undetectable	if the substratum were annihilated and the sensations continued in the same order, there would be no signs by which to discover that it had ceased to exist
atom	warranted_now	we are now warranted in believing that the substratum exists
atom	facts_bagged	we have already securely bagged our facts in a certain order
atom	past_dispensable	we can dispense with any further warrant (substance) for the order of the irrecoverably past
atom	future_dispensable	substance is an equally empty complication to our notions of the future
atom	future_different	with regard to the facts yet to come the case is far different
atom	confidence	the logical form of referring things to a substance remains accompanied by a feeling of rest and future confidence
atom	liking	men will always have a liking for any philosophy which explains things per substantiam
P1	S1	undetectable	says mill
P2	S4	undetectable → ¬warranted_now	says mill
P3	S5	facts_bagged → past_dispensable
P4	S6	future_different
# S7 denies only that the past case carries over to the future; it does not assert that substance is indispensable for the future.
P5	S7	future_different → ¬(past_dispensable → future_dispensable)
P6	S8	confidence
A1	-	confidence → liking
C	S9	liking	from P6 A1
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

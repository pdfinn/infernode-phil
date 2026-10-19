# reading 2 of james-will-1.md by claude-opus-5-5
logic	s5
atom	substratum_missed_if_annihilated	if the substratum were annihilated while the sensations continued in the same order, the substratum would be missed
atom	warranted_belief_substratum	we are warranted in believing that the substratum exists
atom	past_facts_bagged	we have already securely bagged our past facts in a certain order
atom	dispense_warrant_past	we can dispense with any further warrant for the order of the past facts
atom	substance_droppable_past	substance may be dropped from our conception of the irrecoverably past
atom	substance_empty_future	substance is an equally empty complication to our notions of the future
atom	substance_new_attributes	for aught we know, the substance might develop at any moment a wholly new set of attributes
atom	substance_form_gives_confidence	the mere logical form of referring things to a substance remains accompanied by a feeling of rest and future confidence
atom	men_like_substance_philosophy	men will always have a liking for any philosophy which explains things per substantiam
# Mill's argument, reported: the substratum would not be missed; if so, we are not warranted in believing it.
P1	S1	¬substratum_missed_if_annihilated	says mill
P2	S4	¬substratum_missed_if_annihilated → ¬warranted_belief_substratum	says mill
O1	S4	¬warranted_belief_substratum	against C
# The author concedes the point for the past.
P3	S5	past_facts_bagged → dispense_warrant_past
# S7: droppability for the past does not carry over to the future; written as a denial that the conditional is necessary.
R1	S7	¬□(substance_droppable_past → substance_empty_future)	against O1
# S8: even granting new attributes are possible, the form still gives confidence.
P4	S8	substance_new_attributes → substance_form_gives_confidence
P5	S8	substance_form_gives_confidence
A1	-	substance_form_gives_confidence → men_like_substance_philosophy
C	S9	men_like_substance_philosophy	from P5 A1
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

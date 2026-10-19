# the argument of spinoza-ethics-4.md as claude-opus-5-5 read it: check that it says what the text says
atom	nourishment_needs_aid	the strength of each individual would hardly suffice for providing these nourishments
atom	mutual_aid	men lend one another mutual aid
atom	money_token	money has furnished us with a token for everything
atom	multitude_engrossed	the mind of the multitude is chiefly engrossed with the notion of money
atom	pleasure_tied_to_money	the multitude can hardly conceive any kind of pleasure which is not accompanied with the idea of money as cause
P1	S2	¬mutual_aid → nourishment_needs_aid	kind empirical
P2	S3	money_token	kind empirical
# the "hence" in S3 relies on an unstated link from money being a token for everything to the multitude's absorption in it
A1	-	money_token → multitude_engrossed
P3	S3	pleasure_tied_to_money	kind empirical
C	S3	multitude_engrossed	from P2 A1
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

# the argument of plato-republic-1.md as claude-opus-5-5 read it: check that it says what the text says
# the argument of plato-republic-1.md as claude-opus-5-5 read it: check that it says what the text says
atom	unjust_appearance_fares_well	if we only unite the worst injustice with a deceitful regard to appearances, we shall fare to our mind both with gods and men, in life and after death
atom	principle_to_choose_justice	there is a principle on which we should choose justice rather than the worst injustice
atom	superior_honours_justice	a man who has any superiority of mind or person or rank or wealth is willing to honour justice
atom	men_not_just_willingly	men are not just of their own free will
atom	inspired	the divinity within him has inspired him with a hatred of injustice
atom	knows_truth	he has attained knowledge of the truth
atom	forgives_unjust	one who is satisfied that justice is best is not angry with the unjust but is very ready to forgive them
atom	blames_injustice	he blames injustice
atom	lacks_power	owing to cowardice or age or some weakness, he has not the power of being unjust
atom	unjust_when_power	when he obtains the power, he immediately becomes unjust as far as he can be
# S1 reports this as what "the most numerous and the highest authorities tell us"; the text gives them no single name, so it is written as a plain premise that the argument rests on.
P1	S1	unjust_appearance_fares_well	kind empirical
P2	S1	unjust_appearance_fares_well → ¬principle_to_choose_justice
C1	S1	¬principle_to_choose_justice	from P1 P2
# S2 draws its rhetorical question ("Knowing all this") from S1; the link is not stated.
A1	-	¬principle_to_choose_justice → ¬superior_honours_justice
C	S2	¬superior_honours_justice	from C1 A1
P3	S3	men_not_just_willingly	kind empirical
P4	S3	men_not_just_willingly ∧ ¬inspired ∧ ¬knows_truth → forgives_unjust
P5	S5	unjust_when_power	kind empirical
# S5 says S4 "is proved by" S5; the link from the evidence to S4 is left unstated in the text.
A2	-	unjust_when_power → (blames_injustice → lacks_power)
C2	S4	blames_injustice → lacks_power	from P5 A2
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

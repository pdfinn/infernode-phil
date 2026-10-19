# the argument of plato-republic-1.md as claude-opus-5-5 read it: check that it says what the text says
# Adeimantus' speech (Republic II): the main conclusion is S2, that a man of any superiority
# will not honour justice, drawn from S1.
# S3 and S4-S5 add further support but are not linked to C by any stated inference.
atom	unjust_seeming	one unites injustice with a deceitful regard to appearances
atom	fare_well	one fares to one's mind with gods and men, in life and after death
atom	reason_choose_justice	there is a principle on which to choose justice rather than the worst injustice
atom	superior	a man has some superiority of mind or person or rank or wealth
atom	honour_justice	the man is willing to honour justice
atom	knows_justice_best	someone is able to disprove these words and is satisfied that justice is best
atom	inspired	the divinity within him has inspired him with a hatred of injustice
atom	knows_truth	he has attained knowledge of the truth
atom	forgives_unjust	he is not angry with the unjust but is ready to forgive them
atom	just_freely	men are just of their own free will
atom	blames_injustice	a man blames injustice
atom	lacks_power	owing to cowardice or age or some weakness, he has not the power of being unjust
atom	obtains_power	he obtains the power of being unjust
atom	becomes_unjust	he immediately becomes unjust as far as he can be
P1	S1	unjust_seeming → fare_well	says authorities
P2	S1	unjust_seeming → fare_well
P3	S1	(unjust_seeming → fare_well) → ¬reason_choose_justice
C1	S1	¬reason_choose_justice	from P2 P3
A1	-	¬reason_choose_justice → (superior → ¬honour_justice)
C	S2	superior → ¬honour_justice	from C1 A1
P4	S3	¬just_freely	kind empirical
P5	S3	knows_justice_best ∧ ¬just_freely ∧ ¬(inspired ∨ knows_truth) → forgives_unjust
P6	S5	obtains_power → becomes_unjust	kind empirical
# S5 is offered as proof of S4; the step is written as the text gives it
C2	S4	blames_injustice → lacks_power	from P6
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

# reading 3 of locke-labour.md by claude-opus-5-5
atom	common	the earth and all inferior creatures are common to all men
atom	own_person	every man has a property in his own person, which no body has any right to but himself
atom	labour_his	the labour of his body and the work of his hands are properly his
atom	removes	he removes a thing out of the state that nature hath provided and left it in
atom	mixed	he hath mixed his labour with it and joined to it something that is his own
atom	property	he makes it his property
atom	enough	there is enough, and as good, left in common for others
atom	excludes	the labour annexed to it excludes the common right of other men, so that no man but he can have a right to it
A1	-	excludes → property
P1	S1	common ∧ own_person	kind normative
P2	S2	labour_his	kind normative
P3	S3	removes → mixed
P4	S3	mixed ∧ labour_his → property	kind normative
# S4 gives the reason the mixing makes property: the labour is his, so where enough is left it excludes others' right
P5	S4	labour_his ∧ mixed ∧ enough → excludes	kind normative
C	S3	removes → property	from P2 P3 P4 A1
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

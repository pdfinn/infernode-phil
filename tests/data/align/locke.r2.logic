# reading 2 of locke-labour.md by claude-opus-5-5
atom	common_earth	the earth and all inferior creatures are common to all men
atom	owns_person	every man has a property in his own person, to which nobody has any right but himself
atom	owns_labour	the labour of his body and the work of his hands are properly his
atom	removed	he removes a thing out of the state that nature hath provided and left it in
atom	mixed	he hath mixed his labour with the thing and joined to it something that is his own
atom	property	the thing is made his property
atom	enough_left	there is enough, and as good, left in common for others
atom	excludes	the thing has something annexed to it that excludes the common right of other men, so that no man but the labourer can have a right to it
P1	S1	common_earth ∧ owns_person
P2	S2	owns_labour
P3	S3	removed → mixed
P4	S3	mixed → property
P5	S4	owns_labour ∧ mixed ∧ enough_left → excludes
C1	S4	removed ∧ enough_left → excludes	from P2 P3 P5
# S2 is not drawn explicitly from S1; it is stated on its own ("we may say"), so it is entered as a premise.
# S4's qualifier ("at least where there is enough, and as good, left in common") attaches to the exclusion of others' right; S3's claim that removal makes the thing property is stated without it.
C	S3	removed → property	from P3 P4
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

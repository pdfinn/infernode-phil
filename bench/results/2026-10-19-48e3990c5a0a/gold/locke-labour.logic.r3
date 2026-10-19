# reading 2 of locke-labour.md by claude-opus-5-5
atom	earth_common	the earth, and all inferior creatures, are common to all men
atom	owns_person	every man has a property in his own person, to which nobody but himself has any right
atom	labour_his	the labour of his body and the work of his hands are properly his
atom	removes	he removes a thing out of the state that nature hath provided and left it in
atom	mixed	he hath mixed his labour with the thing and joined to it something that is his own
atom	property	he thereby makes the thing his property
atom	enough_left	there is enough, and as good, left in common for others
atom	no_other_right	no man but he can have a right to what his labour is once joined to
atom	excludes	the thing hath by his labour something annexed to it that excludes the common right of other men
P1	S1	earth_common ∧ owns_person
P2	S2	labour_his
P3	S3	removes → mixed
P4	S4	labour_his ∧ mixed ∧ enough_left → no_other_right
P5	S4	no_other_right → excludes
C1	S4	removes ∧ enough_left → excludes	from P2 P3 P4 P5
# The step from excluding others' common right to the thing being his property is relied on but never stated.
A1	-	excludes → property
# S3 says without condition that removing a thing makes it his property, though S4 grounds this only "where there is enough, and as good, left"; written as the text has it.
C	S3	removes → property	from C1 A1
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

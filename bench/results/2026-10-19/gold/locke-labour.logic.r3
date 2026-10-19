# the argument of locke-labour.md as claude-opus-5-5 read it: check that it says what the text says
# Locke: labour mixed with what is common makes it the labourer's property
# x ranges over things removed from the common state of nature
atom	common_nature	the earth and all inferior creatures are common to all men
atom	own_person	every man has a property in his own person, to which nobody but himself has any right
atom	labour_his	the labour of his body and the work of his hands are properly his
atom	removes(x)	he removes x out of the state that nature hath provided and left it in
atom	mixed(x)	he hath mixed his labour with x
atom	joined_own(x)	he hath joined to x something that is his own
atom	property(x)	x is his property
atom	enough_left(x)	there is enough, and as good, left in common for others besides x
atom	excludes(x)	x has something annexed to it that excludes the common right of other men
A1	-	∀x (excludes(x) → property(x))
P1	S1	common_nature ∧ own_person
P2	S2	labour_his
P3	S3	∀x (removes(x) → mixed(x))
P4	S3	∀x (mixed(x) ∧ labour_his → joined_own(x))
P5	S3	∀x (joined_own(x) → property(x))
# S4: no man but he can have a right to what his labour is joined to, at least where enough and as good is left in common
P6	S4	∀x (joined_own(x) ∧ enough_left(x) → excludes(x))
C1	S4	∀x (removes(x) ∧ enough_left(x) → excludes(x))	from P2 P3 P4 P6
# S3's "then ... thereby makes it his property" is taken as the main conclusion
C	S3	∀x (removes(x) → property(x))	from P2 P3 P4 P5 A1
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

# the argument of mill-proof.md as claude-opus-5-5 read it: check that it says what the text says
atom	desires_own	each person, so far as he believes it to be attainable, desires his own happiness
atom	own_good	each person's happiness is a good to that person
atom	general_good	the general happiness is a good to the aggregate of all persons
atom	end_of_conduct	happiness has made out its title as one of the ends of conduct
atom	criterion	happiness is one of the criteria of morality
# S1-S2 are analogies (visible/seen, audible/heard) supporting S3; left out as illustration.
# S3 read as: that people actually desire happiness is evidence that it is desirable (a good).
P1	S3	desires_own → own_good
P2	S6	desires_own	kind empirical
C1	S6	own_good	from P1 P2
P3	S6	own_good → general_good
C2	S6	general_good	from C1 P3
# The step from 'happiness is a good' to 'happiness is an end of conduct' is not stated.
A1	-	general_good → end_of_conduct
C3	S7	end_of_conduct	from C2 A1
P4	S7	end_of_conduct → criterion
C	S7	criterion	from C3 P4
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

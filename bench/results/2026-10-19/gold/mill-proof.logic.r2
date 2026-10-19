# reading 3 of mill-proof.md by claude-opus-5-5
# Mill's proof of the principle of utility: desire is the only evidence that something is desirable.
# S1, S2 and S4 are analogies or framing and are left out; S5 is captured in the S3 principle and the S6 fact.
atom	desires_own	each person, so far as he believes it to be attainable, desires his own happiness
atom	proven_good	we have all the proof which the case admits of that happiness is a good
atom	own_good	each person's happiness is a good to that person
atom	general_good	the general happiness is a good to the aggregate of all persons
atom	end_of_conduct	happiness has made out its title as one of the ends of conduct
atom	criterion	happiness is one of the criteria of morality
P1	S6	desires_own	kind empirical
P2	S3	desires_own → proven_good
C1	S6	proven_good	from P1 P2
A1	-	proven_good → own_good
C2	S6	own_good	from C1 A1
# S6 "therefore": the step from each person's good to the aggregate's good is written as the text gives it, with no bridging premise.
C3	S6	general_good	from C2
A2	-	general_good → end_of_conduct
A3	-	end_of_conduct → criterion	kind conceptual
C	S7	end_of_conduct ∧ criterion	from C3 A2 A3
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

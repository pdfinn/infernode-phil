# reading 3 of mill-proof.md by claude-opus-5-5
# Mill's proof of the principle of utility.
# The word "desirable" changes its sense. In S3 it is read on the model of
# visible/audible as "capable of being desired" (desirable_capable). In S6 it
# yields "a good", i.e. "worthy of desire" (own_good). The two senses are kept
# as separate atoms and are not joined.
# S4 is left out: it is a general remark about proving ends, and nothing is
# drawn from it.
atom	seen	people actually see the object
atom	visible	the object is visible (capable of being seen)
atom	heard	people actually hear the sound
atom	audible	the sound is audible (capable of being heard)
atom	desires_own	each person, so far as he believes it attainable, desires his own happiness
atom	desirable_capable	happiness is desirable in the sense of capable of being desired
atom	own_good	each person's happiness is a good to that person (desirable in the sense of worthy of desire)
atom	general_good	the general happiness is a good to the aggregate of all persons
atom	end_of_conduct	happiness is one of the ends of conduct
atom	criterion	happiness is one of the criteria of morality
A1	-	end_of_conduct → criterion
P1	S1	seen → visible
P2	S2	heard → audible
P3	S3	desires_own → desirable_capable
# S5 states that the only reason is that each person desires his own
# happiness; S6 affirms that this is a fact.
P4	S6	desires_own	kind empirical
C1	S6	desirable_capable	from P3 P4
# The step from "desirable" (capable) to "a good" (worthy) is the equivocation.
C2	S6	own_good	from C1
# The step from each person's good to the aggregate's good is drawn
# with "therefore".
C3	S6	general_good	from C2
C	S7	end_of_conduct ∧ criterion	from C2 C3 A1
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

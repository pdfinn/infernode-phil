# the argument of hume-enquiry-1.md as claude-opus-5-5 read it: check that it says what the text says
# S1 only frames the Catholic ceremonies as further instances; it is left out.
# "devotees" names the Catholic devotees whose plea S2-S3 report.
atom	practices_enliven	external motions, postures and actions enliven the devotees' devotion and quicken their fervour, which would otherwise decay
atom	types_make_present	sensible types and images render the objects of faith more present than intellectual contemplation alone can
atom	sensible_greater	sensible objects have always a greater influence on the fancy than any other
atom	convey_to_resembling	sensible objects readily convey this influence to the ideas to which they are related and which they resemble
atom	resemblance_common	the effect of resemblance in enlivening the ideas is very common
atom	concur	in every case a resemblance and a present impression concur
atom	principle_proved	we are abundantly supplied with experiments to prove the reality of the foregoing principle
P1	S2	practices_enliven	says devotees
P2	S3	types_make_present	says devotees
# Hume infers "from these practices, and this reasoning", so he argues from the devotees' report himself.
P3	S2	practices_enliven	kind empirical
P4	S4	sensible_greater ∧ convey_to_resembling	kind empirical
# "must concur" is read as a plain general claim about every case, not as modal necessity.
P5	S5	concur
A1	-	practices_enliven ∧ sensible_greater ∧ convey_to_resembling → resemblance_common
A2	-	resemblance_common ∧ concur → principle_proved
C1	S5	resemblance_common	from P3 P4 A1
C	S5	principle_proved	from C1 P5 A2
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

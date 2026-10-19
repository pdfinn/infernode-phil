# the argument of hume-enquiry-1.md as claude-opus-5-5 read it: check that it says what the text says
# The devotees' plea (S2, S3) is reported as theirs; Hume then reasons from "these practices, and this reasoning" (S5), so the plea is also entered as a plain premise.
# S1 only frames the case as an instance of the same nature and is left out.
atom	ceremonies_enliven	the external motions, postures and actions of the ceremonies enliven devotion and quicken fervour
atom	types_render_present	sensible types and images render the objects of faith more present than intellectual contemplation can
atom	sensible_influence	sensible objects have a greater influence on the fancy and readily convey it to the ideas they are related to and resemble
atom	resemblance_common	the effect of resemblance in enlivening the ideas is very common
atom	concur	in every case a resemblance and a present impression concur
atom	principle_proven	we are abundantly supplied with experiments to prove the reality of the foregoing principle
P1	S2	ceremonies_enliven	says devotees
P2	S3	types_render_present	says devotees
P3	S2	ceremonies_enliven	kind empirical
P4	S3	types_render_present	kind empirical
P5	S4	sensible_influence
# "must concur" in S5 is read as a general fact about every case and written as a plain atom, not a modal.
P6	S5	concur
# Unstated: that these practices are instances of resemblance enlivening ideas.
A1	-	ceremonies_enliven ∧ types_render_present ∧ sensible_influence → resemblance_common
C1	S5	resemblance_common	from P3 P4 P5 A1
# Unstated: a common effect, together with the concurrence of resemblance and present impression, supplies experiments proving the principle.
A2	-	resemblance_common ∧ concur → principle_proven
C	S5	principle_proven	from C1 P6 A2
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

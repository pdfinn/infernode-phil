# the argument of berkeley-principles-1.md as claude-opus-5-5 read it: check that it says what the text says
# Berkeley, "a third argument ad hominem": the modern philosophers' argument from perceptual variation, applied to heat, cold and sweetness, works equally for figure, extension and motion
# The variation arguments for heat/cold and sweetness are reported from "modern philosophers" (keyed "moderns"); the ad hominem argues from them, so they are also written as plain premises
atom	heat_varies	the same body which appears cold to one hand seems warm to another
atom	heat_mind	heat and cold are affections only of the mind, not patterns of real beings existing in corporeal substances
atom	figure_varies	figure and extension appear various to the same eye at different stations, or to eyes of a different texture at the same station
atom	figure_mind	figure and extension are not patterns or resemblances of qualities existing in Matter, settled and determinate without the mind
atom	sweet_varies	the thing remaining unaltered, the sweetness is changed into bitter, as in a fever or otherwise vitiated palate
atom	sweet_mind	sweetness is not really in the sapid thing
atom	motion_varies	if the succession of ideas in the mind becomes swifter, the motion appears slower without any alteration in any external object
atom	motion_mind	motion is not without the mind
atom	all_mind	all sensible qualities whatsoever have no existence in Matter, or without the mind
P1	S2	heat_varies → heat_mind	says moderns
P2	S2	heat_varies	kind empirical
P3	S2	heat_varies → heat_mind
P4	S3	figure_varies	kind empirical
P5	S3	figure_varies → figure_mind
C1	S3	figure_mind	from P4 P5
P6	S4	sweet_varies → sweet_mind	says moderns
P7	S4	sweet_varies	kind empirical
P8	S4	sweet_varies → sweet_mind
P9	S5	motion_varies	kind empirical
P10	S5	motion_varies → motion_mind
C2	S5	motion_mind	from P9 P10
A1	-	heat_mind ∧ sweet_mind ∧ figure_mind ∧ motion_mind → all_mind
C	S1	all_mind	from P2 P3 C1 P7 P8 C2 A1
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

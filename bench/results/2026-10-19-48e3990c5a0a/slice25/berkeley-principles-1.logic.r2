# the argument of berkeley-principles-1.md as claude-opus-5-5 read it: check that it says what the text says
# Berkeley's third ad hominem argument: the moderns' relativity reasoning for secondary
# qualities works just as well for figure, extension and motion.
# The moderns' inferences are reported in S2 and S4. Berkeley then argues from them
# ad hominem, so they appear again as plain premises.
# I read S1's "all other sensible qualities" through the two cases the text gives,
# figure/extension and motion.
atom	heat_vary	the same body appears cold to one hand and warm to another
atom	heat_mind	heat and cold are affections only of the mind, not patterns of real beings in corporeal substances
atom	figure_vary	figure and extension appear various to the same eye at different stations, or to eyes of different texture at the same station
atom	figure_mind	figure and extension are not patterns of qualities existing in Matter, nothing settled and determinate without the mind
atom	sweet_vary	the thing remaining unaltered, its sweetness is changed into bitter, as in a fever or vitiated palate
atom	sweet_mind	sweetness is not really in the sapid thing
atom	motion_vary	if the succession of ideas in the mind becomes swifter, motion appears slower without any alteration in any external object
atom	motion_mind	motion is not without the mind
P1	S2	heat_vary → heat_mind	says moderns
P2	S2	heat_vary	says moderns
P3	S2	heat_vary → heat_mind
P4	S3	figure_vary	kind empirical
# S3's rhetorical question asserts a parity: if the heat inference holds, so does the figure one.
P5	S3	(heat_vary → heat_mind) → (figure_vary → figure_mind)
P6	S4	sweet_vary → sweet_mind	says moderns
P7	S4	sweet_vary	says moderns
P8	S4	sweet_vary → sweet_mind
P9	S5	motion_vary	kind empirical
# S5's rhetorical question asserts a parity between the sweetness inference and the motion one.
P10	S5	(sweet_vary → sweet_mind) → (motion_vary → motion_mind)
C1	S3	figure_mind	from P3 P4 P5
C2	S5	motion_mind	from P8 P9 P10
C	S1	figure_mind ∧ motion_mind	from C1 C2
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

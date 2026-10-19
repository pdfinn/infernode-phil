# reading 2 of hume-induction.md by claude-opus-5-5
atom	arg_exists	there is an argument engaging us to trust past experience and make it the standard of our future judgement
atom	demo_arg	there is a demonstrative argument (concerning relations of ideas) that the future will be conformable to the past
atom	moral_arg	there is a probable or moral argument (concerning matter of fact and existence) that the future will be conformable to the past
atom	change_conceivable	it implies no contradiction, and can be distinctly conceived, that the course of nature may change
atom	presupposes_uniformity	arguments concerning existence proceed upon the supposition that the future will be conformable to the past
atom	circular	proving this supposition by probable arguments goes in a circle, taking for granted the very point in question
P1	S1	arg_exists → demo_arg ∨ moral_arg	kind conceptual
P2	S2	change_conceivable
P3	S5	change_conceivable → ¬demo_arg	kind conceptual
C1	S2	¬demo_arg	from P2 P3
P4	S6	arg_exists → moral_arg
P5	S8	presupposes_uniformity
P6	S9	presupposes_uniformity → circular
C2	S9	circular	from P5 P6
A1	-	circular → ¬moral_arg
C3	S7	¬moral_arg	from C2 A1
C	S7	¬arg_exists	from P1 C1 C3
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

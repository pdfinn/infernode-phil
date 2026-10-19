# the argument of hume-induction.md as claude-opus-5-5 read it: check that it says what the text says
logic	s5
atom	trust_arg	there are arguments that engage us to trust past experience and make it the standard of our future judgement
atom	demo_arg	there is a demonstrative argument (relations of ideas) that the future will be conformable to the past
atom	prob_arg	there is a probable argument (matter of fact and existence) that the future will be conformable to the past, without going in a circle
atom	no_contradiction	it implies no contradiction that the course of nature may change
atom	conceivable	that the course of nature may change, and like objects have contrary effects, can be clearly and distinctly conceived
atom	causal_founded	all arguments concerning existence are founded on the relation of cause and effect
atom	from_experience	our knowledge of the relation of cause and effect is derived entirely from experience
atom	presuppose_uniformity	all our experimental conclusions proceed upon the supposition that the future will be conformable to the past
# S1's division of all reasonings into two kinds, applied to arguments for trusting experience
P1	S1	trust_arg → demo_arg ∨ prob_arg	kind conceptual
P2	S2	no_contradiction
# S3 and S4 are rhetorical questions affirming conceivability
P3	S3	conceivable
P4	S5	conceivable → no_contradiction ∧ ¬demo_arg	kind conceptual
C1	S2	¬demo_arg	from P3 P4
C2	S6	trust_arg → prob_arg	from P1 C1
P5	S8	causal_founded
P6	S8	from_experience
P7	S8	presuppose_uniformity
# S9: proving the supposition by probable arguments would go in a circle, so no such (non-circular) argument
P8	S9	presuppose_uniformity → ¬prob_arg
C3	S9	¬prob_arg	from P7 P8
C	S7	¬trust_arg	from C2 C3
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

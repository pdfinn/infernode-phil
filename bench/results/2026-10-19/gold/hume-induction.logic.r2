# reading 2 of hume-induction.md by claude-opus-5-5
logic	s5
atom	nature_change_conceivable	that the course of nature may change, and an object like those experienced be attended with different or contrary effects, can be clearly and distinctly conceived
atom	no_contradiction	it implies no contradiction that the course of nature may change
atom	arg_any	there are arguments which engage us to put trust in past experience and make it the standard of our future judgement
atom	arg_demo	there is a demonstrative argument, concerning relations of ideas, for trusting past experience
atom	arg_moral	there is a probable argument, regarding matter of fact and existence, that proves that the future will be conformable to the past
atom	founded_cause	all arguments concerning existence are founded on the relation of cause and effect
atom	cause_from_experience	our knowledge of the relation of cause and effect is derived entirely from experience
atom	presuppose_uniformity	all our experimental conclusions proceed upon the supposition that the future will be conformable to the past
atom	circular	proving the supposition by probable arguments is going in a circle, taking for granted the very point in question
P1	S1	arg_any → arg_demo ∨ arg_moral	kind conceptual
P2	S2	no_contradiction → ¬arg_demo
P3	S3	nature_change_conceivable
# S5 "whatever is intelligible ... implies no contradiction" read as a necessary truth
P4	S5	□(nature_change_conceivable → no_contradiction)	kind conceptual
C1	S2	¬arg_demo	from P2 P3 P4
C2	S6	arg_any → arg_moral	from P1 C1
P5	S8	founded_cause
P6	S8	cause_from_experience
P7	S8	presuppose_uniformity
# the "therefore" of S9 plainly relies on the S8 claims yielding circularity
A1	-	founded_cause ∧ cause_from_experience ∧ presuppose_uniformity → circular
C3	S9	circular	from P5 P6 P7 A1
# S7 relies on a circular argument not being a genuine probable argument for the point
A2	-	circular → ¬arg_moral
C	S7	¬arg_any	from C2 C3 A2
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

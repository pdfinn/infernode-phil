# the argument of hume-induction.md as claude-opus-5-5 read it: check that it says what the text says
# Hume's argument that no reasoning grounds our trust in past experience.
# "the case" / "this supposition" = that the future will be conformable to the past.
atom	arg_exists	there are arguments that engage us to put trust in past experience and make it the standard of future judgement
atom	demo	there is a demonstrative argument (concerning relations of ideas) that the future will be conformable to the past
atom	moral	there is a sound probable (moral) argument, regarding matter of fact and existence, that the future will be conformable to the past
atom	noncontra	it implies no contradiction that the course of nature may change
atom	conceivable	a change in the course of nature (e.g. salty snow, trees flourishing in December) is intelligible and can be distinctly conceived
atom	founded_cause	all arguments concerning existence are founded on the relation of cause and effect
atom	from_exp	our knowledge of the relation of cause and effect is derived entirely from experience
atom	presuppose	all our experimental conclusions proceed upon the supposition that the future will be conformable to the past
atom	circular	proving that the future will be conformable to the past by probable arguments goes in a circle, taking for granted the very point in question
A2	-	founded_cause ∧ from_exp ∧ presuppose → circular
P1	S1	arg_exists → demo ∨ moral	kind conceptual
P2	S2	noncontra
P3	S2	noncontra → ¬demo	kind conceptual
P4	S3	conceivable
P5	S5	conceivable → noncontra ∧ ¬demo	kind conceptual
C1	S2	¬demo	from P2 P3
C2	S6	arg_exists → moral	from P1 C1
P6	S8	founded_cause ∧ from_exp ∧ presuppose
P7	S9	founded_cause ∧ from_exp ∧ presuppose → (moral → circular)
# Unstated: a circular argument, one that begs the question, is no sound argument for its point.
A1	-	circular → ¬moral	kind conceptual
C	S7	¬moral	from P6 P7 A1 A2
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

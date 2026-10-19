# the argument of hume-treatise-1.md as claude-opus-5-5 read it: check that it says what the text says
logic	s5
# Hume's argument concerns the idea of causation; the general claims in S2 are applied to that idea.
atom	reason_justly	we reason justly concerning causation
atom	understand_idea	we understand perfectly the idea of causation
atom	trace_origin	we trace the idea of causation up to its origin and examine the primary impression from which it arises
atom	clear_idea	the idea is made clear
atom	clear_reasoning	all our reasoning is made clear
# S2: "impossible to reason justly without understanding perfectly" is read as a necessary conditional.
P1	S2	□(reason_justly → understand_idea)
P2	S2	□(understand_idea → trace_origin)
# S3 supports the method but is not needed for the conclusion.
P3	S3	trace_origin → clear_idea
P4	S3	clear_idea → clear_reasoning
# S1: "we must consider the idea of causation and see from what origin it is derived."
# "Must" is read as the necessity of tracing the origin if we are to reason justly, drawn from S2.
# It could instead be read as a practical requirement, but no deontic premise is given.
C	S1	□(reason_justly → trace_origin)	from P1 P2
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

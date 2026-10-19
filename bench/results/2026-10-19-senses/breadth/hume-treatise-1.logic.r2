# the argument of hume-treatise-1.md as claude-opus-5-5 read it: check that it says what the text says
logic	s5
# Hume, Treatise 1.3.2. "Impossible" in S2 is read as necessity.
# The "must" of S1 is read as a necessary condition: reasoning justly about causation requires tracing the idea to its origin.
atom	reason_justly	we reason justly concerning the idea of causation
atom	understand_perfectly	we understand perfectly the idea of causation
atom	trace_origin	we trace the idea of causation up to its origin and examine the primary impression from which it arises
atom	clear_idea	a clearness is bestowed on the idea of causation
atom	clear_reasoning	a like clearness is bestowed on all our reasoning concerning causation
P1	S2	□(reason_justly → understand_perfectly)	kind conceptual
P2	S2	□(understand_perfectly → trace_origin)	kind conceptual
P3	S3	trace_origin → clear_idea
P4	S3	clear_idea → clear_reasoning
C	S1	□(reason_justly → trace_origin)	from P1 P2
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

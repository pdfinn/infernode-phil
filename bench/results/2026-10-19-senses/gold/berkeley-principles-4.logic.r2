# reading 2 of berkeley-principles-4.md by claude-opus-5-5
logic	s5
# The prover's modal logic is propositional, so the quantified claims about all sensible objects are written as single propositions about sensible objects in general.
atom	objects_sensed	the fore-mentioned objects (houses, mountains, rivers, all sensible objects) are the things we perceive by sense
atom	sensed_ideas	what we perceive by sense is nothing besides our own ideas or sensations
atom	ideas_unperceived	some one of our ideas or sensations, or some combination of them, exists unperceived
atom	objects_unperceived	sensible objects have an existence, natural or real, distinct from their being perceived by the understanding
# S1 reports the prevailing opinion of men, which the text goes on to reject; written as an objection to the conclusion.
O1	S1	objects_unperceived	against C
# S3 "what are the fore-mentioned objects but the things we perceive by sense?": rhetorical question read as assertion.
P1	S3	objects_sensed	kind conceptual
# S3 "what do we perceive besides our own ideas or sensations?": rhetorical question read as assertion.
P2	S3	sensed_ideas
# S3 "plainly repugnant that any one of these ... should exist unperceived": read as impossibility.
P3	S3	¬◇ideas_unperceived	kind conceptual
# The text relies on this: if the objects are the things perceived by sense, and these are only ideas, then the objects' existing unperceived would be ideas existing unperceived.
A1	-	objects_sensed ∧ sensed_ideas → □(objects_unperceived → ideas_unperceived)
# S2: the principle involves a manifest contradiction, i.e. sensible objects cannot exist unperceived.
C	S2	¬◇objects_unperceived	from P1 P2 P3 A1
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

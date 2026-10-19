# the argument of aquinas-ontological-objection.md as claude-opus-5-5 read it: check that it says what the text says
# The text is Objection 2 itself; its argument is written as given.
# S3 only illustrates the principle with whole and part, so it is left out.
atom	known_once_terms	as soon as the signification of the word "God" is understood, it is at once seen that God exists
atom	self_evident	the proposition "God exists" is self-evident
atom	first_principles_known	the first principles of demonstration are known as soon as their terms are known
atom	meaning	by the word "God" is signified that thing than which nothing greater can be conceived
atom	actual_greater	that which exists actually and mentally is greater than that which exists only mentally
atom	exists_mentally	as soon as the word "God" is understood, it exists mentally
P1	S2	known_once_terms → self_evident	kind conceptual
P2	S2	first_principles_known	says aristotle
P3	S5	meaning	kind conceptual
P4	S6	actual_greater	kind conceptual
P5	S7	exists_mentally
# S7's "it follows" relies on this step, from the meaning, greater-than and mental existence to God's existence being seen at once; the text never states it as a conditional.
A1	-	meaning ∧ actual_greater ∧ exists_mentally → known_once_terms
C1	S4	known_once_terms	from P3 P4 P5 A1
C	S8	self_evident	from P1 C1
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

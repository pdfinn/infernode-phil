# reading 3 of aquinas-ontological-objection.md by claude-opus-5-5
# Obj. 2 argues that "God exists" is self-evident. The rule is: what is known as soon as its terms are known is self-evident.
# S3 only illustrates, so it is left out.
# S4's claim is treated as the step that S5-S7 support.
atom	known_on_terms	"God exists" is known as soon as its terms are known
atom	self_evident	the proposition "God exists" is self-evident
atom	first_principles_known_on_terms	the first principles of demonstration are known as soon as their terms are known
atom	signifies_greatest	by the word "God" is signified that thing than which nothing greater can be conceived
atom	greater_actual	that which exists actually and mentally is greater than that which exists only mentally
atom	understood	the word "God" is understood
atom	exists_mentally	God exists mentally
atom	exists_actually	God exists actually
P1	S2	known_on_terms → self_evident	kind conceptual
P2	S2	first_principles_known_on_terms	says aristotle
P3	S5	signifies_greatest	kind conceptual
P4	S6	greater_actual	kind conceptual
P5	S7	understood → exists_mentally
A1	-	understood
A2	-	signifies_greatest ∧ greater_actual ∧ exists_mentally → exists_actually
C1	S7	exists_actually	from P3 P4 P5 A1 A2
# S4 reads "as soon as the word is understood, it is at once seen that God exists" as the term-knowledge condition.
A3	-	(understood → exists_actually) → known_on_terms
C2	S4	known_on_terms	from C1 A3
C	S8	self_evident	from P1 C2
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

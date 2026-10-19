# reading 3 of aquinas-ontological-objection.md by claude-opus-5-5
atom	known_on_terms	the proposition "God exists" is known as soon as its terms are known (as soon as the signification of the word "God" is understood, it is at once seen that God exists)
atom	self_evident	the proposition "God exists" is self-evident
atom	first_principles_known	the first principles of demonstration are known as soon as their terms are known
atom	understood	the word "God" is understood
atom	signifies_greatest	by the word "God" is signified that thing than which nothing greater can be conceived
atom	greater_actual	that which exists actually and mentally is greater than that which exists only mentally
atom	mental	God exists mentally
atom	actual	God exists actually
# S2: things known as soon as their terms are known are said to be self-evident; applied here to "God exists"
P1	S2	known_on_terms → self_evident	kind conceptual
P2	S2	first_principles_known	says aristotle
# S3 (whole greater than part) only illustrates, so it is left out
P3	S5	signifies_greatest	kind conceptual
P4	S6	greater_actual
P5	S7	understood → mental
# S7 says "as soon as the word is understood", so the argument takes the word to be understood
A1	-	understood
# S7 rests on the reasoning that what is signified as the greatest conceivable, if it exists only mentally, would not be the greatest
A2	-	signifies_greatest ∧ greater_actual ∧ mental → actual
C1	S7	actual	from P3 P4 P5 A1 A2
# S4: that understanding the word suffices to see that God exists is what S5-S7 are offered to show
A3	-	understood ∧ actual → known_on_terms
C2	S4	known_on_terms	from C1 A1 A3
C	S8	self_evident	from C2 P1
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

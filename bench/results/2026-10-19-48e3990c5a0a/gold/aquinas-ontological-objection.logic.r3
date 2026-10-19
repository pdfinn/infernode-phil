# the argument of aquinas-ontological-objection.md as claude-opus-5-5 read it: check that it says what the text says
# Aquinas, ST I q.2 a.1, Objection 2: the argument is given in the objector's voice.
# The modal "can be conceived" in S5 is left inside the atom; no modal logic is used.
atom	known_on_terms	the proposition "God exists" is known as soon as its terms are known
atom	self_evident	the proposition "God exists" is self-evident
atom	first_principles_known	the first principles of demonstration are known as soon as their terms are known
atom	signifies_greatest	by the word "God" is signified that thing than which nothing greater can be conceived
atom	actual_greater	that which exists actually and mentally is greater than that which exists only mentally
atom	exists_mentally	as soon as the word "God" is understood, God exists mentally
atom	exists_actually	God exists actually
P1	S2	known_on_terms → self_evident	kind conceptual
P2	S2	first_principles_known	says aristotle
P3	S5	signifies_greatest	kind conceptual
P4	S6	actual_greater	kind conceptual
P5	S7	exists_mentally
# Unstated link: if the greatest conceivable thing existed only in the mind, something greater could be conceived.
A1	-	signifies_greatest ∧ actual_greater ∧ exists_mentally → exists_actually
C1	S7	exists_actually	from P3 P4 P5 A1
# Unstated link: since God's actual existence follows from the meaning of the word alone, it is seen as soon as the word is understood (S4 is supported by S5-S7, "For ...").
A2	-	signifies_greatest ∧ exists_mentally ∧ exists_actually → known_on_terms
C2	S4	known_on_terms	from C1 P3 P5 A2
C	S8	self_evident	from C2 P1
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

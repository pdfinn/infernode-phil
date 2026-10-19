# reading 3 of plato-gorgias-1.md by claude-opus-5-5
logic	kd
atom	rhet_counsel	the rhetorician will be taken into counsel when the assembly meets to elect a physician, a shipwright or any other craftsman
atom	rhet_most_skilled	the rhetorician is the one most skilled in the craft for which the election is held
atom	rhet_advises_building	the rhetorician, not the master workman, will advise when walls, harbours or docks have to be built
atom	rhet_advises_war	the rhetoricians, not the military, will advise when generals have to be chosen, an order of battle arranged or a position taken
# S4: "at every election he ought to be chosen who is most skilled", read as: it ought to be that whoever is taken into counsel is the most skilled
P1	S4	O(rhet_counsel → rhet_most_skilled)	kind normative
P2	S4	¬rhet_advises_building	kind empirical
P3	S4	¬rhet_advises_war	kind empirical
# Unstated: the rhetorician, as such, is not the most skilled in the craft in question
A1	-	¬rhet_most_skilled
# Unstated: the assembly does as it ought here, so S3's "Surely not" can be read as a prediction of what will happen, not only of what ought to
A2	-	O(rhet_counsel → rhet_most_skilled) → (rhet_counsel → rhet_most_skilled)
# P2 and P3 are parallel cases that support the conclusion by analogy; the derivation uses P1 with A1 and A2
C	S3	¬rhet_counsel	from P1 A1 A2
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

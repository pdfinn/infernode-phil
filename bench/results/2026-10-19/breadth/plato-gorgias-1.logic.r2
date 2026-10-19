# the argument of plato-gorgias-1.md as claude-opus-5-5 read it: check that it says what the text says
logic	kd
# S3's conclusion: the rhetorician will not be taken into counsel when craftsmen are elected.
# S4 supports it with a normative premise (the most skilled ought to be chosen) and with parallel cases (building, war).
# The bridge from "ought" to "will" is not stated in the text, so it is supplied as an assumption.
atom	rhet_counsel	when the assembly meets to elect a physician or shipwright or other craftsman, the rhetorician will be taken into counsel
atom	choose_skilled	at every election the one who is most skilled is chosen
atom	rhet_skilled	the rhetorician is the one most skilled in these crafts
atom	master_advises	when walls, harbours or docks have to be constructed, the master workman will advise
atom	rhet_advises_building	the rhetorician will advise when walls, harbours or docks have to be constructed
atom	military_advises	when generals are chosen or an order of battle arranged, the military will advise
atom	rhet_advises_war	the rhetoricians will advise when generals are chosen or an order of battle arranged
P1	S4	O choose_skilled	kind normative
P2	S4	master_advises ∧ ¬rhet_advises_building	kind empirical
P3	S4	military_advises ∧ ¬rhet_advises_war	kind empirical
# Unstated: the rhetorician, as such, is not the one most skilled in these crafts.
A1	-	¬rhet_skilled
# Unstated: if the most skilled ought to be chosen and the rhetorician is not the most skilled, he will not be taken into counsel.
A2	-	O choose_skilled ∧ ¬rhet_skilled → ¬rhet_counsel
C	S3	¬rhet_counsel
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

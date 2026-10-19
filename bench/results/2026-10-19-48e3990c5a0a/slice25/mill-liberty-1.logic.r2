# the argument of mill-liberty-1.md as claude-opus-5-5 read it: check that it says what the text says
# Mill, *On Liberty*: the theory that truth may justifiably be persecuted, and what it shows about its defenders.
atom	theory_holds_persecution_justified	the theory maintains that truth may justifiably be persecuted because persecution cannot possibly do it any harm
atom	theory_not_hostile	the theory cannot be charged with being intentionally hostile to the reception of new truths
atom	theory_generous	the theory deals generously with the persons to whom mankind are indebted for new truths
atom	discovery_great_service	to discover to the world something which deeply concerns it and of which it was ignorant is as important a service as a human being can render to his fellow-creatures
atom	most_precious_gift	in certain cases (the early Christians, the Reformers) such discovery was the most precious gift which could be bestowed on mankind
atom	theory_holds_martyrdom_justified	upon this theory, that the authors of such benefits should be requited by martyrdom is the normal and justifiable state of things
atom	defends_mistreatment	people defend this mode of treating benefactors
atom	values_benefit	those who defend this mode of treating benefactors set much value on the benefit
P1	S1	theory_holds_persecution_justified → theory_not_hostile
P2	S1	¬theory_generous
P3	S1	theory_holds_persecution_justified
P4	S2	discovery_great_service	kind normative
P5	S2	most_precious_gift	says johnson
# Unstated: persecuting truth means persecuting those who discover it.
A1	-	theory_holds_persecution_justified → theory_holds_martyrdom_justified
C1	S3	theory_holds_martyrdom_justified	from P3 A1
# Unstated: those who hold the theory defend this treatment of benefactors.
A2	-	theory_holds_martyrdom_justified → defends_mistreatment
P6	S5	defends_mistreatment → ¬values_benefit
C	S5	¬values_benefit	from C1 A2 P6
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

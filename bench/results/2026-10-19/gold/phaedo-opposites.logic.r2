# the argument of phaedo-opposites.md as claude-opus-5-5 read it: check that it says what the text says
atom	opp_principle	all things which have opposites are generated out of their opposites
atom	life_death_opposites	death is opposed to life, as sleep is to waking
atom	gen_mutual	life and death are generated one from the other
atom	dead_from_living	the dead are generated from the living
atom	living_from_dead	the living, whether things or persons, are generated from the dead
atom	souls_below	our souls exist in the world below
P1	S12	opp_principle
P2	S23	opp_principle → (life_death_opposites → gen_mutual)
P3	S31	life_death_opposites
C1	S33	gen_mutual	from P1 P2 P3
P4	S36	gen_mutual → dead_from_living
P5	S38	gen_mutual → living_from_dead
C2	S39	living_from_dead	from C1 P5
# the step from the living coming from the dead to the souls existing below is never stated
A1	-	living_from_dead → souls_below
C	S41	souls_below	from C2 A1
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

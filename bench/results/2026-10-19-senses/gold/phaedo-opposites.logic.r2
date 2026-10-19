# the argument of phaedo-opposites.md as claude-opus-5-5 read it: check that it says what the text says
# The argument from opposites (Phaedo): opposites come from opposites; life and death are opposites;
# so the living come from the dead, and so our souls exist below.
# S17 says "necessarily holds"; I read this as stressing that the principle is general, not as a
# separate modal claim, so no modal operator is used.
atom	opposites_generated	all things which have opposites are generated out of their opposites
atom	life_death_opposites	death is the opposite of life
atom	mutual_generation	life and death are generated the one from the other
atom	living_from_dead	the living, whether things or persons, are generated from the dead
atom	souls_below	our souls exist in the world below
P1	S17	opposites_generated	kind conceptual
P2	S19	life_death_opposites	kind conceptual
# S23: "these, if they are opposites, are generated the one from the other", applying the general principle to life and death.
P3	S23	opposites_generated → (life_death_opposites → mutual_generation)
C1	S33	mutual_generation	from P1 P2 P3
# Mutual generation includes generation of the living from the dead (S35-S38).
A1	-	mutual_generation → living_from_dead
C2	S39	living_from_dead	from C1 A1
# The step from the living coming from the dead to souls existing below is not stated in this
# passage; it relies on the earlier claim that the living come from the souls of the dead in the world below.
A2	-	living_from_dead → souls_below
C	S41	souls_below	from C2 A2
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

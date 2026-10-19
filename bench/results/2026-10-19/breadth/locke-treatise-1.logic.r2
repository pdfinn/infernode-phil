# the argument of locke-treatise-1.md as claude-opus-5-5 read it: check that it says what the text says
logic	kd
atom	end_continuation	the end of conjunction between male and female is not barely procreation but the continuation of the species
atom	young_need_sustaining	the young are to be sustained by those that got them till they are able to shift and provide for themselves
atom	conj_lasts_while_needed	the conjunction betwixt male and female lasts, even after procreation, so long as is necessary to the nourishment and support of the young
atom	creatures_obey	the inferior creatures steadily obey this rule set by the infinite wise maker
atom	teat_sufficient	in grass-feeding viviparous animals the teat of the dam is sufficient to nourish the young till it can feed on grass
atom	male_contributes_nothing	the male can contribute nothing to the sustenance of the female or young
atom	grass_conj_only_copulation	in grass-feeding viviparous animals the conjunction lasts no longer than the act of copulation
atom	dam_cannot_alone	in beasts of prey the dam is not able well to subsist herself and nourish her numerous offspring by her own prey alone
atom	male_assist_necessary	in beasts of prey the assistance of the male is necessary to the maintenance of their common family
atom	prey_conj_longer	in beasts of prey the conjunction lasts longer
atom	bird_young_need_food	the young of birds need food in the nest
atom	birds_mates_continue	the cock and hen continue mates till the young are able to use their wing and provide for themselves
P1	S3	end_continuation	kind conceptual
P2	S3	young_need_sustaining	kind empirical
A1	-	end_continuation ∧ young_need_sustaining → O conj_lasts_while_needed
C	S3	O conj_lasts_while_needed
P3	S4	creatures_obey	kind empirical
P4	S5	teat_sufficient	kind empirical
P5	S5	teat_sufficient → male_contributes_nothing	kind empirical
P6	S5	male_contributes_nothing → grass_conj_only_copulation	kind empirical
P7	S6	dam_cannot_alone	kind empirical
P8	S6	dam_cannot_alone → male_assist_necessary	kind empirical
P9	S6	male_assist_necessary → prey_conj_longer	kind empirical
P10	S7	bird_young_need_food	kind empirical
P11	S7	bird_young_need_food → birds_mates_continue	kind empirical
# S5-S7 are offered as observed confirmation of S4 (that creatures obey the rule); the text does not state how they entail S4, so no step is drawn
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

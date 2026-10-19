# the argument of aquinas-st-i-ii-3.md as claude-opus-5-5 read it: check that it says what the text says
# Aquinas, Reply to Objection 2: why the Law forbade many kinds of animal food but not the products of the soil.
atom	flesh_after_deluge	the eating of flesh seems to have been introduced after the deluge
atom	plants_before_deluge	men were wont to eat plants and other products of the soil even before the deluge
atom	herbs_little_effort	the soil gives birth to the herb of its own accord, and such products may be had in great quantities with very little effort
atom	animals_much_trouble	no small trouble is necessary either to rear or to catch an animal
atom	soil_simple	the eating of the products of the soil savors rather of a simple life
atom	flesh_delicate	the eating of flesh savors of delicate and over-careful living
atom	god_wishes_simple	God was wishful to bring His people back to a more simple way of living
atom	forbid_animals	God forbade His people to eat many kinds of animals
atom	forbid_soil	God forbade His people to eat the things produced by the soil
atom	animals_idols	animals were offered to idols
atom	soil_idols	the products of the soil were offered to idols
P1	S2	plants_before_deluge ∧ flesh_after_deluge	kind empirical
P2	S4	herbs_little_effort ∧ animals_much_trouble	kind empirical
A1	-	herbs_little_effort ∧ animals_much_trouble → soil_simple ∧ flesh_delicate
C1	S3	soil_simple ∧ flesh_delicate	from P2 A1
P3	S5	god_wishes_simple
A2	-	god_wishes_simple ∧ soil_simple ∧ flesh_delicate → forbid_animals ∧ ¬forbid_soil
C	S5	forbid_animals ∧ ¬forbid_soil	from C1 P3 A2
# S6 offers an alternative reason ("may be"); recorded as a premise with its implicit link.
P4	S6	animals_idols ∧ ¬soil_idols	kind empirical
A3	-	animals_idols ∧ ¬soil_idols → forbid_animals ∧ ¬forbid_soil
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

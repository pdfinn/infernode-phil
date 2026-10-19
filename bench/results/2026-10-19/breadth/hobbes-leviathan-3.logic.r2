# the argument of hobbes-leviathan-3.md as claude-opus-5-5 read it: check that it says what the text says
# Hobbes reports Bellarmine's argument from David's fasting and rebuts it: the fasting was for honour, not to obtain anything for the dead
atom	natural_eternity	separated souls have a natural eternity
atom	purgatory	there is a Purgatory, a third place for souls of the dead that are neither in Heaven nor in Hell
atom	grace_only	eternal life is by grace only
atom	body_life_only	there is no life but the life of the body, and no immortality till the Resurrection
atom	separate_soul	the soul has an existence separate from the body
atom	fast_to_obtain	David's fasting for Saul, Jonathan and Abner was to obtain something for them at God's hands after their death
atom	fast_for_honour	David's fasting for Saul and Abner was used for honour's sake to their persons
atom	texts_prove	the texts on David's fasting alleged by Bellarmine prove a Purgatory
P1	S1	purgatory → natural_eternity
P2	S2	grace_only → body_life_only
A1	-	body_life_only → ¬natural_eternity
P3	S7	fast_to_obtain	says bellarmine
P4	S8	separate_soul ∧ fast_to_obtain → purgatory	says bellarmine
P5	S8	separate_soul	says bellarmine
# Bellarmine's proof from these texts goes through only if the fasting was to obtain something for the dead
A2	-	texts_prove → fast_to_obtain
P6	S9	fast_for_honour	kind empirical
# Mourning and fasting for those whose life was not profitable to the mourners are used for honour's sake, not to obtain anything for them
P7	S9	fast_for_honour → ¬fast_to_obtain	kind empirical
C	S9	¬texts_prove	from A2 P6 P7
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

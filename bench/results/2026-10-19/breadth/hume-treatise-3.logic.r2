# the argument of hume-treatise-3.md as claude-opus-5-5 read it: check that it says what the text says
atom	danger	this contrariety of passions would be attended with more than small danger
atom	peculiarity	the contrariety of passions concurs with a peculiarity in our outward circumstances, which affords it an opportunity of exerting itself
atom	first_secure	we are perfectly secure in the enjoyment of the internal satisfaction of our minds
atom	second_ravishable	the external advantages of our body may be ravished from us
atom	second_advantage	the external advantages of our body can be of advantage to him who deprives us of them
atom	third_exposed	the possessions acquired by our industry and good fortune are exposed to the violence of others
atom	third_transferable	the possessions acquired by our industry and good fortune may be transferred without suffering any loss or alteration
atom	third_scarce	there is not a sufficient quantity of acquired possessions to supply every one's desires and necessities
atom	improvement_advantage	the improvement of these goods is the chief advantage of society
atom	instability_impediment	the instability of the possession of these goods, along with their scarcity, is the chief impediment of society
P1	S1	¬peculiarity → ¬danger
P2	S3	first_secure	kind empirical
P3	S4	second_ravishable ∧ ¬second_advantage	kind empirical
P4	S5	third_exposed ∧ third_transferable ∧ third_scarce	kind empirical
P5	S6	improvement_advantage
# The step from the features of acquired goods to their being the chief impediment is left implicit; S6's "therefore" relies on it.
A1	-	third_exposed ∧ third_transferable ∧ third_scarce → instability_impediment
C	S6	instability_impediment	from P4 A1
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

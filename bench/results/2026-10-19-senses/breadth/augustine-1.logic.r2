# the argument of augustine-1.md as claude-opus-5-5 read it: check that it says what the text says
# The S1 to S3 lament (models praised for eloquent vice, God's forbearance) is not part of the argument for S7, so it is left out.
# S6 is a rhetorical question, read as: the prodigal son did not leave by physical means.
atom	leave_by_place	men leave God, or return to him, by their feet or by change of place
atom	removal_darkened	darkened affections are removal from God
atom	prodigal_physical	the younger son left for the far country by horses, chariots, ships, wings or the motion of his limbs
atom	distance_affections	the true distance from God's face is in lustful, that is darkened, affections
P1	S4	removal_darkened
P2	S5	¬leave_by_place
P3	S6	¬prodigal_physical
# The text relies on the prodigal son as a case standing for how men leave God.
A1	-	¬prodigal_physical → ¬leave_by_place
C1	S5	¬leave_by_place	from P3 A1
# If leaving God is not a matter of place but darkened affections are removal from him, then the true distance lies in those affections.
A2	-	removal_darkened ∧ ¬leave_by_place → distance_affections
C	S7	distance_affections	from P1 C1 A2
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

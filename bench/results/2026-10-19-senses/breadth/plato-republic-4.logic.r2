# the argument of plato-republic-4.md as claude-opus-5-5 read it: check that it says what the text says
# The passage exhorts rather than argues: S2 points to the soul's love of wisdom and its kinship with the divine,
# and says what would follow if she followed that principle. S3 closes the topic, but nothing in S1 or S2 supports it,
# so the conclusion is written as the text gives it, with no premise linking to it.
atom	kin_divine	the soul is near kindred with the immortal and eternal and divine
atom	loves_wisdom	the soul has a love of wisdom
atom	follows_superior	the soul wholly follows this superior principle
atom	disengaged	the soul is disengaged from the stones and shells and things of earth which grow around her
atom	seen_as_is	you would see her as she is and know what her nature is
atom	said_enough	we have now said enough of her affections and of the forms she takes in this present life
P1	S2	kin_divine
P2	S1	loves_wisdom
P3	S2	follows_superior ∧ disengaged → seen_as_is
C	S3	said_enough
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

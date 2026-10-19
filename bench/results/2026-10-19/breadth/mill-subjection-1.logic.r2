# the argument of mill-subjection-1.md as claude-opus-5-5 read it: check that it says what the text says
# Mill, on the subordination of women: its isolation in modern institutions raises a presumption against it.
# "should at least suffice" in S3 is read as a claim that the presumption is enough, not as a duty, so no modal logic is used.
atom	isolated	the social subordination of women stands out as an isolated fact in modern social institutions, a solitary breach of what has become their fundamental law
atom	opposed	the nature of the subordination of women is radically opposed to the progressive movement which is the boast of the modern world
atom	analogous_swept	the progressive movement has successively swept away everything else of a character analogous to the subordination of women
atom	presumption_against	there is a prima facie presumption on the unfavourable side, far outweighing any which custom and usage could create on the favourable
atom	balanced	the subordination of women is at least a balanced question, like the choice between republicanism and royalty
P1	S1	isolated	kind empirical
P2	S2	opposed	kind empirical
P3	S2	analogous_swept	kind empirical
P4	S3	isolated ∧ opposed ∧ analogous_swept → presumption_against
C1	S3	presumption_against	from P1 P2 P3 P4
P5	S3	presumption_against → balanced
C	S3	balanced	from C1 P5
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

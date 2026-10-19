# reading 2 of mill-subjection-1.md by claude-opus-5-5
atom	isolated	the social subordination of women stands out an isolated fact in modern social institutions, a solitary breach of their fundamental law, a relic of an old world exploded in everything else
atom	opposed_progress	the nature of women's subordination is radically opposed to the progressive movement of the modern world, which has swept away everything else of an analogous character
atom	discrepancy_matter	the discrepancy between this social fact and all those which accompany it affords serious matter for reflection to a conscientious observer
atom	unfavourable_presumption	the discrepancy raises a prima facie presumption on the unfavourable side, outweighing any which custom and usage could create on the favourable
atom	balanced_question	the subordination of women is at least a balanced question, like the choice between republicanism and royalty
P1	S1	isolated	kind empirical
P2	S2	opposed_progress	kind empirical
P3	S2	isolated ∧ opposed_progress → discrepancy_matter
C1	S2	discrepancy_matter	from P1 P2 P3
P4	S3	discrepancy_matter → unfavourable_presumption
C2	S3	unfavourable_presumption	from C1 P4
P5	S3	unfavourable_presumption → balanced_question
# "should at least suffice" read as a plain conditional: the presumption suffices to make it a balanced question
C	S3	balanced_question	from C2 P5
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

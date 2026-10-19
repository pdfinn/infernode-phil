# reading 2 of sidgwick-methods-2.md by claude-opus-5-5
atom	no_distinguish	the common estimate of different sources of happiness does not distinguish between objects of natural desire and sources of experienced pleasure
atom	confusion	the common estimate of different sources of happiness involves the confusion of ideas and points of view which the empirical method of Hedonism takes pains to eliminate
atom	not_coincident	objects of natural desire and sources of experienced pleasure are not exactly coincident
atom	indulge_painful	there are numerous examples of men who continue to feel and indulge desires whose gratification they know by ample experience to be attended with more pain than pleasure
atom	think_desirable	men are apt to think desirable what they strongly desire, whether or not they have found it conducive to happiness on the whole
atom	compromise	the common opinion tends to represent a compromise between the average force of desires and the average experience of the consequences of gratifying them
atom	expresses_experience	the current estimate of the desirability of objects of pursuit can be taken to express simply men's experience of pleasure and pain
P1	S3	confusion
P2	S4	no_distinguish
P3	S5	indulge_painful	kind empirical
P4	S5	indulge_painful → not_coincident
C1	S5	not_coincident	from P3 P4
P5	S6	think_desirable	kind empirical
P6	S6	think_desirable → compromise
C2	S6	compromise	from P5 P6
# S6's "therefore" draws on S4-S5: an estimate that fails to separate desire from experienced pleasure, when the two diverge and the opinion is a compromise, cannot express experience alone
P7	S6	no_distinguish ∧ not_coincident ∧ compromise → ¬expresses_experience
C	S6	¬expresses_experience	from P2 C1 C2 P7
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

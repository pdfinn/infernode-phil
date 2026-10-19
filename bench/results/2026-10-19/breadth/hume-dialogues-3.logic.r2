# reading 2 of hume-dialogues-3.md by claude-opus-5-5
# Philo's reductio of Cleanthes' principles: they make Scepticism, Polytheism and Theism equal, which Cleanthes cannot accept.
atom	principles	Cleanthes' principles hold
atom	pagan_no_gain	nothing is gained by the hypothesis that the deities arose from the unknown powers of nature, since it is as easy to suppose men and animals sprung immediately from a like origin
atom	society_explicable	a numerous society of deities is as explicable as one universal deity possessing the powers and perfections of the whole society
atom	like_footing	Scepticism, Polytheism and Theism are on a like footing, no one having any advantage over the others
# S1: the objection Cleanthes "would naturally" make, read as following from his principles.
P1	S1	principles → pagan_no_gain
# S2: "push the same inference a step further", the same principles carried on.
P2	S2	principles → society_explicable
# The "then" of S3 relies on the two results together giving the like footing; unstated.
A1	-	pagan_no_gain ∧ society_explicable → like_footing
C1	S3	principles → like_footing	from P1 P2 A1
# The reductio relies, unstated, on the like footing being unacceptable: Theism has some advantage.
A2	-	¬like_footing
C	S4	¬principles	from C1 A2
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

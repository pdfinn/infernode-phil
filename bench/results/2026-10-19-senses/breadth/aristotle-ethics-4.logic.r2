# reading 3 of aristotle-ethics-4.md by claude-opus-5-5
logic	kd
atom	honour_elders	we render to our elders the honour befitting their age
atom	frank_companions	we give our companions or brothers frankness and free participation in all we have
atom	render_due	we constantly try to render their due to those of the same family, tribe or city and all similarly connected with us
atom	discriminate	we discriminate, and observe the distinctions as to, what belongs to each in respect of nearness of connection, goodness or intimacy
atom	diff_class_harder	discriminating between those in different classes is a matter of more trouble than between those of the same class
atom	give_up	we give up the attempt to discriminate what belongs to each
# S1 continues an implicit "we should render", read as obligation
P1	S1	O honour_elders ∧ O frank_companions	kind normative
P2	S2	O render_due ∧ O discriminate	kind normative
P3	S2	diff_class_harder	kind empirical
# S3: the greater trouble is not a reason for giving up; we must still observe the distinctions
P4	S3	diff_class_harder → ¬O give_up	kind normative
C	S3	O discriminate ∧ ¬O give_up	from P2 P3 P4
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

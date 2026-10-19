# reading 3 of james-will-4.md by claude-opus-5-5
atom	weather_work	as a weather bureau accumulating reports of phenomena such as apparitions, the S. P. R. has done an immense amount of work
atom	exp_fulfilled	as an experimenting body, the S. P. R. has completely fulfilled the hopes of its founders
atom	subjects_few	the clairvoyant and other subjects who will allow themselves to be experimented upon are few and far between
atom	work_time	work with such subjects takes an immense amount of time and has had to be carried on at odd intervals by members engaged in other pursuits
atom	not_rich	the Society has not yet been rich enough to control the undivided services of skilled experimenters
atom	gurney_loss	the loss of Edmund Gurney, who more than anyone had leisure to devote, has been so far irreparable
atom	records_fallible	the records of the facts cited in the literature of the supernatural are so fallible and imperfect that at most they suggest keeping a window open on that quarter
atom	lit_worthless	the existing literature of the supernatural is practically worthless for evidential purposes
atom	indispensable	the S. P. R.'s function, even as nothing but a weather bureau catching sporadic apparitions in their freshness, is indispensable in the scientific organism
P1	S1	weather_work	kind empirical
P2	S2	¬exp_fulfilled	kind empirical
P3	S3	subjects_few ∧ work_time	kind empirical
A1	-	subjects_few ∧ work_time → ¬exp_fulfilled
P4	S4	not_rich	kind empirical
P5	S5	gurney_loss	kind empirical
P6	S9	records_fallible	kind empirical
A2	-	records_fallible → lit_worthless
C1	S8	lit_worthless	from P6 A2
# The link from the worthless literature to the indispensability of a weather bureau that catches reports fresh is left implicit (S7 "he will know what I mean").
A3	-	lit_worthless ∧ weather_work → indispensable
C	S6	indispensable	from C1 P1 A3
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

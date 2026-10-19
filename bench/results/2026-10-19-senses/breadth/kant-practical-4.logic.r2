# reading 3 of kant-practical-4.md by claude-opus-5-5
# "must" in S2/S3 is read as normative, but the requirement is folded into plain implications rather than written with ought.
atom	beautiful	it is a very beautiful thing to do good to men from love and sympathetic good will, or to be just from love of order
atom	above_duty	we pretend with fanciful pride to set ourselves above the thought of duty, as if independent of the command, doing of our own good pleasure what we think needs no command
atom	true_maxim	our conduct follows the true moral maxim suitable to our position amongst rational beings as men
atom	under_discipline	we stand under a discipline of reason
atom	ground_in_law	in all our maxims the determining principle of our will is set nowhere but in the law itself and in respect for it
atom	ground_elsewhere	the determining principle of our will is set somewhere else than in the law and respect for it, even though the law be conformed to
atom	only_duty	duty and obligation are the only names that we must give to our relation to the moral law
atom	legislative	we are legislative members of a moral kingdom rendered possible by freedom
atom	subjects	we are subjects in the moral kingdom, not the sovereign
atom	revolt	presumptuously rejecting the authority of the moral law is already to revolt from it in spirit, even though its letter is fulfilled
P1	S1	beautiful	kind normative
P2	S1	above_duty → ¬true_maxim	kind normative
P3	S2	under_discipline
P4	S2	under_discipline → ground_in_law	kind normative
P5	S2	ground_elsewhere → ¬ground_in_law	kind conceptual
C1	S2	¬ground_elsewhere	from P3 P4 P5
P6	S4	legislative ∧ subjects
P7	S4	subjects → revolt
# The link from grounding in the law and being subjects to duty being our only relation is relied on but never stated.
A1	-	ground_in_law ∧ subjects → only_duty
C	S3	only_duty	from P3 P4 P6 A1
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

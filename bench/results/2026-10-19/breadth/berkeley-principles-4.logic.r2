# reading 3 of berkeley-principles-4.md by claude-opus-5-5
# S2 is introduced "For example", but S3 draws its conclusion from it, so S2 is kept as premises.
# S4's "may be cleared" is read as a plain conditional (if philosophers consider their own meaning, the errors are cleared), not as a modal.
atom	borrowed_terms	men are used to speak of the nature and operations of the mind in terms borrowed from sensible ideas
atom	controversies	men are engaged in controversies and mistakes with regard to the nature and operations of the mind
atom	will_termed_motion	the will is termed the motion of the soul
atom	belief_ball	it is believed that the mind of man is as a ball in motion, impelled and determined by the objects of sense as necessarily as a ball by the stroke of a racket
atom	moral_errors	endless scruples and errors of dangerous consequence in morality arise
atom	consider_meaning	philosophers retire into themselves and attentively consider their own meaning
atom	errors_cleared	all these errors are cleared and truth appears plain, uniform and consistent
P1	S1	borrowed_terms → controversies
P2	S1	borrowed_terms	kind empirical
P3	S2	will_termed_motion	kind empirical
P4	S2	will_termed_motion → belief_ball
A1	-	belief_ball → moral_errors
C	S3	moral_errors	from P3 P4 A1
P5	S4	consider_meaning → errors_cleared
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

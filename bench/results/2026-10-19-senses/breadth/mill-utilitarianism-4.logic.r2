# reading 2 of mill-utilitarianism-4.md by claude-opus-5-5
atom	distinction_real	the difference between the Just and the Expedient is a real, not merely imaginary, distinction
atom	delusion	mankind have been under a delusion in thinking that justice is a more sacred thing than policy
atom	exposition_recognises	the exposition given of the nature and origin of the sentiment of justice recognises a real distinction
atom	justice_essentials	the moral rules called justice concern the essentials of human well-being more nearly than any other rules for the guidance of life
atom	more_obligation	the moral rules called justice are of more absolute obligation than any other rules for the guidance of life
atom	right_notion	the notion of a right residing in an individual is of the essence of the idea of justice
atom	justice_most_sacred	justice grounded on utility is the chief, and incomparably the most sacred and binding, part of all morality
P1	S4	exposition_recognises
A1	-	exposition_recognises → distinction_real
P2	S6	justice_essentials
P3	S6	justice_essentials → more_obligation
P4	S6	right_notion → more_obligation
P5	S6	right_notion
C1	S6	more_obligation	from P2 P3
A2	-	more_obligation → justice_most_sacred
C2	S5	justice_most_sacred	from C1 A2
A3	-	justice_most_sacred → ¬delusion
C	S3	distinction_real ∧ ¬delusion	from P1 A1 C2 A3
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

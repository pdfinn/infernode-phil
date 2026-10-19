# reading 2 of aquinas-st-i-ii-2.md by claude-opus-5-5
atom	about_operations	justice is a moral virtue about operations, not about the passions
atom	without_passions	justice can be without passions
atom	applies_will	justice applies the will to its proper act, which is not a passion
atom	joy_results	joy results from the act of justice, in the will
atom	joy_is_passion	the joy that results from the act of justice in the will is a passion
atom	lower_follow_higher	the lower powers follow the movement of the higher
atom	perfected	the joy is increased through the perfection of justice
atom	overflow	the joy overflows into the sensitive appetite
atom	more_passion	the more perfect the virtue is, the more it causes passion
P1	S1	about_operations → without_passions
P2	S2	applies_will
P3	S2	applies_will → about_operations
C1	S2	without_passions	from P1 P2 P3
P4	S3	joy_results ∧ ¬joy_is_passion
P5	S4	lower_follow_higher
P6	S4	perfected ∧ lower_follow_higher → overflow
A1	-	perfected
C2	S4	overflow	from P5 P6 A1
P7	S5	overflow → more_passion
C	S5	more_passion	from C2 P7
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

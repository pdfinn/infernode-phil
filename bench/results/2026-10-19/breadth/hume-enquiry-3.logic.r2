# the argument of hume-enquiry-3.md as claude-opus-5-5 read it: check that it says what the text says
logic	s5
atom	assured_no_stab	I rest assured that my honest and opulent friend is not to stab me in my house to rob me of my silver standish
atom	assured_house	I rest assured that my new, solidly built and founded house will not fall
atom	equal_stab_house	I no more suspect the stabbing than the falling of the house itself
atom	frenzy	he has been seized with a sudden and unknown frenzy
atom	earthquake	a sudden earthquake arises and tumbles my house about my ears
atom	certain_no_fire	I know with certainty that he is not to put his hand into the fire and hold it there till it be consumed
atom	equal_fire_fall	I can foretell the hand-in-fire event with the same assurance as that a man who throws himself out of the window will not remain suspended in the air
atom	contrary_principles	putting his hand into the fire till it be consumed is contrary to all the known principles of human nature
atom	fire_event	he puts his hand into the fire and holds it there till it be consumed
atom	moral_certainty	inferences about the conduct of mankind are attended with certainty proportioned to our experience of the usual conduct of mankind, as with inferences about physical events
P1	S1	assured_no_stab ∧ assured_house ∧ equal_stab_house	kind empirical
O1	S1	◇frenzy	against P1
R1	S1	◇earthquake ∧ assured_house	against O1
P2	S3	certain_no_fire ∧ equal_fire_fall	kind empirical
P3	S4	contrary_principles	kind empirical
P4	S4	contrary_principles → ¬◇fire_event
C1	S4	¬◇fire_event	from P3 P4
# the step from the single hand-in-fire case to inferences about human conduct generally is left implicit; S5 is an illustration
A1	-	certain_no_fire ∧ equal_fire_fall ∧ ¬◇fire_event → moral_certainty
C	S6	moral_certainty	from P2 C1 A1
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

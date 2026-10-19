# the argument of mill-utilitarianism-1.md as claude-opus-5-5 read it: check that it says what the text says
logic	s5kd
atom	do_without	one does without happiness
atom	done_involuntarily	nineteen-twentieths of mankind do without happiness involuntarily
atom	sacrifice_for_end	the hero's or martyr's self-sacrifice is for some end beyond itself
atom	end_happiness	the end of the self-sacrifice is the happiness of others, or some of the requisites of happiness
atom	end_virtue	the end of the self-sacrifice is virtue, which is better than happiness
atom	believes_benefit	the hero or martyr believes his sacrifice will earn for others immunity from similar sacrifices
atom	sacrifice_made	the sacrifice would be made
atom	increases_happiness	the renunciation contributes worthily to increase the amount of happiness in the world
atom	admirable	the one who renounces the personal enjoyment of life is deserving of admiration
atom	renounce	one abnegates for oneself the personal enjoyment of life
# S2: "possible" is read as what can be, shown by its being done; "should" in S7 is read as moral obligation.
P1	S2	done_involuntarily	kind empirical
P2	S2	done_involuntarily → do_without
P3	S2	do_without → ◇do_without
C1	S2	◇do_without	from P1 P2 P3
P4	S4	sacrifice_for_end
P5	S3	sacrifice_for_end → end_happiness
C2	S3	end_happiness	from P4 P5
O1	S4	end_virtue ∧ ¬end_happiness	against P5
# S4-S5: rhetorical questions read as asserting the sacrifice would not be made without the belief that it benefits others.
R1	S4	sacrifice_made → believes_benefit	against O1
P6	S6	increases_happiness → admirable	kind normative
P7	S6	¬increases_happiness → ¬admirable	kind normative
P8	S7	◇renounce
A1	-	O renounce → admirable
C	S7	¬increases_happiness → ◇renounce ∧ ¬O renounce	from P7 P8 A1
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

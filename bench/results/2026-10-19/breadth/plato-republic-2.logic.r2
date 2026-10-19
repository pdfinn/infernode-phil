# reading 2 of plato-republic-2.md by claude-opus-5-5
logic	kd
atom	enquire	we enquire who are the best guardians of their own conviction that what they think the interest of the State is to be the rule of their lives
atom	test	we watch them from their youth upwards and make them perform actions in which they are most likely to forget or to be deceived
atom	passes	he remembers and is not deceived in the trial
atom	select	he is selected
atom	reject	he is rejected
# S1's "Therefore" points back to earlier reasoning not given here; S1 is taken as the premise and S2's testing as what follows from it.
# S3 is a question ("That will be the way?") and is left out; it suggests testing is the way to enquire, read as assumption A1.
P1	S1	O enquire	kind normative
P2	S2	passes → O select	kind normative
P3	S2	¬passes → O reject	kind normative
A1	-	O(enquire → test)
C	S2	O test	from P1 A1
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

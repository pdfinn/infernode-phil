# the argument of critic.md as claude-opus-5-5 read it: check that it says what the text says
# S2 "trust needs no sovereign" read as: it is not the case that trust requires a sovereign
# S3 "must be elected" is taken as a plain report of Hobbes's claim; nothing is drawn from it, so no modal logic is used
# S6 "the argument's conclusion" is taken to be Hobbes's conclusion in S1
# promises_kept (S4) and industry (S5) are distinct claims from trust (S1)
atom	sovereign	there is a sovereign
atom	trust	people can trust one another
atom	sovereign_elected	the sovereign is elected
atom	promises_kept	people keep their promises
atom	industry	there is industry
P1	S1	¬sovereign → ¬trust	says hobbes
P2	S2	¬(trust → sovereign)	says hobbes
P3	S3	sovereign_elected	says hobbes
O1	S4	¬sovereign → promises_kept	against P1
P4	S5	¬sovereign → industry	kind empirical
C	S6	¬(¬sovereign → ¬trust)	from P4
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

# the argument of critic.md as claude-opus-5-5 read it: check that it says what the text says
# Atoms: "sovereign" = there is a sovereign; trust/promises/industry describe people living under or without one.
atom	sovereign	there is a sovereign
atom	trust	people can trust one another
atom	keep_promises	people keep their promises
atom	industry	there is industry
atom	elected	the sovereign is elected
# S3's "must be elected" is taken as Hobbes's plain claim that the sovereign is elected; a deontic reading (ought elected) is possible.
P1	S1	¬sovereign → ¬trust	says hobbes
# S2: "trust needs no sovereign" read as: it is not the case that trust requires a sovereign.
P2	S2	¬(trust → sovereign)	says hobbes
P3	S3	elected	says hobbes
O1	S4	¬sovereign → keep_promises	against P1
P4	S5	¬sovereign → industry	kind empirical
# S6: "the argument's conclusion" taken to be Hobbes's claim in S1 that without a sovereign there is no trust.
C	S6	¬(¬sovereign → ¬trust)	from P4
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

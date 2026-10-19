# the argument of trust.md as claude-opus-5-5 read it: check that it says what the text says
atom	sovereign	there is a sovereign
atom	life_short	the life of man is short
atom	trust	people can trust one another
atom	plans	someone plans for the future
P1	S1	¬sovereign → life_short	says hobbes
P2	S2	¬sovereign → ¬trust
P3	S3	¬trust → ¬plans
C	S4	¬sovereign → ¬plans	from P2 P3
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

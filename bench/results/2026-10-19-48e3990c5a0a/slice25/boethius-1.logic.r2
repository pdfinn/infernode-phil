# the argument of boethius-1.md as claude-opus-5-5 read it: check that it says what the text says
# Boethius, Consolation of Philosophy: servants and other possessions are not really one's own
atom	servants_happy	a long train of servants makes thee happy
atom	vicious	the servants behave viciously
atom	honest	the servants are honest
atom	burden	the servants are a ruinous burden to thy house and exceeding dangerous to their master
atom	virtue_others	what the servants have of worth is other men's virtue
atom	servants_thine	the servants are really thine, to be counted in the sum of thy possessions
atom	all_thine	the things thou reckonest in the number of thy possessions are really thine
atom	beautiful	these things are beautiful in their own nature
atom	grieve_joy	thou hast reason to grieve for their loss or find joy in their continued possession
atom	beauty_thine	their beauty is anything to thee
atom	pleasing_without	they would have been not less pleasing in themselves though never included among thy possessions
atom	precious_from_counted	they derive their preciousness from being counted in thy riches
A1	-	vicious ∨ honest
P1	S2	vicious → burden
A2	-	burden → ¬servants_thine
P2	S2	honest → virtue_others
P3	S2	virtue_others → ¬servants_thine
C1	S2	¬servants_thine	from A1 P1 A2 P2 P3
A3	-	all_thine → servants_thine
C	S3	¬all_thine	from C1 A3
P4	S4	¬beautiful → ¬grieve_joy
P5	S6	pleasing_without
P6	S7	¬precious_from_counted
A4	-	pleasing_without ∧ ¬precious_from_counted → ¬beauty_thine
C2	S5	beautiful → ¬beauty_thine	from P5 P6 A4
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

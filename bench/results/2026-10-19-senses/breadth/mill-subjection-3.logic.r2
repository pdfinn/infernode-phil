# reading 2 of mill-subjection-3.md by claude-opus-5-5
# S4 is phrased as a "relevant question"; I read it as implying a negative answer drawn from S2-S3.
# S7 and S8 illustrate S6 (Sappho, Myrtis, Corinna, Aspasia), so they are left out.
atom	short_time	it is scarcely three generations since women have begun to try their capacity in philosophy, science, or art
atom	few_attempts	only in the present generation have women's attempts been at all numerous, and they are even now extremely few
atom	eminence_expected	a mind with the requisites of first-rate eminence could have been expected, on the calculation of chances, to turn up among such women in that time
atom	done_as_expected	in all but the very highest grades women have done quite as much as could be expected from the length of time and the number of competitors
atom	early_success	some of the few women in the earlier period made the attempt with distinguished success
atom	sufficient_grounds	experience has afforded sufficient grounds for an induction
P1	S2	short_time	kind empirical
P2	S3	few_attempts	kind empirical
A1	-	short_time ∧ few_attempts → ¬eminence_expected
C1	S4	¬eminence_expected	from P1 P2 A1
P3	S5	done_as_expected	kind empirical
P4	S6	early_success	kind empirical
A2	-	¬eminence_expected ∧ done_as_expected ∧ early_success → ¬sufficient_grounds
C	S1	¬sufficient_grounds	from C1 P3 P4 A2
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

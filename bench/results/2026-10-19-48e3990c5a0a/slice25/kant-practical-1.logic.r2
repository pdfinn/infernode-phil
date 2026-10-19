# the argument of kant-practical-1.md as claude-opus-5-5 read it: check that it says what the text says
# The atom antinomy is the mathematical proof of the infinite divisibility of space, which empiricism cannot admit.
# S2 is a parenthetical gloss. It is recorded as a premise, but nothing is drawn from it.
# S4 is a qualification about Hume. Its premises stand apart from the main chain.
atom	antinomy	in the antinomy, mathematics proves the infinite divisibility of space, which empiricism cannot admit
atom	contra	this science (mathematics) is in contradiction with a reason that admits only empirical principles
atom	demo_vs_exp	the greatest possible evidence of demonstration is in manifest contradiction with the alleged conclusions from experience
atom	driven_ask	we are driven to ask, like Cheselden's blind patient, which deceives me, sight or touch
atom	felt_seen	empiricism is based on a necessity felt, rationalism on a necessity seen
atom	univ_sceptic	universal empiricism reveals itself as absolute scepticism
atom	hume_absolute	absolute scepticism is rightly attributed in an unqualified sense to Hume
atom	hume_touchstone	Hume left at least one certain touchstone, which can only be found in a priori principles
atom	exp_judgements	experience consists not only of feelings but also of judgements
P1	S1	antinomy → contra
P2	S1	antinomy
P3	S1	contra → demo_vs_exp ∧ driven_ask
P4	S2	felt_seen	kind conceptual
C1	S1	demo_vs_exp ∧ driven_ask	from P1 P2 P3
A1	-	demo_vs_exp ∧ driven_ask → univ_sceptic
C	S3	univ_sceptic	from C1 A1
P5	S4	hume_touchstone → ¬hume_absolute
P6	S4	hume_touchstone	kind empirical
P7	S4	exp_judgements
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

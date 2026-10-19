# the argument of kant-practical-1.md as claude-opus-5-5 read it: check that it says what the text says
atom	math_proves_divisibility	mathematics proves the infinite divisibility of space
atom	emp_cannot_admit	empiricism cannot admit the infinite divisibility of space
atom	math_contra_emp	this science (mathematics) is in contradiction with a reason that admits only empirical principles
atom	demo_contra_exp	the greatest possible evidence of demonstration is in manifest contradiction with the alleged conclusions from experience
atom	doubt_senses	we are driven to ask, like Cheselden's blind patient, "Which deceives me, sight or touch?"
atom	emp_felt	empiricism is based on a necessity felt
atom	rat_seen	rationalism is based on a necessity seen
atom	univ_emp_sceptic	universal empiricism reveals itself as absolute scepticism
atom	hume_touchstone	Hume left at least one certain touchstone, which can only be found in a priori principles
atom	hume_absolute_sceptic	absolute scepticism is to be attributed in an unqualified sense to Hume
P1	S1	math_proves_divisibility ∧ emp_cannot_admit → math_contra_emp
P2	S1	math_proves_divisibility	kind conceptual
P3	S1	emp_cannot_admit	kind conceptual
P4	S1	math_contra_emp → demo_contra_exp ∧ doubt_senses
C1	S1	demo_contra_exp ∧ doubt_senses	from P1 P2 P3 P4
P5	S2	emp_felt ∧ rat_seen	kind conceptual
# "And thus" needs the step from being driven to doubt the senses to scepticism; the text never states it.
A1	-	demo_contra_exp ∧ doubt_senses → univ_emp_sceptic
C	S3	univ_emp_sceptic	from C1 A1
# S4 qualifies how the conclusion applies to Hume; it is not drawn from the main argument.
P6	S4	hume_touchstone	kind empirical
P7	S4	hume_touchstone → ¬hume_absolute_sceptic
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

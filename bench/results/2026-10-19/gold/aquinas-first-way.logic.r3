# reading 3 of aquinas-first-way.md by claude-opus-5-5
logic	s5
atom	some_motion	in the world some things are in motion
atom	moved_potential	whatever is in motion is in potentiality to that towards which it is in motion
atom	mover_actual	a thing moves inasmuch as it is in act
atom	motion_is_actualization	motion is nothing else than the reduction of something from potentiality to actuality
atom	actualization_needs_actual	nothing can be reduced from potentiality to actuality except by something in a state of actuality
atom	same_act_pot	the same thing is at once in actuality and potentiality in the same respect
atom	self_motion	a thing is both mover and moved in the same respect, i.e. moves itself
atom	moved_by_another	whatever is in motion is put in motion by another
atom	infinite_regress	the series of movers put in motion by another goes on to infinity
atom	first_mover	there is a first mover, put in motion by no other
atom	other_movers	there are subsequent (other) movers
atom	god	the first mover is God
P1	S2	some_motion	kind empirical
P2	S3	moved_potential ∧ mover_actual
P3	S4	motion_is_actualization	kind conceptual
P4	S5	actualization_needs_actual
P5	S7	¬◇same_act_pot
# S9 rests on the claim, implicit in S3, that a self-mover would be in act and potency in the same respect
A1	-	moved_potential ∧ mover_actual → □(self_motion → same_act_pot)
C1	S9	¬◇self_motion	from P2 A1 P5
A2	-	motion_is_actualization ∧ actualization_needs_actual ∧ ¬◇self_motion → moved_by_another
C2	S10	moved_by_another	from P3 P4 C1 A2
P6	S12	infinite_regress → ¬first_mover
P7	S12	¬first_mover → ¬other_movers
A3	-	some_motion ∧ moved_by_another → other_movers
C3	S12	¬infinite_regress	from P1 C2 A3 P6 P7
A4	-	moved_by_another ∧ ¬infinite_regress → first_mover
P8	S13	first_mover → god
C	S13	first_mover ∧ god	from C2 C3 A4 P8
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

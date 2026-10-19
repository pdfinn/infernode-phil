# reading 3 of kant-practical-3.md by claude-opus-5-5
logic	s5
atom	cf_determine_will	the categories of freedom refer to the determination of a free elective will
atom	cf_founded_pure_law	the will they determine has as its foundation a pure practical a priori law
atom	tc_founded_pure_law	theoretic concepts have as their foundation a pure practical a priori law
atom	tc_mere_forms	the theoretic categories are only forms of thought which designate objects in an indefinite manner by means of universal concepts of every possible intuition
atom	cf_founded_pure_will	the categories of freedom have as their foundation the form of a pure will, which is given in reason itself
atom	cf_advantage	the categories of freedom have an obvious advantage over the theoretic categories
atom	precepts_will_only	all precepts of pure practical reason have to do only with the determination of the will, not with the physical conditions of executing one's purpose
atom	produce_reality	the practical a priori principles themselves produce the reality of that to which they refer (the intention of the will)
atom	tc_produce_reality	theoretical concepts produce the reality of that to which they refer
atom	cognitions_without_intuition	the practical a priori principles are at once cognitions and need not wait for intuitions to acquire significance
atom	only_practical	these categories apply only to the practical reason
atom	ordered	the categories proceed in order from those subject to sensible conditions and morally indeterminate to those free from sensible conditions and determined merely by the moral law
P1	S1	tc_mere_forms	kind conceptual
P2	S1	cf_determine_will	kind conceptual
P3	S1	cf_founded_pure_law
P4	S1	¬tc_founded_pure_law
P5	S1	cf_determine_will ∧ cf_founded_pure_law → cf_founded_pure_will
C1	S1	cf_founded_pure_will	from P2 P3 P5
A1	-	tc_mere_forms ∧ cf_founded_pure_will → cf_advantage
C2	S1	cf_advantage	from P1 C1 A1
P6	S2	precepts_will_only
P7	S2	produce_reality
P8	S2	¬tc_produce_reality
P9	S2	precepts_will_only ∧ produce_reality → cognitions_without_intuition
C	S2	cognitions_without_intuition	from P6 P7 P9
P10	S3	only_practical
P11	S3	ordered
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

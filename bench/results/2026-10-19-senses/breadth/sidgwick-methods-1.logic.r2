# reading 2 of sidgwick-methods-1.md by claude-opus-5-5
atom	phases_not_distinct	the three phases are not sharply distinguished in the moral reasoning of ordinary men
atom	intuitionism_not_distinct	Intuitionism of any sort is not sharply distinguished from either species of Hedonism in the moral reasoning of ordinary men
atom	confusion_common	a loose combination or confusion of methods is the most common type of actual moral reasoning
atom	believe_sense	most moral men believe that their moral sense or instinct will guide them fairly right
atom	believe_rules	most moral men believe that there are general rules for determining right action in different departments of conduct
atom	believe_deducible	most moral men believe that a philosophical explanation can be found by which these rules may be deduced from a smaller number of fundamental principles
atom	systematic	conduct is to receive systematic direction
atom	need_ultimate	we require to know on what judgments we are to rely as ultimately valid
P1	S1	phases_not_distinct ∧ intuitionism_not_distinct	kind empirical
P2	S2	confusion_common	kind empirical
P3	S3	believe_sense ∧ believe_rules ∧ believe_deducible	kind empirical
# "Still" marks a contrast with the mixed practice; S4 states the requirement for systematic direction
P4	S4	systematic → need_ultimate
A1	-	systematic
C	S4	need_ultimate
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

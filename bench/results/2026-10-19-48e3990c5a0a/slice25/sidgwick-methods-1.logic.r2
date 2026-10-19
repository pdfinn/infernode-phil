# the argument of sidgwick-methods-1.md as claude-opus-5-5 read it: check that it says what the text says
# Sidgwick: ordinary moral reasoning mixes methods, yet systematic direction requires knowing the ultimately valid judgments.
# The text gives no explicit step from S1-S3 to S4; S4 is taken as the main claim ("Still ...").
atom	phases_not_sharp	these three phases are not sharply distinguished in the moral reasoning of ordinary men
atom	intuit_not_sharp	Intuitionism of any sort is not sharply distinguished from either species of Hedonism
atom	loose_combination	a loose combination or confusion of methods is the most common type of actual moral reasoning
atom	believe_sense	most moral men believe their moral sense or instinct will guide them fairly right
atom	believe_rules	most moral men believe there are general rules for determining right action in different departments of conduct
atom	believe_explanation	most moral men believe a philosophical explanation can be found by which these rules may be deduced from a smaller number of fundamental principles
atom	systematic_direction	we are to have systematic direction of conduct
atom	know_valid	we know on what judgments we are to rely as ultimately valid
# "it is possible to find" in S3 is kept inside the content of the belief, as part of an atom, not written as a modal operator.
P1	S1	phases_not_sharp ∧ intuit_not_sharp
P2	S2	loose_combination	kind empirical
# "Probably most moral men believe" is a hedged report of common belief; the hedge is not formalised.
P3	S3	believe_sense ∧ believe_rules ∧ believe_explanation	kind empirical
# "we require to know" is read as a necessary condition: systematic direction only if we know the ultimately valid judgments.
C	S4	systematic_direction → know_valid
# read by claude-opus-5-5, prompt /lib/phil/argue 48e3990c5a0a, 2026-10-19, blinded by name space

# reading 3 of locke-treatise-2.md by claude-opus-5-5
atom	enters	a man incorporates himself into a commonwealth, entering society with others for the securing and regulating of property
atom	regulated	the property of his land is to be regulated by the laws of the society
atom	exempt	his land is exempt from the jurisdiction of that government, to which he himself, the proprietor, is a subject
atom	land_subject	his possessions are united to the commonwealth and subject to its government and dominion as long as it hath a being
atom	enjoys	someone thenceforth, by inheritance, purchase, permission or otherways, enjoys any part of the land so annexed
atom	submits	whoever enjoys that land takes it on the condition of submitting to the government of the commonwealth under whose jurisdiction it is, as far forth as any subject of it
P1	S3	enters → regulated
P2	S3	¬(enters ∧ regulated ∧ exempt)	kind conceptual
A1	-	¬exempt → land_subject
C1	S4	enters → land_subject	from P1 P2 A1
A2	-	land_subject ∧ enjoys → submits
A3	-	enters
C	S5	enjoys → submits	from C1 A2 A3
# read by claude-opus-5-5, prompt /lib/phil/argue a036b21b8816, 2026-10-19, blinded by name space

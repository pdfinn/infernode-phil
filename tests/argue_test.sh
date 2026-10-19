#!/bin/sh
# tests/argue_test.sh - phil/argue end to end: a real llmsrv whose
# model (tests/fakellm.py) answers with the logic file in
# tests/data/argue/reply, talk and all.  Checks that the file is kept
# without the talk and that phil/prove finds the fallacy in it, at the
# sentence the conclusion came from.  Then a model whose first file
# does not parse (data/argue/replies): it is shown the prover's
# complaint and asked again, and its second file is proved.  Then
# readings compared, and misreadings found by reading them back
# beside the sentences, even when most of the readings share them;
# an argument in steps with an objection; and a writer's own reading
# set beside a cold one (-s).
# Needs python3; ROOT as for tests/run.sh.
here=$(cd "$(dirname "$0")/.." && pwd)
if [ -z "$ROOT" ] || [ ! -f "$ROOT/mkconfig" ]; then
	echo 'tests/argue_test.sh: set ROOT to your InferNode tree' >&2
	exit 1
fi
if ! command -v python3 >/dev/null; then
	echo 'tests/argue_test.sh: SKIP: no python3'
	exit 0
fi
case $(uname -s) in
Darwin)	host=MacOSX;;
*)	host=$(uname -s);;
esac
emu=$ROOT/emu/$host/o.emu
wwb=${WWB:-$(cd "$here/.." && pwd)/infernode-wwb}
if [ ! -f "$wwb/dis/wwb/lib/prose.dis" ]; then
	echo "$0: no built Writer's Workbench at $wwb: set WWB" >&2
	exit 1
fi
tmp=$(mktemp -d)
rm -rf "$here/tests/out/argue.logic.parts"
fake=
trap '[ -n "$fake" ] && kill $fake 2>/dev/null; rm -rf "$tmp"' EXIT
port=$(python3 -I -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1])')
python3 -I "$here/tests/fakellm.py" "$port" "$tmp/requests" "$here/tests/data/argue/reply" &
fake=$!
sleep 1

timeout 120 "$emu" -c1 -r"$ROOT" sh "#U*$here/tests/argue.inferno" "#U*$here" "#U*$wwb" "$port" 2>&1 |
	grep -v '^fs: fsqid' > "$tmp/out"
fail=0
want() {
	if ! grep -qF -- "$1" "$tmp/$3"; then
		echo "FAIL: $2"
		fail=1
	fi
}
dontwant() {
	if grep -qF -- "$1" "$tmp/$3"; then
		echo "FAIL: $2"
		fail=1
	fi
}
want 'You are helping check the reasoning' 'the model is given /lib/phil/argue' requests
want 'S3 line 2: So the server is patched.' 'the model is given the numbered sentences' requests
want '# argument written to out/argue.logic by fake-model' 'the model is named' out
want 'data/argue/sample.md:2: argue/invalid: C (S3)' 'the invalid conclusion is found, at its sentence' out
want 'affirming the consequent' 'the fallacy is named' out
want 'argue/missing: C (S3): it would follow given "secure → patched"' 'the missing premise is given' out
want 'out/argue.logic: argue/valid 0' 'the measure is given' out
want 'P1	S1	patched → secure' 'the logic file is kept' out
dontwant 'I hope this helps' 'what the model says besides the file is dropped' out

# a file the prover cannot read goes back to the model
kill $fake 2>/dev/null
port=$(python3 -I -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1])')
python3 -I "$here/tests/fakellm.py" "$port" "$tmp/requests2" "$here/tests/data/argue/replies" &
fake=$!
sleep 1
timeout 120 "$emu" -c1 -r"$ROOT" sh "#U*$here/tests/argue.inferno" "#U*$here" "#U*$wwb" "$port" 2>&1 |
	grep -v '^fs: fsqid' > "$tmp/out2"
want '# the prover could not read out/argue.logic: fake-model is asked again' 'a file that does not parse is sent back' out2
want 'P1: the formula ends too soon' 'the model is told what is wrong' requests2
want 'Write the whole file again, corrected' 'the model is asked for the whole file again' requests2
want 'affirming the consequent' 'the corrected file is proved' out2
want 'P1	S1	patched → secure' 'the corrected file is kept' out2
dontwant 'argue.logic.answer' 'no working files are left' out2
[ "$(ls "$here/tests/out" | grep -c 'argue.logic.')" = 0 ] || { echo 'FAIL: working files left beside the logic file'; fail=1; }

# three readings: the first misreads S1, the other two agree; the
# model is asked whether S1 holds in a case that tells them apart, and
# its answer keeps the two
kill $fake 2>/dev/null
port=$(python3 -I -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1])')
python3 -I "$here/tests/fakellm.py" "$port" "$tmp/requests3" "$here/tests/data/argue/kreplies" &
fake=$!
sleep 1
timeout 120 "$emu" -c1 -r"$ROOT" sh "#U*$here/tests/argue.inferno" "#U*$here" "#U*$wwb" "$port" -k 3 2>&1 |
	grep -v '^fs: fsqid' > "$tmp/out3"
want '# 3 readings by fake-model, compared' 'the readings are compared' out3
want 'argue/readings: S1 is read 2 ways' 'a sentence read two ways is found' out3
want 'out/argue.logic has "secure → patched"' 'the misreading is named' out3
want 'argue/verdicts: valid as out/argue.logic reads it' 'the verdict turning on the reading is said' out3
want '# kept the reading that best fits the words and the other readings: out/argue.logic.2' 'the agreed reading is kept' out3
want 'Answer the question with yes or no' 'the readings'"'"' difference is put to the model as a question' requests3
want 'Suppose \"the server is patched\" is true and \"the server is secure\" is false. Is S1' 'the question is a situation that tells the readings apart' requests3
want 'argue/answered: S1: answered no, which keeps out/argue.logic.2 and out/argue.logic.3' 'the answer rules a reading out' out3
want 'Use these atoms, and no others' 'later readings are given the first one'"'"'s atoms' requests3
want 'affirming the consequent' 'the kept reading is proved' out3
want 'P1	S1	patched → secure' 'the kept reading is the logic file' out3
[ "$(ls "$here/tests/out" | grep -c 'argue.logic.')" = 0 ] || { echo 'FAIL: working files left after -k'; fail=1; }

# the same, with an answer that reasons first and ends with its no
kill $fake 2>/dev/null
port=$(python3 -I -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1])')
python3 -I "$here/tests/fakellm.py" "$port" "$tmp/requests3b" "$here/tests/data/argue/kreplies3" &
fake=$!
sleep 1
timeout 120 "$emu" -c1 -r"$ROOT" sh "#U*$here/tests/argue.inferno" "#U*$here" "#U*$wwb" "$port" -k 3 2>&1 |
	grep -v '^fs: fsqid' > "$tmp/out3b"
want 'argue/answered: S1: answered no' 'an answer reasoned before its no is read' out3b

# a later reading the prover cannot read is sent back too, not left to
# stop the comparison
kill $fake 2>/dev/null
port=$(python3 -I -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1])')
python3 -I "$here/tests/fakellm.py" "$port" "$tmp/requests3c" "$here/tests/data/argue/kreplies4" &
fake=$!
sleep 1
timeout 120 "$emu" -c1 -r"$ROOT" sh "#U*$here/tests/argue.inferno" "#U*$here" "#U*$wwb" "$port" -k 3 2>&1 |
	grep -v '^fs: fsqid' > "$tmp/out3c"
want '# the prover could not read out/argue.logic.2: fake-model is asked again' 'a later reading that does not parse is sent back' out3c
want '# 3 readings by fake-model, compared' 'and, corrected, compared' out3c
want 'argue/answered: S1: answered no' 'the comparison goes on to its question' out3c
[ "$(ls "$here/tests/out" | grep -c 'argue.logic.')" = 0 ] || { echo 'FAIL: working files left after a reading was mended'; fail=1; }

# a model that misreads S1 the same way however often it is asked:
# reading it back beside the sentence shows it
kill $fake 2>/dev/null
port=$(python3 -I -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1])')
python3 -I "$here/tests/fakellm.py" "$port" "$tmp/requests4" "$here/tests/data/argue/misreply" &
fake=$!
sleep 1
timeout 120 "$emu" -c1 -r"$ROOT" sh "#U*$here/tests/argue.inferno" "#U*$here" "#U*$wwb" "$port" 2>&1 |
	grep -v '^fs: fsqid' > "$tmp/out4"
want 'data/argue/sample.md:1: argue/converse: P1 (S1)' 'a condition turned round is found, at its sentence' out4
want 'it reads "if the server is secure, then the server is patched"' 'the statement is read back' out4
want 'out/argue.logic: argue/valid 1' 'the misreading makes the argument valid, which is why it matters' out4

# three readings, two of them misreading S1 alike and one right, no
# questions asked (-q): the words, not the majority, decide
kill $fake 2>/dev/null
port=$(python3 -I -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1])')
python3 -I "$here/tests/fakellm.py" "$port" "$tmp/requests5" "$here/tests/data/argue/kreplies2" &
fake=$!
sleep 1
timeout 120 "$emu" -c1 -r"$ROOT" sh "#U*$here/tests/argue.inferno" "#U*$here" "#U*$wwb" "$port" -k 3 -q 2>&1 |
	grep -v '^fs: fsqid' > "$tmp/out5"
want 'out/argue.logic.2: argue/mismatches 1' 'the misreadings are counted' out5
want 'out/argue.logic: argue/mismatches 0' 'the right reading has none' out5
want '# kept the reading that best fits the words and the other readings: out/argue.logic' 'the right reading is kept though outvoted' out5
want 'affirming the consequent' 'the kept reading is proved' out5
dontwant 'Answer the question with yes or no' 'with -q no question is put to the model' requests5
[ "$(ls "$here/tests/out" | grep -c 'argue.logic.')" = 0 ] || { echo 'FAIL: working files left after -k -q'; fail=1; }

# an argument in steps, with an objection the text leaves unanswered:
# the lines are kept, each step is checked, and the conclusion falls
kill $fake 2>/dev/null
port=$(python3 -I -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1])')
python3 -I "$here/tests/fakellm.py" "$port" "$tmp/requests6" "$here/tests/data/argue/structreply" &
fake=$!
sleep 1
timeout 120 "$emu" -c1 -r"$ROOT" sh "#U*$here/tests/argue.inferno" "#U*$here" "#U*$wwb" "$port" -d data/argue/structured.md 2>&1 |
	grep -v '^fs: fsqid' > "$tmp/out6"
want 'from C1 P3' 'a step is kept' out6
want 'against P1' 'an objection is kept' out6
want 'argue/defeated: P1 (S1): P1 falls to O1, which nothing answers' 'the unanswered objection defeats its premise' out6
want 'argue/defeated: C (S5): C falls with C1' 'and the conclusion falls with the step' out6
want 'argue/survives 0' 'the measure says so' out6
want 'write each as C1, C2' 'the model is told how to write steps' requests6

# the writer's own reading beside a cold one (-s): where they differ is
# where the prose does not say what the writer meant
kill $fake 2>/dev/null
port=$(python3 -I -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1])')
python3 -I "$here/tests/fakellm.py" "$port" "$tmp/requests7" "$here/tests/data/argue/misreply" &
fake=$!
sleep 1
timeout 120 "$emu" -c1 -r"$ROOT" sh "#U*$here/tests/argue.inferno" "#U*$here" "#U*$wwb" "$port" -s data/argue/mine.logic 2>&1 |
	grep -v '^fs: fsqid' > "$tmp/out7"
want 'Use these atoms, and no others' 'the cold reading is given the writer'"'"'s atoms' requests7
want '# data/argue/mine.logic as its writer meant it, beside out/argue.logic' 'the readings are set side by side' out7
want 'argue/readings: S1 is read 2 ways: data/argue/mine.logic has "patched → secure"; out/argue.logic has "secure → patched"' 'the sentence read otherwise is named' out7
want 'argue/verdicts: valid as out/argue.logic reads it' 'and what turns on it' out7
dontwant '# best reading' 'no reading is chosen between them' out7

# the whole done twice (-n 2), the model reading it otherwise the second
# time: what only one run found is marked, and the runs disagree
kill $fake 2>/dev/null
port=$(python3 -I -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1])')
python3 -I "$here/tests/fakellm.py" "$port" "$tmp/requests9" "$here/tests/data/argue/nreplies" &
fake=$!
sleep 1
timeout 120 "$emu" -c1 -r"$ROOT" sh "#U*$here/tests/argue.inferno" "#U*$here" "#U*$wwb" "$port" -n 2 2>&1 |
	grep -v '^fs: fsqid' > "$tmp/out9"
want '# run 2 of 2' 'the work is done twice' out9
want 'data/argue/sample.md:2: argue/invalid: C (S3)' 'the first run'"'"'s findings are given' out9
want '[in 1 of 2 runs]' 'one only the first run found is marked' out9
want 'out/argue.logic: argue/runs-agree 0' 'the runs'"'"' verdicts differ' out9
want 'P1	S1	patched → secure' 'the first run'"'"'s reading is the logic file' out9
[ -f "$here/tests/out/argue.logic.r2" ] || { echo 'FAIL: the runs are not kept'; fail=1; }
rm -f "$here/tests/out/argue.logic.r"*

# a long work, part by part (-w): a part rests on an earlier one's
# conclusion, a part that argues nothing is passed over, and the main
# conclusion is joined to the parts' steps by a link the work never states
kill $fake 2>/dev/null
port=$(python3 -I -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1])')
python3 -I "$here/tests/fakellm.py" "$port" "$tmp/requests8" "$here/tests/data/argue/workreplies" &
fake=$!
sleep 1
timeout 120 "$emu" -c1 -r"$ROOT" sh "#U*$here/tests/argue.inferno" "#U*$here" "#U*$wwb" "$port" -d data/argue/work.md -w 2>&1 |
	grep -v '^fs: fsqid' > "$tmp/out8"
want '# part 1, S1-S4: Whales' 'the first section is a part' out8
want '# part 2, S5-S7: Breathing' 'the second is another' out8
want '# no argument here' 'a part that argues nothing is passed over' out8
want 'Earlier parts concluded these' 'a later part is shown what earlier parts concluded' requests8
want 'S4\tmammal' 'with the sentence and formula to rest on' requests8
want 'Use these atoms where they fit' 'and the atoms they used' requests8
want 'C2	S7	breathes	from P3 C1' 'the later part rests on the earlier step' out8
want 'What each part concludes, with its sentence' 'the model is asked to join the steps' requests8
want 'S12 line 15: Therefore Moby must come up for air.' 'and shown the work'"'"'s closing sentences' requests8
want '# the work as a whole, 4 parts' 'the whole is proved' out8
want 'argue/assumed: C (S12): follows only by A1' 'the unstated link between parts is found' out8
want 'out/argue.logic: argue/valid 1' 'and the whole holds' out8
dontwant 'argue/invalid' 'no step fails' out8
[ -f "$here/tests/out/argue.logic.parts/part2.logic" ] || { echo 'FAIL: the parts are not kept'; fail=1; }

# the answers split the readings, and the one kept lacks an assumption
# an answer said the text takes for granted: it is added to it
kill $fake 2>/dev/null
port=$(python3 -I -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1])')
python3 -I "$here/tests/fakellm.py" "$port" "$tmp/requests12" "$here/tests/data/argue/affirmreplies" &
fake=$!
sleep 1
timeout 120 "$emu" -c1 -r"$ROOT" sh "#U*$here/tests/argue.inferno" "#U*$here" "#U*$wwb" "$port" -d data/argue/affirm/text.md -k 3 2>&1 |
	grep -v '^fs: fsqid' > "$tmp/out12"
want 'argue/answers-split' 'the answers split the readings' out12
want 'as the answers say the text takes it for granted: wet → cancelled' 'the affirmed assumption is added' out12
want 'A1	-	wet → cancelled' 'to the logic file' out12
want 'C	S3	cancelled	from P1 P2 A1' 'and the conclusion draws on it' out12
want 'out/argue.logic: argue/valid 1' 'so the kept reading is valid, as the answers say' out12

# the joining uses a part's atom in another sense: read back in the
# atom's meaning, the model writes its lines again
kill $fake 2>/dev/null
port=$(python3 -I -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1])')
python3 -I "$here/tests/fakellm.py" "$port" "$tmp/requests11" "$here/tests/data/argue/workmisread" &
fake=$!
sleep 1
rm -rf "$here/tests/out/argue.logic.parts"
timeout 120 "$emu" -c1 -r"$ROOT" sh "#U*$here/tests/argue.inferno" "#U*$here" "#U*$wwb" "$port" -d data/argue/work.md -w 2>&1 |
	grep -v '^fs: fsqid' > "$tmp/out11"
want 'Here are the assumptions you added, read back' 'the joining assumptions are read back to the model' requests11
want 'A1: reads \"if Moby breathes air, then Moby is a whale' 'in the meanings their atoms declare (the log is JSON)' requests11
want 'wrote how the parts are joined again' 'its rewritten lines are taken' out11
want 'A1	-	breathes → surfaces' 'the corrected assumption is the one kept' out11
dontwant 'breathes → whale' 'the misread one is gone' out11

# cut short and carried on (-c): the parts read to the end are kept,
# and only what is left, the last part and the whole, goes to the model
rm -f "$here/tests/out/argue.logic.parts/part4.span"
kill $fake 2>/dev/null
port=$(python3 -I -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1])')
python3 -I "$here/tests/fakellm.py" "$port" "$tmp/requests10" "$here/tests/data/argue/workrest" &
fake=$!
sleep 1
timeout 120 "$emu" -c1 -r"$ROOT" sh "#U*$here/tests/argue.inferno" "#U*$here" "#U*$wwb" "$port" -d data/argue/work.md -w -c 2>&1 |
	grep -v '^fs: fsqid' > "$tmp/out10"
dontwant 'S6 line' 'a part read to the end is not read again' requests10
dontwant 'S9 line' 'nor another' requests10
want 'S11 line' 'a part cut short is read again' requests10
want 'C2	S7	breathes	from P3 C1' 'the parts kept are joined as before' out10
want 'out/argue.logic: argue/valid 1' 'and the whole holds' out10
rm -rf "$here/tests/out/argue.logic.parts"

if [ $fail = 0 ]; then
	echo 'argue: ok'
else
	cat "$tmp/out"
fi
exit $fail

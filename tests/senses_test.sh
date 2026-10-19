#!/bin/sh
# tests/senses_test.sh - phil/senses against a scripted model
# (tests/fakellm.py, data/senses/replies): a claim said to be in two
# senses where the argument turns on it is argue/equivocates, with
# its case; one it does not turn on is argue/two-senses; a claim in
# one sense, and an answer that splits every statement or none, say
# nothing.  Needs python3; ROOT as for tests/run.sh.
here=$(cd "$(dirname "$0")/.." && pwd)
if [ -z "$ROOT" ] || [ ! -f "$ROOT/mkconfig" ]; then
	echo 'tests/senses_test.sh: set ROOT to your InferNode tree' >&2
	exit 1
fi
if ! command -v python3 >/dev/null; then
	echo 'tests/senses_test.sh: SKIP: no python3'
	exit 0
fi
case $(uname -s) in
Darwin)	host=MacOSX;;
*)	host=$(uname -s);;
esac
emu=$ROOT/emu/$host/o.emu
wwb=${WWB:-$(cd "$here/.." && pwd)/infernode-wwb}
tmp=$(mktemp -d)
fake=
trap '[ -n "$fake" ] && kill $fake 2>/dev/null; rm -rf "$tmp"' EXIT
port=$(python3 -I -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1])')
python3 -I "$here/tests/fakellm.py" "$port" "$tmp/requests" "$here/tests/data/senses/replies" &
fake=$!
sleep 1
timeout 120 "$emu" -c1 -r"$ROOT" sh "#U*$here/tests/senses.inferno" "#U*$here" "#U*$wwb" "$port" 2>&1 |
	grep -v '^fs: fsqid' > "$tmp/out"
fail=0
want() {
	if ! grep -qF -- "$1" "$tmp/$3"; then
		echo "FAIL: $2"
		fail=1
	fi
}
count() {
	n=$(sed -n "/^# ask $1\$/,/^# end $1\$/p" "$tmp/out" | grep -c -- "$2")
	if [ "$n" != "$3" ]; then
		echo "FAIL: $4 (ask $1: $n, not $3)"
		fail=1
	fi
}
want 'You are checking whether an argument moves between two senses' 'the model is given /lib/phil/senses' requests
want 'S2 line 2: Death is the end of life.' 'the model is given the numbered sentences' requests
want 'Claim end: x is the end of a thing' 'each shared claim is named, with what it stands for' requests
want 'P2 (S2): \"death is the end of a thing\"' 'each statement that uses it is given in words' requests
count 1 'argue/equivocates: P2 (S2): "end" is taken as the last point of a thing in P2 and as the aim a thing tends to where end is used else' 1 'the shift the argument turns on is found, at its statement'
count 1 'taken apart, C (S4) does not follow (out/senses.logic.sense1)' 1 'the conclusion that fails is named, and the split kept'
count 1 'argue/countermodel: C (S4)' 1 'the case is given'
count 1 '^atom	end_2(x)	the last point of a thing' 1 'the split declares the second sense'
count 1 '^P2	S2	end_2(death)' 1 'the split uses it'
count 1 'argue/two-senses' 0 'a shift the argument turns on is not called harmless'
count 2 'argue/two-senses: P3 (S3): "end" is taken as the last point of a thing in P3' 1 'a shift the argument does not turn on is said'
count 2 'the argument does not turn on it' 1 'and said to be harmless'
count 2 'argue/equivocates' 0 'a harmless shift is not an equivocation'
count 3 'argue/' 0 'claims in one sense say nothing'
count 4 'argue/' 0 'a split of every statement says nothing'
count 5 'argue/' 0 'talk before the answer, and one sense, say nothing'
count 1 'senses.logic.senses' 1 'the answers are kept'
want '# answered by fake-model, prompt /lib/phil/senses ' 'the answers say who answered, by what prompt' out
for i in 1 2 3 4 5; do
	count $i 'senses.logic.(shared|words|ans|split)' 0 'no working files are left'
done
# end to end: phil/argue -e reads the text, then asks about senses
kill $fake 2>/dev/null
port=$(python3 -I -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1])')
python3 -I "$here/tests/fakellm.py" "$port" "$tmp/requests2" "$here/tests/data/senses/argue-replies" &
fake=$!
sleep 1
timeout 120 "$emu" -c1 -r"$ROOT" sh "#U*$here/tests/argue.inferno" "#U*$here" "#U*$wwb" "$port" -d data/senses/end.md -e 2>&1 |
	grep -v '^fs: fsqid' > "$tmp/out2"
want 'out/argue.logic: argue/valid 1' 'the reading is valid as read' out2
want 'out/argue.logic: argue/equivocates: P2 (S2): "end"' 'argue -e finds the shift' out2
want 'You are checking whether an argument moves between two senses' 'argue -e asks about senses' requests2
rm -f "$here/tests/out/argue.logic.senses" "$here/tests/out/argue.logic.sense1"
if [ $fail = 0 ]; then
	echo 'senses: ok'
else
	cat "$tmp/out" "$tmp/out2"
	exit 1
fi

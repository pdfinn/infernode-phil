#!/bin/sh
# tests/claims_test.sh - phil/claims against a scripted model
# (tests/fakellm.py, data/claims/replies): a reading with no conclusion
# is kept, without the model's talk, in logic's symbols, with who read
# it; the model is given /lib/phil/claims and the sentences.  Needs
# python3; ROOT as for tests/run.sh.
here=$(cd "$(dirname "$0")/.." && pwd)
if [ -z "$ROOT" ] || [ ! -f "$ROOT/mkconfig" ]; then
	echo 'tests/claims_test.sh: set ROOT to your InferNode tree' >&2
	exit 1
fi
if ! command -v python3 >/dev/null; then
	echo 'tests/claims_test.sh: SKIP: no python3'
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
python3 -I "$here/tests/fakellm.py" "$port" "$tmp/requests" "$here/tests/data/claims/replies" &
fake=$!
sleep 1
timeout 120 "$emu" -c1 -r"$ROOT" sh "#U*$here/tests/claims.inferno" "#U*$here" "#U*$wwb" "$port" 2>&1 |
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
want 'You are helping read what a document claims' 'the model is given /lib/phil/claims' requests
want 'S2 line 2: Words become general' 'the model is given the numbered sentences' requests
want '# status ' 'it runs' out
dontwant '# status fail' 'a reading with no conclusion is not refused' out
dontwant 'could not read' 'nor sent back' out
want '# the claims of data/claims/source.md as fake-model read them' 'the reading says what it is' out
want 'P1	S1	¬abstract_brutes	kind empirical' 'it is kept in logic'"'"'s symbols' out
want 'P2	S2	words_signs	kind conceptual' 'every claim is kept' out
want '# read model=fake-model temperature=default maxtokens=8192 thinking=off prompt=/lib/phil/claims prompthash=' 'who read it, asked how, by what prompt' out
dontwant 'Here is the file' 'the model'"'"'s talk is dropped' out
[ "$(sed -n '/^# files/,$p' "$tmp/out" | grep -c 'source.claims.')" = 0 ] || { echo 'FAIL: working files left'; fail=1; }
if [ $fail = 0 ]; then
	echo 'claims: ok'
else
	cat "$tmp/out"
	exit 1
fi

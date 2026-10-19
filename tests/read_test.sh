#!/bin/sh
# tests/read_test.sh - phil/read's readers are blinded: a reader that
# is a program inside InferNode, run by read, sees nothing in the
# directory the readings go to, nothing under /n, and cannot attach the
# host's files by a device name, where the same reader run directly sees
# them all.  And: -k gives several readings, each saying who read it,
# with which instructions and when; a reading the prover still cannot
# read after asking again is kept and read fails; a host command is
# said to be one, unconfined, and a reader that is a program inside
# InferNode has no /net.  ROOT as for tests/run.sh; WWB, the
# Writer's Workbench, by default beside this tree.
here=$(cd "$(dirname "$0")/.." && pwd)
if [ -z "$ROOT" ] || [ ! -f "$ROOT/mkconfig" ]; then
	echo 'tests/read_test.sh: set ROOT to your InferNode tree' >&2
	exit 1
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
# the reader, where the emulator's own / can reach it
mkdir -p "$ROOT/tmp"
peek=phil-peek.$$
trap 'rm -f "$ROOT/tmp/$peek"; rm -rf "$tmp"' EXIT
cat > "$ROOT/tmp/$peek" <<'P'
load std
# $1 inside a `{} block is the block's, so name it first
d=$1
cat > /dev/null
for l in `{ls $d >[2=1]} {
	echo '# saw in the readings'' directory:' $l
}
for l in `{ls /n >[2=1]} {
	echo '# saw in /n:' $l
}
for l in `{cat $d/secret >[2=1]} {
	echo '# read the secret:' $l
}
for l in `{ls '#U*/' >[2=1]} {
	echo '# saw the host:' $l
}
for l in `{ls /net >[2=1]} {
	echo '# saw in /net:' $l
}
echo 'atom	p	the server is patched'
echo 'C	S1	p'
P
tmp=$(mktemp -d)
timeout 120 "$emu" -c1 -r"$ROOT" sh "#U*$here/tests/read.inferno" "#U*$here" "#U*$wwb" "/tmp/$peek" 2>&1 |
	grep -v '^fs: fsqid' > "$tmp/out"
fail=0
section() {
	sed -n "/^# $1\$/,/^# [a-z]* [a-z]*,\{0,1\} [a-z]*\$/p" "$tmp/out"
}
sed -n '/^# the reader, unblinded$/,/^# the reader, through phil\/read$/p' "$tmp/out" > "$tmp/open"
sed -n '/^# the reader, through phil\/read$/,/^# the readings under a name, not a device$/p' "$tmp/out" > "$tmp/blind"
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
want "saw in the readings' directory:" 'unblinded, the reader sees the readings'' directory (the control)' open
want 'read the secret: SECRET' 'unblinded, the reader reads a file there (the control)' open
dontwant "out/read/other.logic" 'blinded, the reader lists nothing in the readings'' directory' blind
want "saw in the readings' directory: mount/attach" 'blinded, the readings'' directory is refused it' blind
dontwant 'read the secret: SECRET' 'blinded, the reader cannot read the secret' blind
dontwant 'saw in /n:' 'blinded, the reader sees nothing under /n' blind
want 'saw in /net:' 'unblinded, the reader sees the network (the control)' open
dontwant 'saw in /net:' 'blinded, a reader that is a program sees nothing in /net' blind
want 'saw the host:' 'the reader tries the host by a device name' blind
dontwant 'saw the host: #U*//home' 'blinded, the reader cannot attach the host' blind
grep 'saw the host:' "$tmp/blind" | grep -qv 'saw the host: .*\(no attach\|permission\|refused\|not allowed\|disallowed\|ls:\|stat\|#U\*/:\|mount/attach\)' &&
	{ echo "FAIL: blinded, the host is refused: $(grep 'saw the host' "$tmp/blind")"; fail=1; }
want 'status ' 'read runs' blind
grep -q '^status $' "$tmp/blind" || { echo 'FAIL: a blinded reading succeeds'; fail=1; }
want '# a test' 'the header is the first line' blind
want 'C	S1	p' 'the reading is kept' blind
for i in 1 2 3; do
	want "out/read/three.$i has its provenance" "reading $i of 3 says who read it, with what and when" out
done
sed -n '/^# the readings under a name, not a device$/,/^# through phil\/read, under a name$/p' "$tmp/out" > "$tmp/open2"
sed -n '/^# through phil\/read, under a name$/,/^# three readers$/p' "$tmp/out" > "$tmp/blind2"
want 'other.logic' 'unblinded, a reader sees readings under a plain name (the control)' open2
want 'read the secret: SECRET' 'unblinded, a reader reads the secret under a plain name (the control)' open2
dontwant "saw in the readings' directory: /tmp/phil.readtest" 'blinded, a reader lists nothing in a directory under a plain name' blind2
dontwant 'read the secret: SECRET' 'blinded, a reader cannot read the secret under a plain name' blind2
want 'read the secret: exist' 'blinded, the secret under a plain name does not exist' blind2
sed -n '/^# a reader that never writes/,/^# a host command$/p' "$tmp/out" > "$tmp/bad"
want 'is asked again' 'an unreadable reading goes back to the reader' bad
want 'status fail:unreadable' 'read fails when a reading still cannot be read' bad
want 'the reading is kept' 'the unreadable reading is kept' bad
sed -n '/^# a host command$/,$p' "$tmp/out" > "$tmp/host"
want 'unconfined: a host command, not blinded by name space' 'a host command is said to be unconfined' host
want "(settings the command's own)" 'a host command'"'"'s settings are said to be its own' host
[ $fail = 0 ] && echo 'read: ok'
[ $fail = 0 ] || cat "$tmp/blind"
exit $fail

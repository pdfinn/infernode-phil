#!/bin/sh
# tests/demo_test.sh - demo/guide, worked as a person works it in Xenith:
# the guide opened, "Local run ../philns" executed (button 2), then each
# command in it, its output read from the +Errors window and checked; and
# a finding's address looked at (button 3) opens the file.  The clicks are
# events written to the guide window's event file, which Xenith carries
# out as it would the mouse's.  Every command line of the guide is run,
# so a command added there must be given what to expect here.
#
# Xenith runs under SDL's dummy video driver, so this needs the SDL GUI
# emulator: EMU names it (default $ROOT/emu/<host>/o.emu); it is skipped
# on a headless one.  ROOT as for tests/run.sh.
here=$(cd "$(dirname "$0")/.." && pwd)
if [ -z "$ROOT" ] || [ ! -f "$ROOT/mkconfig" ]; then
	echo 'tests/demo_test.sh: set ROOT to your InferNode tree' >&2
	exit 1
fi
case $(uname -s) in
Darwin)	host=MacOSX;;
*)	host=$(uname -s);;
esac
emu=${EMU:-$ROOT/emu/$host/o.emu}
if ! nm "$emu" 2>/dev/null | grep -q sdl3_mainloop; then
	echo 'demo: SKIP (not the SDL emulator; set EMU)'
	exit 0
fi
if [ ! -f "$ROOT/dis/xenith.dis" ]; then
	echo 'demo: SKIP (Xenith not built)'
	exit 0
fi
tmp=$(mktemp -d "$here/tests/.demo.XXXXXX")
trap 'rm -rf "$tmp"' EXIT
# a host path as Inferno sees it, through /n/local as the profile mounts it
n() { echo "/n/local$1"; }

# what each command of the guide must print (patterns for Inferno's grep)
python3 -I - "$here/demo/guide" "$(n "$here/demo")" > "$tmp/run.sh" <<'E'
import sys
guide, dir = sys.argv[1], sys.argv[2]
expect = {
	'phil/prove agents.logic agents.md': ['argue/valid 1'],
	'phil/prove agents-misread.logic agents.md': ['agents.md:1: argue/converse', 'denying the antecedent', 'argue/missing'],
	'phil/prove necessity.logic necessity.md': ['necessity.md:3: argue/invalid'],
	'phil/prove ought.logic ought.md': ['ought.md:2: argue/invalid.*ought to be that you pay'],
	'phil/map cosmos.logic': ['against: O1'],
	'phil/map -a cosmos.logic': ['objections and replies'],
	'phil/prove cosmos.logic cosmos.md': ['cosmos.md:7: argue/restates', 'argue/survives 1'],
	'phil/prove cosmos-unanswered.logic cosmos.md': ['cosmos.md:5: argue/defeated', 'argue/survives 0'],
	'phil/prove cosmos-missed.logic cosmos.md': ['cosmos.md:7: argue/misses', 'argue/negation'],
	'phil/prove -t agents.logic': ['conjecture'],
}
model = ('phil/argue', 'cosmos.md.logic')	# section 7 wants a model
text = open(guide).read()
cmds, pos = [], 0
for line in text.split('\n'):
	c = line.strip()
	if line.startswith('\t') and (c.startswith('phil/') or c.startswith('Local ')):
		q0 = pos + line.index(c)
		cmds.append((c, q0, q0 + len(c)))
	pos += len(line) + 1
print('load std')
print('failed=0')
print("fn pass { echo 'PASS:' $* }")
print("fn fail { echo 'FAIL:' $*; failed=1 }")
print('id=`{cat /mnt/xenith/new/ctl}')
print('W=/mnt/xenith/${index 1 $id}')
print("echo 'name %s/guide' > $W/ctl" % dir)
print('echo get > $W/ctl')
# the +Errors window, emptied; the pattern waited for in it
print('''fn errwin {
	e=`{grep 'demo/\\+Errors' /mnt/xenith/index}
	if {! ~ $#e 0} { E=/mnt/xenith/${index 1 $e} }
}
fn clear {
	E=()
	errwin
	if {! ~ $#E 0} { echo -n , > $E/addr; echo -n '' > $E/data }
}
fn waitfor {
	found=()
	for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 {
		if {~ $#found 0} {
			errwin
			if {! ~ $#E 0} {
				cat $E/body > /tmp/demo.out
				if {grep -s $1 /tmp/demo.out} {found=1}
			}
			if {~ $#found 0} {sleep 1}
		}
	}
	~ $#found 1
}''')
seen = set()
for c, q0, q1 in cmds:
	if c.startswith(model) or any(m in c for m in model):
		continue
	if c.startswith('Local '):
		print("echo 'MX%d %d' > $W/event" % (q0, q1))
		print('sleep 2')
		continue
	if c not in expect:
		print("fail 'the guide runs %s, which this test has no expectation for'" % c)
		continue
	seen.add(c)
	print('clear')
	print("echo 'MX%d %d' > $W/event" % (q0, q1))
	for p in expect[c]:
		print("if {waitfor '%s'} {pass '%s: %s'} {fail '%s: no %s'}" % (p, c, p, c, p))
for c in expect:
	if c not in seen:
		print("fail 'the guide no longer runs %s'" % c)
# button 3 on an address in the guide opens the file at that line
i = text.index('agents.md:3')
print("echo 'ML%d %d' > $W/event" % (i, i + len('agents.md:3')))
print('sleep 2')
print("if {grep -s '%s/agents.md' /mnt/xenith/index} {pass 'button 3 on agents.md:3 opens agents.md'} {fail 'button 3 on agents.md:3 opened nothing'}" % dir)
print("if {~ $failed 0} {echo 'ALL PASS'} {echo '--- windows'; cat /mnt/xenith/index; errwin; if {! ~ $#E 0} {echo '--- +Errors'; cat $E/body}}")
E

{
	echo /
	echo
	echo
	printf '%11d \n' 0
	printf 'e%11d %11d %11d %11d %11d \n' 0 0 0 0 0
	echo
	echo /
	echo "sh $(n "$tmp/run")"
} > "$tmp/dump"
{
	echo "sh $(n "$tmp/run.sh") >'#c/cons' >[2=1]"
	echo "echo halt >'#c/sysctl'"
} > "$tmp/run"

# Xenith's buffer files are left when the emulator halts; remove this run's
before=$(ls "$ROOT/tmp" 2>/dev/null | grep 'xenith$')
out=$(SDL_VIDEODRIVER=dummy timeout 300 "$emu" -c1 -g1024x768 -r"$ROOT" /dis/sh.dis -c "
load std
mount -ac {mntgen} /n >[2] /dev/null
trfs '#U*' /n/local >[2] /dev/null
ls /n/local > /dev/null >[2] /dev/null
xenith -l $(n "$tmp/dump")" 2>&1)
for f in $(ls "$ROOT/tmp" 2>/dev/null | grep 'xenith$'); do
	printf '%s\n' "$before" | grep -qxF "$f" || rm -f "$ROOT/tmp/$f"
done
if printf '%s\n' "$out" | grep -q '^ALL PASS'; then
	echo "demo: ok ($(printf '%s\n' "$out" | grep -c '^PASS') checks)"
	exit 0
fi
printf '%s\n' "$out" | grep -v 'fsqid'
echo 'demo: FAIL'
exit 1

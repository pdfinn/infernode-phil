#!/bin/bash
# tests/format_test.sh - wwb/prove -f: every logic file of data/argue
# written again in logic's symbols, and that written back in ASCII
# (-A), is proved as the file was: the same findings, word for word,
# but for the file's name.  A file prove cannot read is not rewritten.
# And every countermodel prove shows is one: tests/cmcheck.py evaluates
# the file's TPTP form (prove -t) in it.  And every valid conclusion has
# a tableau that closes, and no invalid one does (prove -PP tries them
# too).  Needs python3.
# ROOT as for tests/run.sh.
here=$(cd "$(dirname "$0")/.." && pwd)
if [ -z "$ROOT" ] || [ ! -f "$ROOT/mkconfig" ]; then
	echo 'tests/format_test.sh: set ROOT to your InferNode tree' >&2
	exit 1
fi
case $(uname -s) in
Darwin)	host=MacOSX;;
*)	host=$(uname -s);;
esac
emu=$ROOT/emu/$host/o.emu
tmp=$(mktemp -d)
[ -n "$KEEP" ] || trap 'rm -rf "$tmp"' EXIT
timeout 300 "$emu" -c1 -r"$ROOT" sh "#U*$here/tests/format.inferno" "#U*$here" "#U*$tmp" >/dev/null 2>&1
fail=0
n=0
for u in "$tmp"/*.u.logic; do
	b=$(basename "$u" .u.logic)
	n=$((n+1))
	for v in uours aours; do
		# the findings name the file they are about
		if ! diff <(sed 's/^[^ :]*\.logic:/F:/; s/[^ ]*\.logic\b/F/g' "$tmp/$b.ours") \
			<(sed 's/^[^ :]*\.logic:/F:/; s/[^ ]*\.logic\b/F/g' "$tmp/$b.$v") >/dev/null; then
			echo "FAIL: $b: proved otherwise once written again ($v)"
			fail=1
		fi
	done
	grep -q -- '->\|!\|\[\]\|<>' <(cut -f3 "$u" | grep -v '^#') && { echo "FAIL: $b: ASCII left in its symbols"; fail=1; }
done
# each countermodel shown for a file's conclusion, where the file has
# no steps (a step's model is of its own premises, not the file's),
# makes the TPTP form's axioms true and its conjecture false
m=0
for o in "$tmp"/*.ours; do
	b=$(basename "$o" .ours)
	f=$(sed -n 's/^\([^ :]*\.logic\):.*/\1/p' "$o" | head -1)
	model=$(sed -n 's/.*argue\/countermodel: C\( (S[0-9]*)\)\{0,1\}: //p' "$o" | head -1)
	[ -n "$model" ] && [ -s "$tmp/$b.p" ] || continue
	grep -q '	from ' "$tmp/$b.u.logic" 2>/dev/null && continue
	m=$((m+1))
	r=$(python3 -I "$here/tests/cmcheck.py" "$tmp/$b.p" "$model" 2>&1)
	case "$r" in
	ok) ;;
	*)	echo "FAIL: $b: the countermodel shown is not one: $r: $model"; fail=1;;
	esac
done
if [ $m -lt 15 ]; then
	echo "FAIL: only $m countermodels checked"
	fail=1
fi
# a tableau for every valid conclusion, closing; none for an invalid one
p=0
for pf in "$tmp"/*.proof; do
	inv=$(sed -n 's/.*argue\/invalid: \([^ ]*\) .*/\1/p' "$pf" | sort -u)
	for s in $(sed -n 's/^# \([^ ,]*\)\( (S[0-9]*)\)\{0,1\}, proved by a tableau.*/\1/p' "$pf"); do
		if printf '%s\n' $inv | grep -qx "$s"; then
			echo "FAIL: $(basename "$pf" .proof): $s does not follow, yet its tableau closes"; fail=1
		else
			p=$((p+1))
		fi
	done
	for s in $(sed -n 's/^# no tableau shown for \([^ ,]*\).*/\1/p' "$pf"); do
		printf '%s\n' $inv | grep -qx "$s" ||
			{ echo "FAIL: $(basename "$pf" .proof): $s follows, but no tableau closes"; fail=1; }
	done
done
if [ "${p:-0}" -lt 50 ]; then
	echo "FAIL: only ${p:-0} tableaux"
	fail=1
fi
if [ $n -lt 40 ]; then
	echo "FAIL: only $n files written again"
	fail=1
fi
[ $fail = 0 ] && echo "format: ok ($n files, $m countermodels, $p tableaux)"
exit $fail

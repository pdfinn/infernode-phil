#!/bin/sh
# tests/prove_z3_test.sh - phil/prove against Z3.  Each logic file in
# tests/data/argue is written as TPTP (prove -t) and decided by Z3
# (tests/fof2z3.py); its verdict must be prove's: Theorem where prove
# says valid, CounterSatisfiable where it says invalid, either where it
# says undecided.  An argument whose premises contradict each other, or
# whose conclusion restates a premise, follows in logic but is no
# argument: prove calls it invalid, and must say which it is.
# Needs python3 with z3 (pip install z3-solver); ROOT as for tests/run.sh.
here=$(cd "$(dirname "$0")/.." && pwd)
if [ -z "$ROOT" ] || [ ! -f "$ROOT/mkconfig" ]; then
	echo 'tests/prove_z3_test.sh: set ROOT to your InferNode tree' >&2
	exit 1
fi
if ! python3 -c 'import z3' 2>/dev/null; then
	echo 'tests/prove_z3_test.sh: SKIP: no z3 for python3 (pip install z3-solver)'
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
trap 'rm -rf "$tmp"' EXIT
timeout 300 "$emu" -c1 -r"$ROOT" sh "#U*$here/tests/prove.inferno" "#U*$here" "#U*$wwb" "#U*$tmp" >/dev/null 2>&1
fail=0
n=0
for p in "$tmp"/*.p; do
	b=$(basename "$p" .p)
	ours=$(sed -n 's/.*argue\/valid \(-*[0-9]\).*/\1/p' "$tmp/$b.ours")
	[ -z "$ours" ] && continue	# a file that does not parse: no verdict
	z=$(python3 "$here/tests/fof2z3.py" "$p" 2>&1 | tail -1)
	n=$((n+1))
	case "$ours:$z" in
	1:Theorem|0:CounterSatisfiable|-1:Theorem|-1:CounterSatisfiable|-1:Unknown)
		;;
	0:Theorem)
		grep -q 'argue/circular\|argue/inconsistent' "$tmp/$b.ours" ||
			{ echo "FAIL: $b: prove says invalid, Z3 proves it"; fail=1; } ;;
	*)
		echo "FAIL: $b: prove says $ours, Z3 says $z"; fail=1 ;;
	esac
done
[ $n -ge 15 ] || { echo "FAIL: only $n arguments compared"; fail=1; }
if [ $fail = 0 ]; then
	echo "prove-z3: ok ($n arguments agree)"
fi
exit $fail

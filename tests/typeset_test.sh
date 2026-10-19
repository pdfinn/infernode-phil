#!/bin/sh
# tests/typeset_test.sh - phil/tableau's output set by InferNode's own
# troff (the infernode-troff package: pic, eqn, troff, tr2pdf) with no
# complaint from any of them, one picture to each tableau, and a PDF.
# TROFFPKG names the package's tree, built; without it, a sibling
# ../infernode-troff is tried, and the test skips if neither is there.
# ROOT as for tests/run.sh.
here=$(cd "$(dirname "$0")/.." && pwd)
if [ -z "$ROOT" ] || [ ! -f "$ROOT/mkconfig" ]; then
	echo 'tests/typeset_test.sh: set ROOT to your InferNode tree' >&2
	exit 1
fi
pkg=${TROFFPKG:-$here/../infernode-troff}
if [ ! -f "$pkg/dis/troff.dis" ]; then
	echo 'tests/typeset_test.sh: SKIP: no built infernode-troff (set TROFFPKG)'
	exit 0
fi
pkg=$(cd "$pkg" && pwd)
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
cat > "$tmp/run" <<'X'
load std
(phil wwb pkg tmp) = $*
run $pkg/troffns $pkg
run $phil/philns $phil $wwb
cd $phil/tests
for f in data/argue/modal/*.logic data/argue/steps/kalam.logic data/argue/valid.logic {
	phil/prove -P $f
} | grep '^#' > $tmp/proofs
phil/tableau $tmp/proofs > $tmp/tr
cd $tmp
{pic tr | eqn /lib/troff/eqnrc - | troff | tr2pdf > pdf} >[2] err
echo halt > /dev/sysctl
X
timeout 300 "$emu" -c1 -r"$ROOT" sh "#U*$tmp/run" "#U*$here" "#U*$wwb" "#U*$pkg" "#U*$tmp" >/dev/null 2>&1
fail=0
n=$(grep -c 'proved by a tableau' "$tmp/proofs")
[ "$n" -ge 10 ] || { echo "FAIL: only $n tableaux to set"; fail=1; }
[ "$(grep -c '^\.PS' "$tmp/tr")" = "$n" ] || { echo "FAIL: not one picture to each tableau"; fail=1; }
if [ -s "$tmp/err" ]; then
	echo 'FAIL: pic, eqn, troff or tr2pdf said:'
	head "$tmp/err"
	fail=1
fi
head -c 5 "$tmp/pdf" | grep -q '%PDF' || { echo 'FAIL: no PDF'; fail=1; }
[ $fail = 0 ] && echo "typeset: ok ($n tableaux)"
exit $fail

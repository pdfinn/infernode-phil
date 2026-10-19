#!/bin/sh
# tests/typeset_test.sh - phil/tableau's output set by InferNode's own
# troff (the infernode-troff package: pic, eqn, troff, tr2pdf) with no
# complaint from any of them, one picture to each tableau (an invalid
# argument's too, its open branches marked ↑, each followed by its
# countermodel) and one table to each countermodel, and a PDF; where poppler is, its symbols the
# math font's and every tree within the page's margins (none run off a
# page's foot), and (with python3) each tree laid out from what troff
# set: what its lines came from 0.3 inches right of its widest formula,
# in every tree; and the same trees and tables in a book (book(1),
# -mbook) with no complaint, its PDF PDF/UA-1 where veraPDF is
# (verapdf, or $VERAPDF): each tree described.
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
# valid arguments, and invalid ones (each its countermodel)
for f in data/argue/modal/*.logic data/argue/steps/kalam.logic data/argue/valid.logic data/argue/gap.logic data/argue/middle.logic data/argue/shift.logic {
	phil/prove -P $f
} > $tmp/proofs >[2] /dev/null
phil/tableau $tmp/proofs > $tmp/tr
cd $tmp
{pic tr | tbl | eqn /lib/troff/eqnrc - | troff | tr2pdf > pdf} >[2] err
{echo '.title "Proofs"'; echo .mainmatter; echo '.chapter "Tableaux"'; echo; cat tr} > bk.ms
book bk.ms >[2] bkerr
echo halt > /dev/sysctl
X
timeout 300 "$emu" -c1 -r"$ROOT" sh "#U*$tmp/run" "#U*$here" "#U*$wwb" "#U*$pkg" "#U*$tmp" >/dev/null 2>&1
fail=0
n=$(grep -c 'proved by a tableau' "$tmp/proofs")
[ "$n" -ge 10 ] || { echo "FAIL: only $n tableaux to set"; fail=1; }
[ "$(grep -c '^\.PS' "$tmp/tr")" = "$n" ] || { echo "FAIL: not one picture to each tableau"; fail=1; }
m=$(grep -c 'argue/countermodel' "$tmp/proofs")
[ "$m" -ge 5 ] || { echo "FAIL: only $m countermodels to set"; fail=1; }
[ "$(grep -c '^\.TS' "$tmp/tr")" = "$m" ] || { echo "FAIL: not one table to each countermodel"; fail=1; }
o=$(grep -c 'not proved by a tableau' "$tmp/proofs")
[ "$o" -ge 3 ] || { echo "FAIL: only $o open tableaux to set"; fail=1; }
if [ -s "$tmp/err" ]; then
	echo 'FAIL: pic, eqn, troff or tr2pdf said:'
	head "$tmp/err"
	fail=1
fi
head -c 5 "$tmp/pdf" | grep -q '%PDF' || { echo 'FAIL: no PDF'; fail=1; }
if command -v pdffonts >/dev/null 2>&1 && command -v pdftotext >/dev/null 2>&1; then
	pdffonts "$tmp/pdf" | grep -q LibertinusMath || { echo 'FAIL: the symbols not the math font'"'"'s'; fail=1; }
	# each open tree marked, and followed by its countermodel
	pdftotext "$tmp/pdf" "$tmp/txt"
	[ "$(grep -c ', not valid' "$tmp/txt")" = "$o" ] && [ "$(grep -c '↑' "$tmp/txt")" -ge "$o" ] ||
		{ echo 'FAIL: the open trees not titled not valid, their branches not marked ↑'; fail=1; }
	awk '/, not valid/ { open++ } /, a countermodel/ { if (open) open-- } END { exit open != 0 }' "$tmp/txt" ||
		{ echo 'FAIL: an open tree not followed by its countermodel'; fail=1; }
	# every word an inch or more from the page's top and foot
	pdftotext -bbox "$tmp/pdf" - | awk '
		/<page / { match($0, /height="[0-9.]+"/); h = substr($0, RSTART + 8, RLENGTH - 9) + 0 }
		/<word / { match($0, /yMin="[0-9.]+"/); y0 = substr($0, RSTART + 6, RLENGTH - 7) + 0
			match($0, /yMax="[0-9.]+"/); y1 = substr($0, RSTART + 6, RLENGTH - 7) + 0
			if (y0 < 71 || y1 > h - 71) bad++ }
		END { exit bad > 0 }' || { echo 'FAIL: a tree outside the page'"'"'s margins'; fail=1; }
	if command -v python3 >/dev/null 2>&1; then
		pdftotext -bbox "$tmp/pdf" "$tmp/bbox.html"
		python3 -I - "$tmp/bbox.html" <<'PY' || fail=1
import re, html, sys
# each tree from its title (C, C1 ..., alone at the left of its row) to
# the next; the column of what its trunk's lines came from (P1, A1, C
# denied, on a numbered line), and the widest formula on those lines,
# its subscripts too
pages = re.findall(r'<page [^>]*>(.*?)</page>', open(sys.argv[1], encoding='utf-8').read(), re.S)
gaps = []
for p in pages:
    ws = [(float(a), float(b), float(c), float(d), html.unescape(w)) for a, b, c, d, w in
          re.findall(r'xMin="([\d.]+)" yMin="([\d.]+)" xMax="([\d.]+)" yMax="([\d.]+)">([^<]*)<', p)]
    titles = sorted(w[3] for w in ws if re.match(r'^C\d*$', w[4]) and
                    not any(v is not w and abs(v[3] - w[3]) < 2 and v[0] < w[0] for v in ws))
    bounds = titles + [1e9]
    for t0, t1 in zip(bounds, bounds[1:]):
        tw = [w for w in ws if t0 < w[3] < t1]
        prem = [w for w in tw if re.match(r'^(P|A|C)\d*$', w[4]) and
                any(v[2] < w[0] - 12 for v in tw if abs(v[3] - w[3]) < 3)]
        if not prem:
            continue
        x = min(w[0] for w in prem)
        rows = [w for w in tw if abs(w[0] - x) < 1 and
                any(re.match(r'^\d+\.$', v[4]) and abs(v[3] - w[3]) < 1 for v in tw)]
        ends = [max([v[2] for v in tw if r[3] - 2 <= v[3] <= r[3] + 4 and v[2] < x - 3] or [0]) for r in rows]
        if ends:
            gaps.append(round(x - max(ends), 1))
ok = len(gaps) >= 10 and all(20.6 < g < 22.6 for g in gaps)
if not ok:
    print('FAIL: the trees not laid out from what troff set (points from the widest formula to what it came from, 21.6 each):', gaps)
sys.exit(not ok)
PY
	fi
fi
if [ -s "$tmp/bkerr" ] || [ ! -s "$tmp/bk.pdf" ]; then
	echo 'FAIL: the trees in a book:'
	head "$tmp/bkerr"
	fail=1
fi
vera=${VERAPDF:-$(command -v verapdf 2>/dev/null)}
if [ -n "$vera" ] && [ -s "$tmp/bk.pdf" ]; then
	"$vera" --flavour ua1 --format text "$tmp/bk.pdf" 2>/dev/null | grep -q '^PASS' ||
		{ echo 'FAIL: the book not PDF/UA-1'; fail=1; }
fi
[ $fail = 0 ] && echo "typeset: ok ($n tableaux, $o of them open; $m countermodels)"
exit $fail

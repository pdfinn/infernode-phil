#!/bin/sh
# bench/align.sh results out - phil/align on the three runs of each
# passage in a gold run's results (name.logic.r1, .r2, .r3: three
# readings of one text, each with atoms of its own), pairwise, into
# out/name.r1-r2.align and so on; bench/aligncmp.py measures them.
# No model is asked.
here=$(cd "$(dirname "$0")/.." && pwd)
res=$(cd "$1" && pwd)
mkdir -p "$2"
out=$(cd "$2" && pwd)
for r1 in "$res"/*.logic.r1; do
	n=$(basename "$r1" .logic.r1)
	for p in "r1 r2" "r1 r3" "r2 r3"; do
		set -- $p
		[ -f "$res/$n.logic.$2" ] || continue
		"$here/phil" align "$res/$n.logic.$1" "$res/$n.logic.$2" > "$out/$n.$1-$2.align"
	done
done

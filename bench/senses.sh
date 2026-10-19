#!/bin/sh
# bench/senses.sh dir results [jobs] - phil/senses on readings already
# made: each reading in dir (name.logic.rN, beside name.md) copied into
# results and checked there, jobs at a time (default 8), its findings
# in name.logic.rN.senses.out.  $WWBMODEL and $MODEL as for run.sh.
# What it measures is the senses step alone, on readings it did not
# shape.
here=$(cd "$(dirname "$0")/.." && pwd)
dir=$(cd "$1" && pwd)
mkdir -p "$2"
res=$(cd "$2" && pwd)
jobs=${3:-8}
model=${MODEL:-claude-opus-5-5}
for r in "$dir"/*.logic.r[0-9]; do
	n=$(basename "$r")
	md=${n%%.logic.r*}.md
	[ -f "$dir/$md" ] || [ -f "$res/$md" ] || continue
	cp "$r" "$res/$n"
	[ -f "$dir/$md" ] && cp "$dir/$md" "$res/$md"
	echo "$n"
done > "$res/list"
cd "$res"
xargs -P "$jobs" -I{} sh -c "
	[ -s {}.senses.out ] && exit 0
	md=\$(echo {} | sed 's/\.logic\.r[0-9]*\$/.md/')
	timeout 1800 '$here/phil' senses -m '$model' -d \$md {} > {}.senses.out 2>&1
	echo {} \$? >> done" < list

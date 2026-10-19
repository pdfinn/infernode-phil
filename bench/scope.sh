#!/bin/sh
# bench/scope.sh dir results [jobs] - phil/scope on readings already
# made: each reading in dir (name.logic.rN, beside name.md) copied into
# results and checked there, jobs at a time (default 8), its findings
# in name.logic.rN.scope.out.  No model is asked.
here=$(cd "$(dirname "$0")/.." && pwd)
dir=$(cd "$1" && pwd)
mkdir -p "$2"
res=$(cd "$2" && pwd)
jobs=${3:-8}
for r in "$dir"/*.logic.r[0-9]; do
	n=$(basename "$r")
	md=${n%%.logic.r*}.md
	[ -f "$dir/$md" ] || continue
	cp "$r" "$res/$n"
	cp "$dir/$md" "$res/$md"
	echo "$n"
done > "$res/list"
cd "$res"
xargs -P "$jobs" -I{} sh -c "
	md=\$(echo {} | sed 's/\.logic\.r[0-9]*\$/.md/')
	timeout 600 '$here/phil' scope {} \$md > {}.scope.out 2>&1
	echo {} \$? >> done" < list

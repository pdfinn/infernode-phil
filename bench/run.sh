#!/bin/sh
# bench/run.sh dir results [jobs] - phil/argue -n 3 -k 3 on every passage
# (dir/*.md) into results, jobs at a time (default 8); $RUNS sets -n,
# and $FLAGS adds options to argue.  $LLM (or $WWBMODEL) and
# $MODEL (default claude-opus-5-5) say which model reads, as for ./phil.
here=$(cd "$(dirname "$0")/.." && pwd)
dir=$(cd "$1" && pwd)
mkdir -p "$2"
res=$(cd "$2" && pwd)
jobs=${3:-8}
runs=${RUNS:-3}
model=${MODEL:-claude-opus-5-5}
cp "$dir"/*.md "$res"/
cd "$res"
ls *.md | sed 's/\.md$//' | xargs -P "$jobs" -I{} sh -c "
	[ -s {}.out ] && grep -q 'argue/runs-agree' {}.out && exit 0
	timeout 3600 '$here/phil' argue -n $runs -k 3 $FLAGS -m '$model' -o {}.logic {}.md > {}.out 2>&1
	echo {} \$? >> done"

#!/bin/sh
# same.sh dir out - wwb/prove over every logic file in dir, as built now,
# its findings and its TPTP written to out (made afresh), with times.
# same.sh -c old new - whether two such runs said the same thing, byte for
# byte, and how their times compare.
#
# The check every change to prove's speed must pass: run it on the build
# before the change and on the build after, over the bench and the stress
# files (gen.py and stress.py), and nothing may differ.  See
# docs/PROVE-PERFORMANCE.md.  ROOT is the InferNode tree.
#
#	python3 -I tools/prove-bench/gen.py /tmp/args 1
#	tools/prove-bench/same.sh /tmp/args /tmp/before
#	(change prove, mk install)
#	tools/prove-bench/same.sh /tmp/args /tmp/after
#	tools/prove-bench/same.sh -c /tmp/before /tmp/after
here=$(cd "$(dirname "$0")/../.." && pwd)
if [ "$1" = -c ]; then
	old=$2 new=$3 n=0 all=0
	for f in "$old"/*.ours "$old"/*.p; do
		all=$((all+1))
		if ! cmp -s "$f" "$new/$(basename "$f")"; then
			echo "differ: $(basename "$f")"
			n=$((n+1))
		fi
	done
	echo "$n of $all files differ"
	python3 -I - "$old/times" "$new/times" <<'E'
import sys
def t(p):
	r = {}
	for l in open(p):
		n, a, b = l.split()
		r[n] = (int(b) - int(a)) / 1e6
	return r
a, b = t(sys.argv[1]), t(sys.argv[2])
print('seconds in all: %.1f before, %.1f after' % (sum(a.values()), sum(b.values())))
for k in sorted(a, key=lambda k: -a[k])[:10]:
	print('%-24s %8.3f %8.3f' % (k, a[k], b.get(k, -1)))
E
	[ $n = 0 ]
	exit
fi
if [ -z "$ROOT" ] || [ $# != 2 ]; then
	echo 'usage: ROOT=... same.sh dir out | same.sh -c old new' >&2
	exit 1
fi
rm -rf "$2"
mkdir -p "$2"
cp "$1"/*.logic "$2"/
"$ROOT/emu/$(uname -s | sed s/Darwin/MacOSX/)/o.emu" -c1 -pheap=1024m -pmain=1024m -r"$ROOT" \
	sh "#U*$here/tools/prove-bench/run.inferno" "#U*$here" "#U*$(cd "$2" && pwd)" >/dev/null 2>&1
echo "$(ls "$2"/*.ours | wc -l) arguments run into $2"

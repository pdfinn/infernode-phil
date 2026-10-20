#!/bin/sh
# bench/skeleton.sh dir results - phil/skeleton, the reading by rule,
# on every passage in dir (dir/*.md): wwb/parse, then the skeleton, into
# results/name.skel.logic, and the form of each of its statements
# (phil/shape) into results/name.skel.shape, in one emulator.  No model
# is asked.  bench/skelcmp.py sets the forms beside a key's or a model's.
# ROOT and WWB as for ./phil.
here=$(cd "$(dirname "$0")/.." && pwd)
ROOT=${ROOT:-$(cd "$here/.." && pwd)/infernode}
WWB=${WWB:-$(cd "$here/.." && pwd)/infernode-wwb}
case $(uname -s) in
Darwin)	host=MacOSX;;
*)	host=$(uname -s);;
esac
dir=$(cd "$1" && pwd)
mkdir -p "$2"
res=$(cd "$2" && pwd)
cp "$dir"/*.md "$res"/
"$ROOT/emu/$host/o.emu" -c1 -r"$ROOT" sh "#U*$here/bench/skeleton.inferno" "#U*$here" "#U*$WWB" "#U*$res" 2>&1 |
	grep -v '^fs: fsqid'

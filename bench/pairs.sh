#!/bin/sh
# bench/pairs.sh dir results - each attribution pair in dir read and
# checked: the source (primary) read for everything it claims
# (phil/claims), not for one argument, since a report may be of any of
# its claims; the commentary
# read the same way given the source's atoms (-V), so that its reports
# of the source's claims use the source's names; then a corpus of the
# two, the shared atoms the source's, aligned by name (provenance
# "vocabulary": the reader was given the atom), and phil/corpus on it.
here=$(cd "$(dirname "$0")/.." && pwd)
dir=$(cd "$1" && pwd)
mkdir -p "$2"
res=$(cd "$2" && pwd)
model=${MODEL:-claude-opus-5-5}
for p in "$dir"/*/; do
	pair=$(basename "$p")
	c=$res/$pair
	mkdir -p "$c/readings"
	cp "$p"/works "$p"/*.md "$c/"
	prim=$(awk -F'\t' '$3 == "primary" {print $1}' "$c/works")
	sec=$(awk -F'\t' '$3 == "secondary" {print $1}' "$c/works")
	(
	cd "$c"
	"$here/phil" claims -m "$model" -o "$prim.logic" "$prim.md" > "$prim.out" 2>&1
	grep '^atom	' "$prim.logic" > vocab
	"$here/phil" argue -k 3 -m "$model" -V vocab -o "$sec.logic" "$sec.md" > "$sec.out" 2>&1
	cp vocab atoms
	: > align
	for w in $prim $sec; do
		mkdir -p readings/$w
		cp $w.logic readings/$w/logic
		for a in $(awk -F'\t' '$1 == "atom" {sub(/\(.*/, "", $2); print $2}' $w.logic | sort -u); do
			grep -q "^atom	$a[	(]" atoms && printf 'same\t%s:%s\t%s\tvocabulary\n' "$w" "$a" "$a" >> align
		done
	done
	"$here/phil" corpus . > corpus.out 2>&1
	echo "$pair done"
	)
done

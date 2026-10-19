#!/bin/sh
# fetch.sh dir - the Project Gutenberg texts the gold set is cut from
mkdir -p "$1"
for n in $(python3 -I -c 'import sys; sys.path.insert(0, sys.argv[1]); from gold import G; print(" ".join(sorted({str(g[1]) for g in G})))' "$(dirname "$0")"); do
	[ -s "$1/$n.txt" ] || curl -sS -L -o "$1/$n.txt" "https://www.gutenberg.org/ebooks/$n.txt.utf-8"
done

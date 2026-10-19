#!/bin/sh
# tests/run.sh [-u] - run the workbench's tests in an InferNode emulator.
#
# ROOT must name an InferNode tree with a built emulator, and the
# workbench must be built (mk install).  -u rewrites the expected
# output from what the tools do now.
here=$(cd "$(dirname "$0")/.." && pwd)
if [ -z "$ROOT" ] || [ ! -f "$ROOT/mkconfig" ]; then
	echo 'tests/run.sh: set ROOT to your InferNode tree' >&2
	exit 1
fi
case $(uname -s) in
Darwin)	host=MacOSX;;
*)	host=$(uname -s);;
esac
emu=$ROOT/emu/$host/o.emu
if [ ! -x "$emu" ]; then
	echo "tests/run.sh: no emulator at $emu: build InferNode first" >&2
	exit 1
fi
if [ ! -d "$here/dis/wwb" ]; then
	echo 'tests/run.sh: build the workbench first (mk install)' >&2
	exit 1
fi
out=$("$emu" -c1 -r"$ROOT" sh "#U*$here/tests/run.inferno" "#U*$here" "$@" 2>&1)
status=$?
printf '%s\n' "$out" | grep -v '^fs: fsqid'
# emu's own exit status does not carry the script's; read the summary
case $out in
*" passed, 0 failed"*)	exit 0;;
esac
exit 1

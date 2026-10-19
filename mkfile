# Build on the host with InferNode's own mk and limbo:
#	ROOT=/path/to/infernode; PATH=$ROOT/$SYSHOST/$OBJTYPE/bin:$PATH
#	mk install
# The Writer's Workbench must be built first: prove and map load its
# prose library, and map and tableau read its findings parser.  WWB
# names its tree; by default ../infernode-wwb beside this one.
# The commands go to dis/phil, inside this tree; philns binds them in.

DIRS=\
	appl/cmd\
	sh\

all install clean nuke:V:
	test -n "$ROOT" -a -f "$ROOT/mkconfig" || { echo 'set ROOT to your InferNode tree' >&2; exit 1; }
	WWB=${WWB:-`cd ..; pwd`/infernode-wwb}
	test -f "$WWB/module/prose.m" || { echo "no Writer's Workbench at $WWB: set WWB" >&2; exit 1; }
	test -f "$WWB/dis/wwb/lib/prose.dis" || { echo "the Writer's Workbench at $WWB is not built: mk install there" >&2; exit 1; }
	export WWB
	for i in $DIRS; do (cd $i; mk $MKFLAGS $target) || exit 1; done
	mkdir -p dis/ϕwb

test:V:	install
	tests/run.sh
	tests/argue_test.sh
	tests/senses_test.sh
	tests/read_test.sh
	tests/prove_z3_test.sh
	tests/format_test.sh
	tests/typeset_test.sh
	tests/runner_test.sh
	tests/demo_test.sh

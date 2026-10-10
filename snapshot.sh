#!/bin/sh
# snapshot.sh [name]
# Capture an instance's disk back into the package as the new pristine image.
# Run this with the emulator shut down (or after "detach rq0" + "quit").
#
#   ./snapshot.sh 43bsd      -> instances/43bsd/rq.dsk becomes the new image
#   ./snapshot.sh 43bsd -f   -> overwrite an existing snapshot
set -e

PKG=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
NAME=$1
[ $# -gt 0 ] && shift
FORCE=${1:-no}

if [ -z "$NAME" ]; then
	echo "usage: snapshot.sh <instance-dir-name> [-f]" >&2
	exit 2
fi

DIR=$PKG/$NAME
[ -f "$DIR/rq.dsk" ] || { echo "no instance at $DIR" >&2; exit 1; }
[ -f "$DIR/.running" ] && { echo "$DIR is marked running; stop it first" >&2; exit 1; }

mkdir -p "$PKG/instances"
OUT=$PKG/instances/$NAME
if [ -e "$OUT" ] && [ "$FORCE" != "-f" ]; then
	echo "$OUT exists (use -f to replace)" >&2
	exit 1
fi

rm -rf "$OUT"
mkdir -p "$OUT"
echo "compressing $DIR/rq.dsk ..."
xz -9 -T0 -c "$DIR/rq.dsk" > "$OUT/rq.dsk.xz"
cp "$DIR/43.tap" "$OUT/" 2>/dev/null || true

echo "done: $OUT"
echo "to make this the image create.sh hands out, run:"
echo "  cp $OUT/rq.dsk.xz $PKG/files/rq.dsk.xz && $PKG/pack.sh"
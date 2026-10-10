#!/bin/sh
# pack.sh [source-dir]
# Rebuild this package from a working 4.3BSD directory (default ~/vax/4.3bsd).
# Use after the running system's rq.dsk has been updated, to refresh the image
# that create.sh hands out.
#
#   ./pack.sh                 -> uses ~/vax/4.3bsd and ~/source/simh/BIN/vax780
#   ./pack.sh /path/to/4.3bsd /path/to/simh/BIN
set -e

PKG=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SRC=${1:-$HOME/vax/4.3bsd}
SIMH=${2:-$HOME/source/simh/BIN/vax780}

[ -f "$SRC/rq.dsk" ] || { echo "no rq.dsk in $SRC" >&2; exit 1; }
[ -x "$SIMH" ] || { echo "no simh vax780 binary at $SIMH" >&2; exit 1; }

mkdir -p "$PKG/files" "$PKG/bin" "$PKG/extras"

echo "copying emulator and boot files"
cp "$SIMH" "$PKG/bin/vax780"
chmod 755 "$PKG/bin/vax780"
cp "$SRC/boot42" "$SRC/boot.ini" "$PKG/files/"
chmod 755 "$PKG/files/boot42"

echo "compressing disk and tape images (this takes a minute)"
for f in rq.dsk 43.tap; do
	[ -f "$SRC/$f" ] || continue
	echo "  $f"
	xz -9 -T0 -c "$SRC/$f" > "$PKG/files/$f.xz"
done

echo "copying install tape contents to extras/"
for t in "$SRC"/*.tar.gz; do
	[ -f "$t" ] && cp "$t" "$PKG/extras/"
done

echo "writing $PKG/../$(basename "$PKG").tar.xz"
rm -f "$PKG/../$(basename "$PKG").tar.xz"
B=$(basename "$PKG")
tar cJf "$PKG/../$B.tar.xz" -C "$PKG/.." \
	"$B/create.sh" "$B/run.sh.in" "$B/pack.sh" "$B/snapshot.sh" \
	"$B/destroy.sh" "$B/list.sh" "$B/justfile" "$B/README.md" \
	"$B/bin" "$B/files" "$B/extras"

ls -la "$PKG/../$(basename "$PKG").tar.xz"
echo "done"
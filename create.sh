#!/bin/sh
# create.sh [name] [-f]
# Create a fresh, writable 4.3BSD VAX780 instance from the packaged disk image.
#
#   ./create.sh              -> creates ./43bsd
#   ./create.sh work         -> creates ./work
#   ./create.sh work -f      -> overwrites ./work
#
# The instance is a self-contained directory: disk image, boot tape, boot42,
# simh config and the emulator binary. Run it with ./<name>/run.sh

set -e

PKG=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
NAME=43bsd
FORCE=no

while [ $# -gt 0 ]; do
	case "$1" in
		-f|--force) FORCE=yes ;;
		-h|--help) sed -n '2,12p' "$0"; exit 0 ;;
		-*) echo "unknown option: $1" >&2; exit 2 ;;
		*) NAME=$1 ;;
	esac
	shift
done

case "$NAME" in
	''|*/*) echo "invalid instance name: $NAME" >&2; exit 2 ;;
esac

DIR=$PKG/$NAME

if [ -e "$DIR" ]; then
	if [ "$FORCE" = yes ]; then
		echo "replacing existing instance $DIR"
		rm -rf "$DIR"
	else
		echo "$DIR already exists (use -f to replace)" >&2
		exit 1
	fi
fi

mkdir -p "$DIR"

echo "creating $DIR ..."
for f in rq.dsk 43.tap; do
	printf '  unpacking %s\n' "$f"
	xz -dc "$PKG/files/$f.xz" > "$DIR/$f"
done

cp "$PKG/files/boot42" "$PKG/files/boot.ini" "$PKG/bin/vax780" "$DIR/"
chmod 755 "$DIR/vax780" "$DIR/boot42"
ln -s vax780 "$DIR/simh"

sed "s|^BOOTCFG=.*|BOOTCFG=boot.ini|" "$PKG/run.sh.in" > "$DIR/run.sh"
chmod +x "$DIR/run.sh"

cat > "$DIR/README" <<EOF
4.3BSD (MicroVAX 3900 / VAX780) simulator instance -- created from $PKG

  ./run.sh          boot 4.3BSD (single user first:  boot -s, then add a second
                    terminal and "mount -a", "adduser" as needed)
  ./run.sh -f       same, but disable telnet console on port 2323
  ./vax780 boot.ini drop straight into the simh> prompt

Files: rq.dsk (RA81 pack, 456MB), 43.tap (distribution tape), boot42 (bootstrap).
Do not boot with the tape write-locked out of habit: leave it attached read-only
usage is fine, but writes will be discarded on exit unless you detach.
EOF

echo "done. start it with:"
echo "  cd $DIR && ./run.sh"
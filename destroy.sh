#!/bin/sh
# destroy.sh <instance-dir-name> [-f]
# Delete an instance created by create.sh.
#
#   ./destroy.sh work        asks before deleting
#   ./destroy.sh work -f     deletes without asking
set -e

PKG=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
NAME=$1
[ $# -gt 0 ] && shift
FORCE=${1:-}

case "$NAME" in ''|*/*) echo "usage: destroy.sh <instance> [-f]" >&2; exit 2 ;; esac

DIR=$PKG/$NAME
[ -e "$DIR" ] || { echo "no such instance: $DIR" >&2; exit 1; }
[ -f "$DIR/.running" ] && { echo "$DIR is running; stop it first" >&2; exit 1; }

if [ "$FORCE" != "-f" ]; then
	printf 'delete %s and its disk image (%s)? [y/N] ' "$DIR" "$(du -sh "$DIR" | cut -f1)"
	read -r ans
	case "$ans" in y*|Y*) ;; *) echo "cancelled"; exit 0 ;; esac
fi

rm -rf "$DIR"
echo "removed $DIR"
#!/bin/sh
# list.sh -- show every 4.3BSD instance in this package
PKG=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
found=no
for d in "$PKG"/*/rq.dsk; do
	[ -f "$d" ] || continue
	found=yes
	inst=$(dirname "$d")
	name=$(basename "$inst")
	state=stopped
	[ -f "$inst/.running" ] && state=running
	printf '%-16s %-9s %s\n' "$name" "$state" "$(du -sh "$d" | cut -f1)"
done
[ "$found" = no ] && echo "no instances yet -- try: just new 43bsd"
exit 0
#!/bin/sh

latest=$(find "$HOME/Pictures/Screenshots" \
    -type f -name '*.png' \
    -printf '%T@ %p\n' |
    sort -n |
    tail -1 |
    cut -d' ' -f2-)

[ -n "$latest" ] || exit 1

wl-copy --type image/png < "$latest"
notify-send "Screenshot copied" "$(basename "$latest")"

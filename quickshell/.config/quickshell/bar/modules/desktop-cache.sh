#!/usr/bin/env bash

set -e

escape_json() {
    printf '%s' "$1" \
    | sed \
        -e 's/\\/\\\\/g' \
        -e 's/"/\\"/g' \
        -e 's/\t/ /g' \
        -e 's/\r//g'
}

printf '['

first=1

find /usr/share/applications "$HOME/.local/share/applications" \
    -type f -name '*.desktop' 2>/dev/null |
while IFS= read -r file; do

    name=$(grep -m1 '^Name=' "$file" | cut -d= -f2-)
    exec=$(grep -m1 '^Exec=' "$file" | cut -d= -f2-)
    icon=$(grep -m1 '^Icon=' "$file" | cut -d= -f2-)

    # skip invalid entries
    [ -z "$name" ] && continue
    [ -z "$exec" ] && continue

    # remove desktop flags like %u %U %f
    exec="${exec%%\%*}"

    # trim trailing spaces
    exec="$(echo "$exec" | sed 's/[[:space:]]*$//')"

    name=$(escape_json "$name")
    exec=$(escape_json "$exec")
    icon=$(escape_json "$icon")

    if [ $first -eq 0 ]; then
        printf ','
    fi
    first=0

    printf '{"name":"%s","exec":"%s","icon":"%s"}' \
        "$name" "$exec" "$icon"

done

printf ']'

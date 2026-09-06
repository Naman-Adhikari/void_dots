#!/bin/bash

HISTORY="$HOME/.cache/awesome/clipboard_history"
MAX_ENTRIES=50

mkdir -p "$(dirname "$HISTORY")"
touch "$HISTORY"

store_clipboard() {
    local CONTENT ENCODED TMP

    CONTENT=$(xclip -selection clipboard -o 2>/dev/null)

    [ -z "$CONTENT" ] && return

    ENCODED=$(printf '%s' "$CONTENT" | base64 | tr -d '\n')

    [ -z "$ENCODED" ] && return

    TMP="${HISTORY}.tmp"

    # Remove duplicate if it already exists
    grep -Fxv "$ENCODED" "$HISTORY" > "$TMP" 2>/dev/null || true

    # Newest entry goes first
    {
        printf '%s\n' "$ENCODED"
        head -n "$((MAX_ENTRIES - 1))" "$TMP"
    } > "${HISTORY}.new"

    # Atomically replace history
    mv "${HISTORY}.new" "$HISTORY"

    rm -f "$TMP"
}

# Store whatever is already in clipboard
store_clipboard

# Watch X11 clipboard
while clipnotify -s clipboard; do
    store_clipboard
done

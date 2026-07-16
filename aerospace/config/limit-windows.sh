#!/usr/bin/env bash
#
# limit-windows.sh — keep at most MAX_WINDOWS tiled windows on a workspace.
#
# Invoked from AeroSpace's `on-window-detected` callback whenever a new window
# appears. It receives the new window's id in $AEROSPACE_WINDOW_ID. When the
# callback fires the window is ALREADY placed on its workspace and counted, so
# if that workspace now holds more than MAX_WINDOWS this window is the overflow
# one — we move it to the next free workspace, leaving the existing layout
# untouched.
#
# Compatibility: the callback runs under /bin/bash, which on macOS is bash 3.2.
# Avoid bash 4+ features (no `mapfile`, no associative arrays, etc.).
#
# If no empty workspace exists, the window is left where it is — we never lose
# or hide a window.

set -euo pipefail

MAX_WINDOWS=3
AEROSPACE=/opt/homebrew/bin/aerospace

WID="${AEROSPACE_WINDOW_ID:-}"
[ -n "$WID" ] || exit 0

# Which workspace did this specific window land on? Look it up by id rather than
# trusting focus — the new window isn't always on the focused workspace.
current_ws="$(
    "$AEROSPACE" list-windows --all --format '%{window-id}|%{workspace}' \
        | awk -F'|' -v id="$WID" '$1 == id { print $2; exit }'
)"
[ -n "$current_ws" ] || exit 0

# How many windows are on that workspace now (this one included)?
count="$("$AEROSPACE" list-windows --workspace "$current_ws" --count)"

# Within the limit? Nothing to do — let it tile normally.
if [ "$count" -le "$MAX_WINDOWS" ]; then
    exit 0
fi

# Overflow. Find the lowest-numbered empty workspace to send it to.
# `--empty no` lists NON-empty workspaces; any of 1..10 not in that list is free.
nonempty="$("$AEROSPACE" list-workspaces --monitor all --empty no)"

is_nonempty() {
    # exact line match against the non-empty list
    printf '%s\n' "$nonempty" | grep -qxF "$1"
}

target=""
for ws in 1 2 3 4 5 6 7 8 9 10; do
    if ! is_nonempty "$ws"; then
        target="$ws"
        break
    fi
done

# No free workspace — leave the window put rather than crowding another one.
[ -n "$target" ] || exit 0

# Move the overflow window to the free workspace and follow it there.
"$AEROSPACE" move-node-to-workspace --window-id "$WID" --focus-follows-window "$target"

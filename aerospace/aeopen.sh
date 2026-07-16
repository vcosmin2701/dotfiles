# aeopen — launch something and place its new window on a specific AeroSpace
# workspace. Source this from your shell rc (works in zsh and bash):
#
#     source ~/dotfiles/aerospace/aeopen.sh
#
# AeroSpace has no "open app into workspace N" command; you can only move a
# window that already exists. This helper works around that: it snapshots the
# current window ids, runs your command, waits for a NEW window to appear, then
# moves that window to the target workspace. Because it moves the specific new
# window by id, it also works when the app is already running.
#
# Usage:
#   aeopen <workspace> <command...>
#
# Examples:
#   aeopen 5 zed .                 # open Zed in the cwd on workspace 5
#   aeopen 2 code ~/project        # VS Code on workspace 2
#   aeopen 3 open -a Safari        # Safari on workspace 3
#
# IMPORTANT — apps that are already running:
#   A plain `zed .` / `code .` / `open -a App` usually just REFOCUSES the app's
#   existing window instead of making a new one, so there's nothing new to move.
#   Use the app's "new window" flag so a fresh window actually appears:
#       aeopen 9 zed -n .            # zed  --new
#       aeopen 9 code -n ~/project   # code --new-window
#       aeopen 9 open -na Ghostty    # open --new (force new instance)
#   For an app that isn't running yet, the plain form is fine.

aeopen() {
    local aerospace=/opt/homebrew/bin/aerospace
    local ws="$1"; shift

    if [ -z "$ws" ] || [ "$#" -eq 0 ]; then
        echo "usage: aeopen <workspace> <command...>   e.g. aeopen 5 zed ." >&2
        return 2
    fi

    # Snapshot existing window ids.
    local before
    before="$("$aerospace" list-windows --all --format '%{window-id}')"

    # Launch in the background so terminal-attached tools don't block the shell.
    "$@" &

    # Poll up to ~8s for a window id that wasn't there before.
    local new_id="" now attempt=0
    while [ "$attempt" -lt 40 ]; do
        now="$("$aerospace" list-windows --all --format '%{window-id}')"
        new_id="$(
            comm -13 \
                <(printf '%s\n' "$before" | sort) \
                <(printf '%s\n' "$now"    | sort) \
            | head -1
        )"
        [ -n "$new_id" ] && break
        sleep 0.2
        attempt=$((attempt + 1))
    done

    if [ -z "$new_id" ]; then
        echo "aeopen: no new window appeared. If the app was already running," >&2
        echo "        re-run with its new-window flag (e.g. 'zed -n', 'code -n'," >&2
        echo "        'open -na App'). Nothing moved." >&2
        return 1
    fi

    "$aerospace" move-node-to-workspace --window-id "$new_id" "$ws" \
        && echo "aeopen: moved window $new_id -> workspace $ws"
}

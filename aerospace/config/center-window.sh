#!/usr/bin/env bash
# Float the focused window and center it on screen.
# AeroSpace (v0.21) has no native "center", so we float via AeroSpace,
# then size + position the frontmost window with AppleScript.
#
# Usage: center-window.sh [width-fraction] [height-fraction]
#   defaults to 70% wide x 75% tall of the visible screen area.

AEROSPACE=/opt/homebrew/bin/aerospace
FRAC_W="${1:-0.70}"
FRAC_H="${2:-0.75}"

# Ensure the focused window is floating (no-op if already floating).
"$AEROSPACE" layout floating 2>/dev/null

osascript - "$FRAC_W" "$FRAC_H" <<'APPLESCRIPT'
on run argv
  set fracW to (item 1 of argv) as real
  set fracH to (item 2 of argv) as real

  -- Visible desktop area of the main screen (excludes menu bar & Dock).
  tell application "Finder" to set b to bounds of window of desktop
  set sx to item 1 of b
  set sy to item 2 of b
  set scrW to (item 3 of b) - sx
  set scrH to (item 4 of b) - sy

  set newW to (scrW * fracW) as integer
  set newH to (scrH * fracH) as integer
  set newX to (sx + ((scrW - newW) / 2)) as integer
  set newY to (sy + ((scrH - newH) / 2)) as integer

  tell application "System Events"
    set frontApp to first application process whose frontmost is true
    tell frontApp
      if (count of windows) is 0 then return
      set frontWin to front window
      set size of frontWin to {newW, newH}
      set position of frontWin to {newX, newY}
    end tell
  end tell
end run
APPLESCRIPT

#!/usr/bin/env bash
# Orchestrates the AeroSpace workspace items on the left of the bar.
# Shows only workspaces that have windows, plus the focused one.
# - On workspace change (custom event) or reload: rebuild the set of items.
# - On click of a workspace item: switch to that workspace.

AEROSPACE=/opt/homebrew/bin/aerospace
PLUGIN_DIR="$HOME/.config/sketchybar/plugins"
FONT_FACE="JetBrainsMono Nerd Font"
APP_FONT="sketchybar-app-font:Regular:14.0"

render_all() {
  local focused all visible=""
  focused=$("$AEROSPACE" list-workspaces --focused)
  all=$("$AEROSPACE" list-workspaces --monitor focused)

  # Decide which workspaces to show: non-empty OR focused.
  while IFS= read -r ws; do
    [ -z "$ws" ] && continue
    local count
    count=$("$AEROSPACE" list-windows --workspace "$ws" --count 2>/dev/null)
    if [ "$count" -gt 0 ] || [ "$ws" = "$focused" ]; then
      visible+="$ws "
    fi
  done <<< "$all"

  # Remove any stale workspace items, then (re)create the visible set.
  # Items are named space.<id>. We rebuild every time for correctness.
  local existing
  existing=$(sketchybar --query bar 2>/dev/null | jq -r '.items[]' 2>/dev/null | grep '^space\.' || true)
  for item in $existing; do
    sketchybar --remove "$item" 2>/dev/null
  done

  for ws in $visible; do
    local name="space.$ws"
    sketchybar --add item "$name" left \
      --set "$name" \
        icon="$ws" \
        icon.font="$FONT_FACE:Bold:13.0" \
        icon.padding_left=8 \
        icon.padding_right=4 \
        label.font="$APP_FONT" \
        label.padding_right=8 \
        background.corner_radius=5 \
        background.height=26 \
        click_script="$AEROSPACE workspace $ws" \
      --subscribe "$name" aerospace_workspace_change mouse.clicked
    NAME="$name" "$PLUGIN_DIR/aerospace.sh" "$ws"
  done
}

case "$SENDER" in
  aerospace_workspace_change | forced | routine)
    render_all
    ;;
  *)
    render_all
    ;;
esac

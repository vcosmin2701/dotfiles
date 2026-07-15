#!/usr/bin/env bash
# Renders one AeroSpace workspace item: highlight state + the app icons inside it.
# Invoked with $1 = workspace id, and NAME = the sketchybar item name.

source "$HOME/.config/sketchybar/plugins/icon_map.sh"

WORKSPACE_ID="$1"
AEROSPACE=/opt/homebrew/bin/aerospace

FOCUSED=$("$AEROSPACE" list-workspaces --focused)

# Collect unique app icons for the apps living in this workspace.
apps=$("$AEROSPACE" list-windows --workspace "$WORKSPACE_ID" --format '%{app-name}' 2>/dev/null | sort -u)

icon_strip=""
while IFS= read -r app; do
  [ -z "$app" ] && continue
  icon_result=""
  __icon_map "$app"
  [ -z "$icon_result" ] && icon_result=":default:"
  icon_strip+="$icon_result "
done <<< "$apps"
icon_strip="${icon_strip% }"   # trim trailing space

# Colors (Catppuccin Macchiato — matches the rest of the bar)
ACTIVE_BG=0xfff5a97f     # peach
ACTIVE_FG=0xff24273a     # base
IDLE_BG=0x66494d64       # translucent surface
IDLE_FG=0xffcad3f5       # text

if [ "$WORKSPACE_ID" = "$FOCUSED" ]; then
  sketchybar --set "$NAME" \
    background.color=$ACTIVE_BG \
    icon.color=$ACTIVE_FG \
    label.color=$ACTIVE_FG \
    label="$icon_strip" \
    label.drawing=$([ -n "$icon_strip" ] && echo on || echo off)
else
  sketchybar --set "$NAME" \
    background.color=$IDLE_BG \
    icon.color=$IDLE_FG \
    label.color=$IDLE_FG \
    label="$icon_strip" \
    label.drawing=$([ -n "$icon_strip" ] && echo on || echo off)
fi

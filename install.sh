#!/usr/bin/env bash
#
# install.sh — symlink Aerospace + SketchyBar config from this repo into place.
#
# Safe to re-run. Existing real files/dirs at the targets are backed up to
# <target>.backup-<timestamp> before a symlink replaces them. Existing symlinks
# that already point at this repo are left alone.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"

link() {
    local src="$1" dst="$2"

    if [ ! -e "$src" ]; then
        echo "  ✗ source missing, skipping: $src"
        return
    fi

    # Already the correct symlink? Nothing to do.
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
        echo "  = already linked: $dst"
        return
    fi

    mkdir -p "$(dirname "$dst")"

    # Back up whatever is currently there (real file, dir, or wrong symlink).
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        local backup="${dst}.backup-${STAMP}"
        echo "  ⤷ backing up existing $dst -> $backup"
        mv "$dst" "$backup"
    fi

    ln -s "$src" "$dst"
    echo "  ✓ linked: $dst -> $src"
}

echo "Installing dotfiles from: $DOTFILES_DIR"
echo

echo "Aerospace:"
link "$DOTFILES_DIR/aerospace/.aerospace.toml" "$HOME/.aerospace.toml"
link "$DOTFILES_DIR/aerospace/config"          "$HOME/.config/aerospace"

echo
echo "SketchyBar:"
link "$DOTFILES_DIR/sketchybar" "$HOME/.config/sketchybar"

echo
echo "Done."
echo
echo "Next steps:"
echo "  • Reload Aerospace:  aerospace reload-config"
echo "  • Reload SketchyBar: sketchybar --reload   (or: brew services restart sketchybar)"

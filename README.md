# dotfiles

macOS window-manager + status-bar config, shared across my laptops.

- **[Aerospace](https://github.com/nikitabobko/AeroSpace)** — tiling window manager
- **[SketchyBar](https://github.com/FelixKratz/SketchyBar)** — custom status bar

Configs are stored here and symlinked into place, so edits on any machine can be
committed and pulled everywhere.

## Layout

```
aerospace/
  .aerospace.toml        →  ~/.aerospace.toml
  config/                →  ~/.config/aerospace/
    center-window.sh
sketchybar/              →  ~/.config/sketchybar/
  sketchybarrc           # picks laptop vs desktop based on active display
  sketchybarrc-laptop
  sketchybarrc-desktop
  plugins/               # shared plugins (clock, volume, weather, aerospace, …)
  plugins-laptop/        # laptop-only plugins (battery, spotify)
  plugins-desktop/       # desktop-only plugins (spotify)
```

`sketchybarrc` auto-detects whether the built-in laptop display is active and
sources `sketchybarrc-laptop` or `sketchybarrc-desktop` accordingly — so the same
repo works on every machine with no per-host edits.

## Setup on a new laptop

```sh
# 1. Install the tools
brew install nikitabobko/tap/aerospace
brew install FelixKratz/formulae/sketchybar

# 2. Clone and link
git clone https://github.com/vcosmin2701/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh

# 3. Reload
aerospace reload-config
sketchybar --reload
```

`install.sh` is idempotent: it backs up any existing config to
`<target>.backup-<timestamp>` before creating the symlink, and skips links that
are already correct.

## Making changes

Because everything is symlinked, just edit the files in their normal locations
(`~/.aerospace.toml`, `~/.config/sketchybar/…`) — you're editing this repo. Then:

```sh
cd ~/dotfiles
git add -A && git commit -m "tweak config" && git push
```

On other machines: `cd ~/dotfiles && git pull`.

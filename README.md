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
    limit-windows.sh     # caps each workspace at 3 tiled windows (see below)
  aeopen.sh              # shell helper: open an app into a specific workspace
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

### 3-window-per-workspace limit

`limit-windows.sh` keeps each workspace at **at most 3 tiled windows** so a busy
workspace never gets crowded. It's wired into AeroSpace via a catch-all
`on-window-detected` rule at the bottom of `.aerospace.toml`: when a new window
would make the 4th on its workspace, the script moves that window to the next
free workspace (lowest-numbered empty one) and follows it there. The existing
layout is left untouched, and if there's no empty workspace the window just
stays put — nothing is ever hidden or lost. Floating apps (System Settings,
Calculator, etc.) match their own float rules first and don't count toward the
limit. Change the cap by editing `MAX_WINDOWS` at the top of the script.

### Opening an app into a specific workspace — `aeopen`

AeroSpace can't launch an app *into* a chosen workspace (it can only move a
window that already exists), so `aeopen.sh` provides a shell helper that does it:

```sh
aeopen 5 zed .              # open Zed in the cwd on workspace 5
aeopen 2 code ~/project     # VS Code on workspace 2
aeopen 3 open -a Safari     # Safari on workspace 3
```

It snapshots the open windows, runs your command, waits for the new window to
appear, and moves that window to the target workspace.

**If the app is already running**, a plain `zed .` / `open -a App` just refocuses
the existing window — nothing new to move. Use the app's new-window flag instead:

```sh
aeopen 9 zed -n .           # zed  --new
aeopen 9 code -n ~/project  # code --new-window
aeopen 9 open -na Ghostty   # open --new (force a new instance)
```

Enable it by sourcing it from your shell rc (already done on my machines):

```sh
echo 'source ~/dotfiles/aerospace/aeopen.sh' >> ~/.zshrc
```

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

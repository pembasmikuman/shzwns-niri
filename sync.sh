#!/usr/bin/env bash
# sync live configs back into this repo after you tweak them
set -euo pipefail
DOT="$(cd "$(dirname "$0")" && pwd)"

cp ~/.config/niri/config.kdl            "$DOT/config/niri/"
cp ~/.config/niri/rice-colors.kdl       "$DOT/config/niri/"          2>/dev/null || true
cp ~/.config/waybar/config.jsonc        "$DOT/config/waybar/"
cp ~/.config/waybar/style.css           "$DOT/config/waybar/"        2>/dev/null || true
cp ~/.config/waybar/colors.css          "$DOT/config/waybar/"        2>/dev/null || true
rsync -a --delete ~/.config/waybar/scripts/  "$DOT/config/waybar/scripts/"
rsync -a --delete ~/.config/waybar/themes/   "$DOT/config/waybar/themes/"
cp ~/.config/fuzzel/fuzzel.ini          "$DOT/config/fuzzel/"        2>/dev/null || true
cp ~/.config/mako/config                "$DOT/config/mako/"          2>/dev/null || true
cp ~/.config/alacritty/alacritty.toml   "$DOT/config/alacritty/"
cp ~/.config/alacritty/rice-theme.toml  "$DOT/config/alacritty/"     2>/dev/null || true
rsync -a --delete ~/.config/matugen/templates/ "$DOT/config/matugen/templates/"
cp ~/.config/matugen/config.toml        "$DOT/config/matugen/"
cp ~/.config/environment.d/*.conf       "$DOT/config/environment.d/"
cp ~/.config/gtk-3.0/gtk.css            "$DOT/config/gtk-3.0/"       2>/dev/null || true
cp ~/.config/gtk-4.0/gtk.css            "$DOT/config/gtk-4.0/"       2>/dev/null || true
rsync -a --delete ~/.config/niri-rice/  "$DOT/config/niri-rice/"     2>/dev/null || true
cp ~/.local/bin/rice-*                  "$DOT/local-bin/"

echo "synced."

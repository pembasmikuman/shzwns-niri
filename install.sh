#!/usr/bin/env bash
# install — link these dotfiles into $HOME (works on a fresh machine too)
set -euo pipefail
DOT="$(cd "$(dirname "$0")" && pwd)"

link() {  # link <repo-file> <target>
    mkdir -p "$(dirname "$2")"
    ln -sfn "$1" "$2"
}

# --- configs ---
link "$DOT/config/niri/config.kdl"        ~/.config/niri/config.kdl
link "$DOT/config/waybar/config.jsonc"    ~/.config/waybar/config.jsonc
link "$DOT/config/waybar/style.css"       ~/.config/waybar/style.css
mkdir -p ~/.config/waybar
rsync -a "$DOT/config/waybar/scripts/"     ~/.config/waybar/scripts/
rsync -a "$DOT/config/waybar/themes/"      ~/.config/waybar/themes/
link "$DOT/config/mako/config"            ~/.config/mako/config
link "$DOT/config/matugen/config.toml"    ~/.config/matugen/config.toml
rsync -a "$DOT/config/matugen/templates/" ~/.config/matugen/templates/
# wayland-perf env vars live in niri's own environment{} block instead of
# ~/.config/environment.d/, so they don't leak into the Plasma session

# generated files: copy once so apps work before first matugen run
cp -n "$DOT/config/niri/rice-colors.kdl"   ~/.config/niri/rice-colors.kdl   2>/dev/null || true
cp -n "$DOT/config/waybar/colors.css"      ~/.config/waybar/colors.css      2>/dev/null || true
cp -n "$DOT/config/fuzzel/fuzzel.ini"      ~/.config/fuzzel/fuzzel.ini      2>/dev/null || true
mkdir -p ~/.config/kitty
cp -n "$DOT/config/kitty/rice-theme.conf" ~/.config/kitty/rice-theme.conf 2>/dev/null || true
cp -n "$DOT/config/gtk-3.0/gtk.css"        ~/.config/gtk-3.0/gtk.css        2>/dev/null || true
cp -n "$DOT/config/gtk-4.0/gtk.css"        ~/.config/gtk-4.0/gtk.css        2>/dev/null || true

# wire rice-theme.conf into kitty.conf without touching your existing config
if [ -f ~/.config/kitty/kitty.conf ] && ! grep -q '^include rice-theme.conf' ~/.config/kitty/kitty.conf; then
    printf '\ninclude rice-theme.conf\n' >> ~/.config/kitty/kitty.conf
fi

# --- rice scripts + fallback palettes ---
mkdir -p ~/.local/bin ~/.config/niri-rice
install -m755 "$DOT"/local-bin/rice-* ~/.local/bin/
rsync -a "$DOT/config/niri-rice/" ~/.config/niri-rice/

# --- dependencies check ---
echo "checking packages..."
for c in niri waybar swaybg swayidle mako fuzzel cliphist wl-paste matugen \
         kitty brightnessctl playerctl wpctl pamixer bluetoothctl nmcli \
         wlogout swaylock grim slurp python; do
    command -v "$c" >/dev/null 2>&1 || echo "  MISSING: $c"
done

echo
echo "done. enable the session:"
echo "  systemctl --user disable dms.service 2>/dev/null; systemctl --user enable niri.service"
echo "then relogin and press Mod+Ctrl+T to cycle themes."

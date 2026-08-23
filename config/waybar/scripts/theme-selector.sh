#!/usr/bin/env bash
# ──────────────────────────────────────────────
#   Waybar Layout Selector (niri port)
#   switches between layouts in ~/.config/waybar/themes;
#   colors always come from the active rice theme (colors.css).
# ──────────────────────────────────────────────

THEMES_DIR="$HOME/.config/waybar/themes"
WAYBAR_DIR="$HOME/.config/waybar"

[ -d "$THEMES_DIR" ] || { notify-send "Error" "Themes directory not found"; exit 1; }

SELECTED=$(ls -1 "$THEMES_DIR" | fuzzel --dmenu --prompt="waybar layout > " 2>/dev/null)
[ -z "$SELECTED" ] && exit 0

SRC="$THEMES_DIR/$SELECTED"
[ -f "$SRC/config.jsonc" ] && [ -f "$SRC/style.css" ] || {
    notify-send -u critical "Waybar" "layout '$SELECTED' missing files"; exit 1
}

cp "$SRC/config.jsonc" "$WAYBAR_DIR/config.jsonc"
cp "$SRC/style.css" "$WAYBAR_DIR/style.css"

# hyprland-only module → niri equivalent (harmless on already-ported themes)
sed -i 's#"hyprland/workspaces"#"niri/workspaces"#g' "$WAYBAR_DIR/config.jsonc"

killall waybar 2>/dev/null
sleep 0.4
setsid nohup waybar -c "$WAYBAR_DIR/config.jsonc" -s "$WAYBAR_DIR/style.css" >/dev/null 2>&1 < /dev/null &

notify-send "Waybar Layout Updated" "Switched to '$SELECTED' layout (colors follow rice theme)."

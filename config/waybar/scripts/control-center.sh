#!/usr/bin/env bash
# ──────────────────────────────────────────────
#   macOS-style Control Center (niri port, fully wired)
#   origin: okyashgajjar/low-sepecs-hyprland-dotfiles
# ──────────────────────────────────────────────
SCRIPTS="$HOME/.config/waybar/scripts"

get_wifi() {
    local ssid=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes' | cut -d':' -f2)
    [ -z "$ssid" ] && echo "Off" || echo "$ssid"
}

get_bt() {
    bluetoothctl show 2>/dev/null | grep "Powered: yes" >/dev/null && echo "On" || echo "Off"
}

dnd_state() {
    makoctl mode 2>/dev/null | grep -q dnd && echo "On" || echo "Off"
}

bar10() {  # $1 = percent
    local filled=$(($1 / 10)) bar=""
    for ((i=0; i<filled; i++)); do bar+="󰝤"; done
    for ((i=filled; i<10; i++)); do bar+=" "; done
    echo "$bar $1%"
}

get_vol_bar() {
    bar10 "$(pamixer --get-volume 2>/dev/null || echo 0)"
}

get_bright_bar() {
    local cur=$(brightnessctl g) max=$(brightnessctl m)
    local percent=$((cur * 100 / max))
    bar10 "$percent"
}

toggle_dnd() {
    if [[ "$(dnd_state)" == "On" ]]; then
        makoctl mode -d dnd 2>/dev/null
        notify-send -a rice "Focus" "Do not disturb OFF"
    else
        makoctl mode -a dnd 2>/dev/null
        notify-send -a rice "Focus" "Do not disturb ON"
    fi
}

MENU="󰖩  Wi-Fi\n$(get_wifi)\n"
MENU+="󰂯  Bluetooth\n$(get_bt)\n"
MENU+="󰃠  Brightness\n$(get_bright_bar)\n"
MENU+="󰕾  Sound\n$(get_vol_bar)\n"
MENU+="󰔉  Focus\nDND $(dnd_state)\n"
MENU+="󰹑  Displays\n$(niri msg --json outputs 2>/dev/null | python3 -c 'import json,sys; print(len(json.load(sys.stdin)))' 2>/dev/null || echo '?') attached\n"
MENU+="󰝚  Music\n$(playerctl metadata --format '{{artist}} — {{title}}' 2>/dev/null || echo 'Not Playing')\n"
MENU+="󰏘  Rice Theme\n$(cat ~/.local/state/rice/theme 2>/dev/null || echo gruvbox)\n"
MENU+="󰖟  Wallpaper\nnext in theme\n"
MENU+="󰐥  Power\nSystem"

CHOICE=$(echo -e "$MENU" | fuzzel --dmenu --prompt="control center > " 2>/dev/null)

case "$CHOICE" in
    *"Wi-Fi"*)        "$SCRIPTS/wifi-menu.sh" ;;
    *"Bluetooth"*)    "$SCRIPTS/bluetooth-menu.sh" ;;
    *"Brightness"*)   brightnessctl set +10% ;;
    *"Sound"*)        pavucontrol ;;
    *"Focus"*)        toggle_dnd ;;
    *"Displays"*)     rice-display ;;
    *"Music"*)        playerctl play-pause ;;
    *"Rice Theme"*)   rice-theme-switch menu ;;
    *"Wallpaper"*)    rice-wallpaper next ;;
    *"Power"*)        "$SCRIPTS/power-menu.sh" ;;
esac

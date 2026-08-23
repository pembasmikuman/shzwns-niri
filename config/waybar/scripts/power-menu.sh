#!/usr/bin/env bash
# ──────────────────────────────────────────────
#   Power / Controls Menu (niri port)
#   origin: okyashgajjar/low-sepecs-hyprland-dotfiles
# ──────────────────────────────────────────────

pick() {
    fuzzel --dmenu --prompt="$1" 2>/dev/null
}

build_menu() {
    echo "󰌾  Lock"
    echo "󰍃  Logout"
    echo "󰤄  Suspend"
    echo "󰜉  Reboot"
    echo "󰐥  Shutdown"
}

confirm_action() {
    local action="$1"
    local choice
    choice=$(printf "  Yes, %s\n󰅙  Cancel" "$action" | pick " Confirm? > ")

    [[ "$choice" == *"Yes"* ]] && return 0 || return 1
}

handle_selection() {
    local choice="$1"

    case "$choice" in
        "󰌾  Lock")
            rice-lock & disown ;;

        "󰍃  Logout")
            if confirm_action "logout"; then
                niri msg action quit
            fi ;;

        "󰤄  Suspend")
            if confirm_action "suspend"; then
                systemctl suspend
            fi ;;

        "󰜉  Reboot")
            if confirm_action "reboot"; then
                systemctl reboot
            fi ;;

        "󰐥  Shutdown")
            if confirm_action "shutdown"; then
                systemctl poweroff
            fi ;;
    esac
}

main() {
    local menu
    menu=$(build_menu)

    local choice
    choice=$(echo "$menu" | pick " Controls > ")

    [[ -z "$choice" ]] && exit 0

    handle_selection "$choice"
}

main

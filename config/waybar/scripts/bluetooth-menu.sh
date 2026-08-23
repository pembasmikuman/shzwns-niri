#!/usr/bin/env bash
# ──────────────────────────────────────────────
#   Bluetooth Menu for Waybar (niri port: fuzzel + bluetoothctl)
#   origin: okyashgajjar/low-sepecs-hyprland-dotfiles
# ──────────────────────────────────────────────
DIVIDER="────────────────────────────"

notify() {
    notify-send -a "Bluetooth" -i bluetooth "$1" "$2" -t 4000
}

pick() {
    fuzzel --dmenu --prompt="$1" 2>/dev/null
}

# ── Get bluetooth state ──────────────────────
get_state() {
    BT_POWERED=$(bluetoothctl show 2>/dev/null | grep -i "Powered:" | awk '{print $2}')
    BT_SCANNING=$(bluetoothctl show 2>/dev/null | grep -i "Discovering:" | awk '{print $2}')
}

get_connected() {
    bluetoothctl devices Connected 2>/dev/null | cut -d' ' -f3-
}

get_paired() {
    bluetoothctl devices Paired 2>/dev/null
}

# ── Build main menu ──────────────────────────
build_menu() {
    get_state

    if [[ "$BT_POWERED" != "yes" ]]; then
        echo "󰂲  Bluetooth is OFF"
        echo "$DIVIDER"
        echo "󰂯  Turn Bluetooth ON"
        return
    fi

    local connected
    connected=$(get_connected)
    if [[ -n "$connected" ]]; then
        echo "󰂱  Connected: $connected"
    else
        echo "󰂯  Bluetooth ON — no devices"
    fi
    echo "$DIVIDER"

    echo "󰑐  Scan for devices"
    echo "$DIVIDER"

    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        local mac name
        mac=$(echo "$line" | awk '{print $2}')
        name=$(echo "$line" | cut -d' ' -f3-)
        [[ -z "$name" ]] && name="$mac"

        local info
        info=$(bluetoothctl info "$mac" 2>/dev/null)
        local is_connected
        is_connected=$(echo "$info" | grep -i "Connected:" | awk '{print $2}')
        local icon_type
        icon_type=$(echo "$info" | grep -i "Icon:" | awk '{print $2}')

        local icon="󰂱"
        case "$icon_type" in
            audio*|headset|headphones) icon="󰋋" ;;
            input-keyboard)           icon="󰌌" ;;
            input-mouse)              icon="󰍽" ;;
            input-gaming)             icon="󰊗" ;;
            phone)                    icon="󰏲" ;;
            computer)                 icon="󰍹" ;;
        esac

        if [[ "$is_connected" == "yes" ]]; then
            echo "$icon  $name  ✓"
        else
            echo "$icon  $name"
        fi
    done < <(get_paired)

    if [[ "$BT_SCANNING" == "yes" ]]; then
        local scan_results
        scan_results=$(bluetoothctl devices 2>/dev/null)
        local paired_macs
        paired_macs=$(get_paired | awk '{print $2}')

        while IFS= read -r line; do
            [[ -z "$line" ]] && continue
            local mac name
            mac=$(echo "$line" | awk '{print $2}')
            name=$(echo "$line" | cut -d' ' -f3-)

            echo "$paired_macs" | grep -q "$mac" && continue
            [[ "$name" == "$mac" ]] && continue

            echo "󰂳  $name"
        done <<< "$scan_results"
    fi

    echo "$DIVIDER"

    if [[ -n "$(get_connected)" ]]; then
        echo "󰂲  Disconnect all"
    fi
    echo "󰂲  Turn Bluetooth OFF"
}

# ── Handle selection ─────────────────────────
handle_selection() {
    local choice="$1"

    case "$choice" in
        "󰂱  Connected:"*|"󰂯  Bluetooth ON"*|"󰂲  Bluetooth is OFF"|"$DIVIDER")
            return ;;

        "󰂯  Turn Bluetooth ON")
            bluetoothctl power on 2>/dev/null
            notify "Bluetooth ON" "Bluetooth radio enabled"
            sleep 1
            main ;;

        "󰂲  Turn Bluetooth OFF")
            bluetoothctl power off 2>/dev/null
            notify "Bluetooth OFF" "Bluetooth radio disabled" ;;

        "󰑐  Scan for devices")
            notify "Scanning…" "Looking for nearby devices"
            bluetoothctl --timeout 8 scan on 2>/dev/null &
            sleep 5
            main ;;

        "󰂲  Disconnect all")
            while IFS= read -r line; do
                [[ -z "$line" ]] && continue
                local mac
                mac=$(echo "$line" | awk '{print $2}')
                bluetoothctl disconnect "$mac" 2>/dev/null
            done < <(bluetoothctl devices Connected 2>/dev/null)
            notify "Disconnected" "All devices disconnected" ;;

        *)
            local name
            name=$(echo "$choice" | sed 's/^[^ ]* *//' | sed 's/  ✓$//')

            if [[ -z "$name" ]]; then
                return
            fi

            local mac
            mac=$(bluetoothctl devices 2>/dev/null | grep "$name" | head -1 | awk '{print $2}')

            if [[ -z "$mac" ]]; then
                notify "Error" "Could not find device: $name"
                return
            fi

            local info is_connected is_paired
            info=$(bluetoothctl info "$mac" 2>/dev/null)
            is_connected=$(echo "$info" | grep -i "Connected:" | awk '{print $2}')
            is_paired=$(echo "$info" | grep -i "Paired:" | awk '{print $2}')

            if [[ "$is_connected" == "yes" ]]; then
                local action
                action=$(printf "%s\n%s\n%s" \
                    "󰅙  Disconnect" \
                    "󰆴  Remove (unpair)" \
                    "⬅  Back" \
                    | pick " $name > ")

                case "$action" in
                    "󰅙  Disconnect")
                        bluetoothctl disconnect "$mac" 2>/dev/null
                        notify "Disconnected" "$name disconnected" ;;
                    "󰆴  Remove (unpair)")
                        bluetoothctl remove "$mac" 2>/dev/null
                        notify "Removed" "$name has been unpaired" ;;
                    "⬅  Back")
                        main ;;
                esac
            elif [[ "$is_paired" == "yes" ]]; then
                local action
                action=$(printf "%s\n%s\n%s" \
                    "󰂱  Connect" \
                    "󰆴  Remove (unpair)" \
                    "⬅  Back" \
                    | pick " $name > ")

                case "$action" in
                    "󰂱  Connect")
                        notify "Connecting…" "Connecting to $name"
                        if bluetoothctl connect "$mac" 2>/dev/null; then
                            sleep 2
                            local check
                            check=$(bluetoothctl info "$mac" 2>/dev/null | grep "Connected:" | awk '{print $2}')
                            if [[ "$check" == "yes" ]]; then
                                notify "Connected ✓" "Successfully connected to $name"
                            else
                                notify "Failed ✗" "Could not connect to $name"
                            fi
                        else
                            notify "Failed ✗" "Could not connect to $name"
                        fi ;;
                    "󰆴  Remove (unpair)")
                        bluetoothctl remove "$mac" 2>/dev/null
                        notify "Removed" "$name has been unpaired" ;;
                    "⬅  Back")
                        main ;;
                esac
            else
                notify "Pairing…" "Pairing with $name"
                bluetoothctl pair "$mac" 2>/dev/null
                sleep 3
                local pair_check
                pair_check=$(bluetoothctl info "$mac" 2>/dev/null | grep "Paired:" | awk '{print $2}')
                if [[ "$pair_check" == "yes" ]]; then
                    bluetoothctl trust "$mac" 2>/dev/null
                    notify "Connecting…" "Paired! Connecting to $name"
                    bluetoothctl connect "$mac" 2>/dev/null
                    sleep 2
                    local conn_check
                    conn_check=$(bluetoothctl info "$mac" 2>/dev/null | grep "Connected:" | awk '{print $2}')
                    if [[ "$conn_check" == "yes" ]]; then
                        notify "Connected ✓" "Successfully connected to $name"
                    else
                        notify "Paired ✓" "Paired but couldn't auto-connect to $name"
                    fi
                else
                    notify "Failed ✗" "Could not pair with $name"
                fi
            fi
            ;;
    esac
}

# ── Main ─────────────────────────────────────
main() {
    local menu
    menu=$(build_menu)

    local choice
    choice=$(echo "$menu" | pick " Bluetooth > ")

    [[ -z "$choice" ]] && exit 0

    handle_selection "$choice"
}

main

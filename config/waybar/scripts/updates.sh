#!/usr/bin/env bash
# Check for updates (pacman + AUR), JSON-safe output
PACMAN_UPDATES=$(checkupdates 2>/dev/null)
AUR_UPDATES=$(yay -Qua 2>/dev/null)

PACMAN_COUNT=$(echo "$PACMAN_UPDATES" | grep -c '[^[:space:]]')
AUR_COUNT=$(echo "$AUR_UPDATES" | grep -c '[^[:space:]]')

TOTAL_COUNT=$((PACMAN_COUNT + AUR_COUNT))

python3 - "$TOTAL_COUNT" "$PACMAN_COUNT" "$AUR_COUNT" <<'PY'
import json, subprocess, sys

total, pc, ac = int(sys.argv[1]), int(sys.argv[2]), int(sys.argv[3])

if total > 0:
    pacman = subprocess.run(["checkupdates"], capture_output=True, text=True).stdout.strip()
    aur = subprocess.run(["yay", "-Qua"], capture_output=True, text=True).stdout.strip()

    lines = [f"Pacman Updates ({pc}):"]
    if pacman:
        lines += pacman.split("\n")
    lines.append("")
    lines.append(f"AUR Updates ({ac}):")
    if aur:
        lines += aur.split("\n")

    print(json.dumps({"text": str(total), "tooltip": "\n".join(lines), "class": "updates-available"}))
PY

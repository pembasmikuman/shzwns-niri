#!/usr/bin/env bash
set -euo pipefail
DOT="$(dirname "$0")"
chmod +x "$DOT/install.sh" "$DOT/sync.sh"
git init -b main -C "$DOT"
git -C "$DOT" add -A
git -C "$DOT" -c user.name="${GIT_AUTHOR_NAME:-yg}" -c user.email="${GIT_AUTHOR_EMAIL:-yg@users.noreply.github.com}" \
    commit -m "niri rice: dynamic-island waybar, matugen wallpaper theming, light stack (~230MB)"
echo "--- repo ready: $DOT ---"
git -C "$DOT" log --oneline

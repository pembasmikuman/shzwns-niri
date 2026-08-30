#!/usr/bin/env bash
# ──────────────────────────────────────────────
#   Cycle power-profiles-daemon profile
# ──────────────────────────────────────────────

current=$(powerprofilesctl get)

case "$current" in
    performance) next="power-saver" ;;
    balanced)    next="performance" ;;
    power-saver) next="balanced" ;;
    *)           next="balanced" ;;
esac

powerprofilesctl set "$next"

#!/bin/bash
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
STATE_FILE="$HOME/.config/awww/wallpaper-state"
OUTPUT="$HOME/.config/hyprlock/current-wallpaper"

CURRENT_INDEX=$(cat "$STATE_FILE" 2>/dev/null || echo 0)
mapfile -t WALLPAPERS < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \) | sort)
NEXT_WALLPAPER="${WALLPAPERS[$CURRENT_INDEX]}"

echo "$NEXT_WALLPAPER" > "$OUTPUT"

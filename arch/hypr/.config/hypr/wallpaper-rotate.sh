#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
CONFIG_DIR="$HOME/.config/awww"
STATE_FILE="$CONFIG_DIR/wallpaper-state"

if [ ! -f "$STATE_FILE" ]; then
    CURRENT_INDEX=0
    echo "$CURRENT_INDEX" > "$STATE_FILE"
else
    CURRENT_INDEX=$(cat "$STATE_FILE")
fi

mapfile -t WALLPAPERS < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \) | sort)
TOTAL=${#WALLPAPERS[@]}

if [ $TOTAL -eq 0 ]; then
    echo "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

NEXT_INDEX=$(( (CURRENT_INDEX + 1) % TOTAL ))
NEXT_WALLPAPER="${WALLPAPERS[$NEXT_INDEX]}"

echo "$NEXT_INDEX" > "$STATE_FILE"

awww img "$NEXT_WALLPAPER" --transition-type any --transition-fps 60 --transition-duration 1 --resize crop

# Update hyprlock wallpaper path
echo "$NEXT_WALLPAPER" > "$HOME/.config/hyprlock/current-wallpaper"
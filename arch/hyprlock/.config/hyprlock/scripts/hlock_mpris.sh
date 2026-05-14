#!/bin/env bash

THUMB="/tmp/hyde-mpris"
THUMB_BLURRED="/tmp/hyde-mpris-blurred"
ART_INFO="${THUMB}.inf"

PLAYERS="spotify,ncspot,spotifyd,%any"

cleanup() {
    rm -f "${THUMB}"* "${THUMB_BLURRED}.png" "${ART_INFO}"
}

fetch_thumb() {
    status=$(playerctl -p "$PLAYERS" status 2>/dev/null) || { cleanup; exit 1; }
    [[ -z "$status" ]] && { cleanup; exit 1; }

    artUrl=$(playerctl -p "$PLAYERS" metadata --format '{{mpris:artUrl}}' 2>/dev/null)
    [[ -z "$artUrl" ]] && exit 1

    [[ -f "$ART_INFO" && "$(cat "$ART_INFO")" == "$artUrl" ]] && return 0
    echo "$artUrl" > "$ART_INFO"

    curl -sS "$artUrl" -o "${THUMB}.png" || exit 1
    magick "${THUMB}.png" -quality 50 "${THUMB}.png"

    magick "${THUMB}.png" -blur 200x7 -resize 1920x^ -gravity center -extent 1920x1080 "${THUMB_BLURRED}.png"

    pkill -USR2 hyprlock
}

for cmd in playerctl curl magick pkill; do
    command -v "$cmd" &>/dev/null || { echo "Error: $cmd is required but not installed."; exit 1; }
done

playerctl -p "$PLAYERS" status &>/dev/null && { 
    playerctl -p "$PLAYERS" metadata --format '{{title}}  {{artist}}' && fetch_thumb 
} || cleanup &

exit 0

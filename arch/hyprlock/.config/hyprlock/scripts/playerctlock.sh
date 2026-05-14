#!/bin/env bash

THUMB=/tmp/hyde-mpris
THUMB_BLURRED=/tmp/hyde-mpris-blurred
PLAYERS="spotify,ncspot,spotifyd,%any"

if [ $# -eq 0 ]; then
    echo "Usage: $0 --title | --arturl | --artist | --position | --length | --album | --source"
    exit 1
fi

get_metadata() {
    key=$1
    playerctl -p "$PLAYERS" metadata --format "{{ $key }}" 2>/dev/null
}

get_source_info() {
    trackid=$(get_metadata "mpris:trackid")
    if [[ "$trackid" == *"spotify"* ]]; then
        echo -e "Spotify "
    elif [[ "$trackid" == *"ncspot"* ]]; then
        echo -e "ncspot "
    else
        echo ""
    fi
}

get_position() {
    playerctl -p "$PLAYERS" position 2>/dev/null
}

convert_length() {
    local length=$1
    local seconds=$((length / 1000000))
    local minutes=$((seconds / 60))
    local remaining_seconds=$((seconds % 60))
    printf "%d:%02d min" $minutes $remaining_seconds
}

convert_position() {
    local position=$1
    local seconds=${position%.*}
    local minutes=$((seconds / 60))
    local remaining_seconds=$((seconds % 60))
    printf "%d:%02d" $minutes $remaining_seconds
}

fetch_thumb() {
    artUrl=$(playerctl -p "$PLAYERS" metadata --format '{{mpris:artUrl}}') 
    [[ "${artUrl}" = "$(cat "${THUMB}.inf")" ]] && return 0

    printf "%s\n" "$artUrl" > "${THUMB}.inf"

    curl -so "${THUMB}.png" "$artUrl"
    magick "${THUMB}.png" -quality 50 "${THUMB}.png"
    magick "${THUMB}.png" -blur 200x7 -resize 1920x^ -gravity center -extent 1920x1080\! "${THUMB_BLURRED}.png"

    pkill -USR2 hyprlock
}

playerctl -p "$PLAYERS" status &>/dev/null || exit 1

{ fetch_thumb ;} || { rm -f "${THUMB}*" && exit 1;} &

case "$1" in
--title)
    title=$(get_metadata "xesam:title")
    if [ -z "$title" ]; then
        echo ""
    else
        echo "${title:0:20}"
    fi
    ;;
--artist)
    artist=$(get_metadata "xesam:artist")
    if [ -z "$artist" ]; then
        echo ""
    else
        echo "${artist:0:20}"
    fi
    ;;
--position)
    position=$(get_position)
    length=$(get_metadata "mpris:length")
    if [ -z "$position" ] || [ -z "$length" ]; then
        echo ""
    else
        position_formatted=$(convert_position "$position")
        length_formatted=$(convert_length "$length")
        echo "$position_formatted/$length_formatted"
    fi
    ;;
--length)
    length=$(get_metadata "mpris:length")
    if [ -z "$length" ]; then
        echo ""
    else
        convert_length "$length"
    fi
    ;;
--status)
    status=$(playerctl -p "$PLAYERS" status 2>/dev/null)
    if [[ $status == "Playing" ]]; then
        echo "⏸"
    elif [[ $status == "Paused" ]]; then
        echo "▶"
    else
        echo ""
    fi
    ;;
--album)
    album=$(playerctl -p "$PLAYERS" metadata --format "{{ xesam:album }}" 2>/dev/null)
    if [[ -n $album ]]; then
        echo "$album"
    else
        status=$(playerctl -p "$PLAYERS" status 2>/dev/null)
        if [[ -n $status ]]; then
            echo "Not album"
        else
            echo ""
        fi
    fi
    ;;
--source)
    get_source_info
    ;;
*)
    echo "Invalid option: $1"
    echo "Usage: $0 --title | --arturl | --artist | --position | --length | --album | --source"
    exit 1
    ;;
esac

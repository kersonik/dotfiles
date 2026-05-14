#!/bin/bash
nohup playerctl -p spotify,ncspot,%any play-pause >/dev/null 2>&1 &
disown
exit 0

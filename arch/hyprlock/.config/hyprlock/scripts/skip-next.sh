#!/bin/bash
nohup playerctl -p spotify,ncspot,%any next >/dev/null 2>&1 &
disown
exit 0

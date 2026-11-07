#!/bin/bash
if iw dev wlo1 set power_save off 2>/dev/null; then
    :
fi

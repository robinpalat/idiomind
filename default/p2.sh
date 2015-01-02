#!/bin/bash
# -*- ENCODING: UTF-8 -*-

u=$(echo "$(whoami)")
nmt=$(sed -n 1p /tmp/.idmtp1.$u/idmimp_X015x/ls)
dir="/tmp/.idmtp1.$u/idmimp_X015x/$nmt"
wdr=$(echo "$1" | awk '{print tolower($0)}')
play "$dir/.audio/$wdr.mp3"
exit 1

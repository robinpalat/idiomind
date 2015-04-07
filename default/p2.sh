#!/bin/bash
# -*- ENCODING: UTF-8 -*-

u=$(echo "$(whoami)")
nmt=$(sed -n 1p "/tmp/.idmtp1.$u/dir$1/ls")
dir="/tmp/.idmtp1.$u/dir$1/$nmt"
play "$dir/audio/${2,,}.mp3"
exit 1

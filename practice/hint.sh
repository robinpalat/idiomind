#!/bin/bash
# -*- ENCODING: UTF-8 -*-

echo "$1" | awk '{print tolower($0)}' | sed "s/\'//g" | sed "s/\b\(.\)/\u\1/g" \
| sed "s|\.||; s|\,||; s|\;||g" | sed "s|[a-z]|"\."|g" | sed "s| |\t|g" \
| sed "s|\.|\ .|g" | tr "[:upper:]" "[:lower:]" | sed 's/^\s*./\U&\E/g' | \
yad --center --text-info --skip-taskbar \
--justify=left --margins=15 --fontname="Free Sans 15"  \
--buttons-layout=end --borders=0 --wrap --title=" " \
--text-align=center --height=150 --width=460 \
--on-top --align=center --window-icon=idiomind \
--no-buttons & exit

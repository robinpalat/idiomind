#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
eyeD3 "$DM_tlt/$(sed -n "$1"p lsin)".mp3 | \
grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)' \
| awk '{print tolower($0)}' | sed "s/\b\(.\)/\u\1/g" \
| sed "s|\.||; s|\,||; s|\;||g" | sed "s|[a-z]|"\."|g" | sed "s| |\t|g" \
| sed "s|\.|\ .|g" | yad --center --text-info --skip-taskbar \
--justify=left --margins=15 --fontname="Verdana Black" \
--buttons-layout=end --borders=0 --wrap --title=" " \
--text-align=center --height=150 --width=460 \
--on-top --align=center --window-icon=idiomind \
--no-buttons & exit

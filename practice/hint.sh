#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
s1=$(sed -n "$1"p lsin)
prsw=$(eyeD3 "$DM_tlt/$s1".mp3 | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)' \
| awk '{print tolower($0)}' | sed "s/\b\(.\)/\u\1/g" \
| sed "s|[a-z]|"\*"|g" | sed "s| |\t|g")
echo "$prsw" | yad --center --text-info --skip-taskbar \
--justify=left --margins=5 --fontname=verdana \
--buttons-layout=end --borders=0 --wrap --title=" " \
--text-align=center --height=180 --width=460 \
--on-top --align=center --window-icon=idiomind \
--button="gtk-close:0" &

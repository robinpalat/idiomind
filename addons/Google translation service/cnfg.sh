#!/bin/bash
# -*- ENCODING: UTF-8 -*-
source /usr/share/idiomind/ifs/c.conf

if [ ! -f "$DC_a/gts.cfg" ] || [ -z "$(< "$DC_a/gts.cfg")" ]; then
echo -e "set1=\"\"" > "$DC_a/gts.cfg"
echo -e "key=\"\"" >> "$DC_a/gts.cfg";fi
source "$DC_a/gts.cfg"

c=$(yad --center --form --on-top --name=Idiomind \
--skip-taskbar --borders=10 --expand-column=3 --no-headers \
--text="Google Translate" \
--button="$(gettext "Cancel")":0 --button="$(gettext "OK")":0 \
--width=450 --height=300 --class=Idiomind \
--always-print-result --editable --print-all \
--title="Google translation service" --window-icon=idiomind \
--field="$(gettext "Enable")":CHK "$set1" \
--field="$(gettext "Key (optional)")":TXT "$key" \
--field="\n<a href='http://translate.google.com/community?source=all'>\
$(gettext "Help improve Google Translate")</a>\n\n":LBL " ")
val1="$(cut -d "|" -f1 <<< "$c")"
val2="$(cut -d "|" -f2 <<< "$c")"
sed -i "s/set1=.*/set1=\"$val1\"/g" "$DC_a/gts.cfg"
sed -i "s/key=.*/key=\"$val2\"/g" "$DC_a/gts.cfg"




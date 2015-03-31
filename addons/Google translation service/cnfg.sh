#!/bin/bash
# -*- ENCODING: UTF-8 -*-
source /usr/share/idiomind/ifs/c.conf

if [ ! -f "$DC_a/gts.cfg" ] || [ -z "$(< "$DC_a/gts.cfg")" ]; then
echo -e "set1=\"\"" > "$DC_a/gts.cfg"
echo -e "key=\"\"" >> "$DC_a/gts.cfg";fi
source "$DC_a/gts.cfg"

c=$(yad --center --form --on-top --name=Idiomind --class=Idiomind \
--skip-taskbar --borders=10 --expand-column=3 --no-headers \
--button="$(gettext "OK")":0 --width=480 --height=320 \
--always-print-result --editable --print-all \
--title="Google translation service" --window-icon=idiomind \
--field="\n$(gettext "Enable translator")\n":CHK "$set1" \
--field="$(gettext "Key (optional)")"::TXT "$key" \
--field="\n\n\n\n":LBL " ")
val1="$(cut -d "|" -f1 <<< "$c")"
val2="$(cut -d "|" -f2 <<< "$c")"
sed -i "s/set1=.*/set1=\"$val1\"/g" "$DC_a/gts.cfg"
sed -i "s/key=.*/key=\"$val2\"/g" "$DC_a/gts.cfg"


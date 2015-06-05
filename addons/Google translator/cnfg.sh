#!/bin/bash
# -*- ENCODING: UTF-8 -*-

[ -z "$DM" ] && source /usr/share/idiomind/ifs/c.conf
if [ ! -f "$DC_a/gts.cfg" ] \
|| [ -z "$(< "$DC_a/gts.cfg")" ]; then
echo -e "set1=\"\"" > "$DC_a/gts.cfg"
echo -e "key=\"\"" >> "$DC_a/gts.cfg";fi

set1=$(sed -n 1p < "$DC_a/gts.cfg" \
| grep -o set1=\"[^\"]* | grep -o '[^"]*$')
key=$(sed -n 2p < "$DC_a/gts.cfg" \
| grep -o key=\"[^\"]* | grep -o '[^"]*$')

c=$(yad --form --title="$(gettext "Google Translate")" \
--name=Idiomind --class=Idiomind \
--window-icon="$DS/images/icon.png" --center \
--on-top --skip-taskbar --expand-column=3 \
--width=450 --height=300 --borders=10 \
--always-print-result --editable --print-all \
--field="$(gettext "Enable online translator")":CHK "$set1" \
--field="$(gettext "Key (optional)")":TXT "$key" \
--field="\n<a href='http://translate.google.com/community?source=all'>\
$(gettext "Help improve Google Translate")</a>\n\n":LBL " " \
--button="$(gettext "Cancel")":1 \
--button="$(gettext "OK")":0)

if [ $? = 0 ]; then
val1="$(cut -d "|" -f1 <<< "$c")"
val2="$(cut -d "|" -f2 <<< "$c")"
sed -i "s/set1=.*/set1=\"$val1\"/g" "$DC_a/gts.cfg"
sed -i "s/key=.*/key=\"$val2\"/g" "$DC_a/gts.cfg"
fi




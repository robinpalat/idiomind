#!/bin/bash

DC_a="$HOME/.config/idiomind/addons"

if [ ! -e "$DC_d/Google translate.Traslator online.Translator.various" ]; then set1=FALSE
elif [ -e "$DC_d/Google translate.Traslator online.Translator.various" ]; then set1=TRUE; fi

if [ ! -f "$DC_a/gts.cfg" ] || [[ -z "$(< "$DC_a/gts.cfg")" ]]; then
echo -e "key=\"\"" > "$DC_a/gts.cfg"; fi

key=$(grep -o key=\"[^\"]* "$DC_a/gts.cfg" |grep -o '[^"]*$')
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
ret=$?

if [ $ret = 0 ]; then
val1="$(cut -d "|" -f1 <<<"$c")"
val2="$(cut -d "|" -f2 <<<"$c")"

if [ ${val1} = TRUE -a ! -e "$DC_d/Google translate.Traslator online.Translator.various" ]; then
mv -f "$DC_a/dict/disables/Google translate.Traslator online.Translator.various" \
"$DC_d/Google translate.Traslator online.Translator.various"
elif [ ${val1} = FALSE -a -e "$DC_d/Google translate.Traslator online.Translator.various" ]; then
mv -f "$DC_d/Google translate.Traslator online.Translator.various" \
"$DC_a/dict/disables/Google translate.Traslator online.Translator.various"; fi

sed -i "s/key=.*/key=\"$val2\"/g" "$DC_a/gts.cfg"
fi




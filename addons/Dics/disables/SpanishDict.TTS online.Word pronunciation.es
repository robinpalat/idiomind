#!/bin/bash

if [[ "$1" = dlgcnfg ]]; then
yad --form --title="Spanishdict" \
--image=info \
--text="$(gettext "Does not need configuration.")\n" \
--name=Idiomind --class=Idiomind \
--window-icon="$DS/images/icon.png" --center \
--on-top --skip-taskbar --expand-column=3 \
--width=400 --height=120 --borders=5 \
--always-print-result --editable --print-all \
--button="$(gettext "OK")":1
ret=$?
if [ $ret = 0 ]; then
echo
fi

else
name="spanishdict"
lang="es"

wget -O ./"${1}.mp3" -q -U Mozilla "http://audio1.spanishdict.com/audio?lang=es&text=${1}"

exit
fi



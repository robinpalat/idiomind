#!/bin/bash
topic=$(sed -n 1p ~/.config/idiomind/s/cnfg8)
lngt=$(sed -n 2p ~/.config/idiomind/s/cnfg9)
lngs=$(sed -n 2p ~/.config/idiomind/s/cnfg10)

if [[ "$(ps -A | grep -o "sntnc.sh")" = "sntnc.sh" ]]; then
/usr/share/idiomind/audio/wrds.sh "$1"
else
/usr/share/idiomind/audio/sntnc.sh "$1"
fi

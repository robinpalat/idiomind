#!/bin/bash
if [ -d $HOME/.idiomind/ ]; then

topic=$(sed -n 1p ~/.config/idiomind/topic.id)
lang=$(sed -n 1p ~/.config/idiomind/lang)
lnglbl=$(sed -n 2p ~/.config/idiomind/lang)
TPC=$(sed -n 2p ~/.config/idiomind/topic.id)
topic_n_e=$(sed -n 1p ~/.config/idiomind/fnew.id)
DIR2="$HOME/.config/idiomind/topics/$lnglbl/$topic_n_e"

cd ~/.idiomind/topics/"$lnglbl"
ls * -d > /tmp/ttpp_xxx
var1=$(cat /tmp/ttpp_xxx | wc -l)
rm -f /tmp/ttpp_xxx

if [ $var1 -lt 1 ]; then
/usr/share/idiomind/ifs/notpc1.sh & exit
fi

#if [ -n "$topic_n_e" ]; then
#echo o
#else
#/usr/share/idiomind/ifs/notpc.sh & exit;
#fi

if [ -d "$DIR2" ]; then
echo ok
else
/usr/share/idiomind/ifs/notpc.sh & exit;
fi

yad --geometry=185x318-120-420 --width=160 \
	--height=220 --fixed --title=" Idiomind" --no-buttons \
	--window-icon=/usr/share/idiomind/icon/icon.png \
	--icons --single-click \
	--on-top --borders=0 \
	--read-dir=/usr/share/idiomind/default/new --item-width=60
rm "$DIR2"/lstntry

else
/usr/share/idiomind/ifs/1u
fi

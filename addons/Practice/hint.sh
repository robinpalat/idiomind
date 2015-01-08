#!/bin/bash
tpc=$(sed -n 1p ~/.config/idiomind/s/cnfg8)
lgtl=$(sed -n 2p ~/.config/idiomind/s/cnfg10)
drtt="$HOME/.idiomind/topics/$lgtl/$tpc/"
drtc="$HOME/.config/idiomind/topics/$lgtl/$tpc/Practice"
drts="/usr/share/idiomind/addons/Practice/"

s1=$(sed -n "$1"p lsin)

prsw=$(eyeD3 "$drtt/$s1".mp3 | \
		grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)' \
		| awk '{print tolower($0)}' \
		| sed "s/\b\(.\)/\u\1/g" \
		| sed "s|[a-z]|._|g" | tr ".?!;," ' ')

yad --center --text="<b><big>$prsw</big></b>" \
	--buttons-layout=end --borders=12 --title=" " \
	--skip-taskbar --text-align=center --height=180 --width=460 \
	--on-top --align=center --window-icon=idiomind \
	--button="gtk-close:0" &
	

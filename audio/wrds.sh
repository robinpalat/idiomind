#!/bin/bash
topic=$(sed -n 1p ~/.config/idiomind/s/cnfg8)
lngt=$(sed -n 2p ~/.config/idiomind/s/cnfg10)
lngs=$(sed -n 2p ~/.config/idiomind/s/cnfg9)
DIR1="$HOME/.idiomind/topics/$lngt/$topic"
SHR="$HOME/.idiomind/topics/$lngt/.share"
killall play

file="$DIR1/$1.mp3"
lwrd=$(eyeD3 "$file" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)' \
| awk '{print tolower($0)}' | tr ' ' '\n')
n=1
while [ $n -le "$(echo "$lwrd" | wc -l)" ]; do
	ply=$(echo "$lwrd" | sed -n "$n"p)
	play "$SHR/$ply.mp3"
	let n++
done
exit 1

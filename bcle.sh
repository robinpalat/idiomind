#!/bin/bash
# -*- ENCODING: UTF-8 -*-
source /usr/share/idiomind/ifs/c.conf
[ -z "$tpc" ] && exit 1
> $DT/.p__$user
cd $DT/.$user

if [ -n "$(cat ./indx)" ] && [ $(cat ./indx | wc -l) -gt 0 ]; then
	if [ "$(sed -n 8p $DC_s/cfg.5)" = "TRUE" ]; then
			echo "--repeat"
			while [ 1 ]
			do
			n=1
			while [ $n -le $(cat ./indx | wc -l) ]; do
			$DS/chng.sh chngi $n
			let n++
			done
			done
	else
		n=1
		while [ $n -le $(cat ./indx | wc -l) ]; do
		$DS/chng.sh chngi $n
			let n++
		done
		rm -fr $DT/.p__$user $DT/.$user
	fi
else
	
	notify-send -i idiomind "T" "D" -t 9000 &
	exit 1
fi

#!/bin/bash
# -*- ENCODING: UTF-8 -*-

uid=$(echo "$(whoami)")
DS=/usr/share/idiomind
> /tmp/.idmtp1.$uid/.p__$uid
cd /tmp/.idmtp1.$uid/.$uid

if [ "$(sed -n 7p $HOME/.config/idiomind/s/cnfg5)" = "TRUE" ] \
&& [ "$(cat ./indx | wc -l)" > 0 ]; then
	echo "--repeat active"
	while [ 1 ]
	do
	ls=$(cat ./indx | wc -l)
	n=1
	while [ $n -le "$ls" ]; do
	$DS/chng.sh chngi $n
	let n++
	done
	done
else
	ls=$(cat ./indx | wc -l)
	n=1
	while [ $n -le "$ls" ]; do
	$DS/chng.sh chngi $n
		let n++
	done
	rm -fr /tmp/.idmtp1.$uid/.p__$uid /tmp/.idmtp1.$uid/.$uid
fi

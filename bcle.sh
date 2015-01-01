#!/bin/bash
uid=$(echo "$(whoami)")
DS=/usr/share/idiomind
cnfg=$HOME/.config/idiomind/s/cnfg1
> /tmp/.idmtp1.$uid/.p__$uid
cd /tmp/.idmtp1.$uid/.$uid

if [ "$(sed -n 10p $cnfg)" = "TRUE" ]; then
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

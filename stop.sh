#!/bin/bash
user=$(echo "$(whoami)")

if echo "$1" | grep "P"; then
	killall run_all &
	killall chng &
	kill -9 $(pgrep -f "yad --form ")
	exit 1
	
elif echo "$1" | grep "S"; then
	killall run_all &
	killall notify-osd
	killall play
	killall p_lay
	killall chng &
	kill -9 $(pgrep -f "yad --form ")
	rm -f -r /tmp/.idmtp1/.idadtmptts_$user
	exit 1
	
elif echo "$1" | grep "V"; then
	killall chng &
	killall chng &
	kill -9 $(pgrep -f "yad --form ")
	exit 1

elif echo "$1" | grep "L"; then
	killall run_all &
	killall notify-osd
	killall play
	killall chng &
	kill -9 $(pgrep -f "yad --form ")
	rm -f -r /tmp/.idmtp1/.idadtmptts_$user
	exit 1
	
else
	killall run_all &
	killall notify-osd
	killall play
	killall chng &
	kill -9 $(pgrep -f "yad --form ")
	rm -f -r /tmp/.idmtp1/.idadtmptts_$user /tmp/.idmtp1/.p__$user
	exit 1
fi

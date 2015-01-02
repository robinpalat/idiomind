#!/bin/bash
user=$(echo "$(whoami)")

if echo "$1" | grep "P"; then
	killall bcle.sh &
	killall chng.sh &
	kill -9 $(pgrep -f "yad --form ")
	exit 1
	
elif echo "$1" | grep "S"; then
	killall bcle.sh &
	killall notify-osd
	killall play
	killall play.sh
	killall chng.sh &
	kill -9 $(pgrep -f "yad --form ")
	rm -f -r /tmp/.idmtp1.$user/.idadtmptts_$user
	exit 1
	
elif echo "$1" | grep "V"; then
	killall chng.sh &
	kill -9 $(pgrep -f "yad --form ")
	exit 1

elif echo "$1" | grep "L"; then
	killall bcle.sh &
	killall notify-osd
	killall play
	killall chng.sh &
	kill -9 $(pgrep -f "yad --form ")
	rm -f -r /tmp/.idmtp1.$user/.idadtmptts_$user
	exit 1
	
else
	killall bcle.sh &
	killall notify-osd
	killall play
	rm -f -r /tmp/.idmtp1.$user/.idadtmptts_$user /tmp/.idmtp1.$user/.p__$user
	exit 1
fi

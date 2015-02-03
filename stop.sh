#!/bin/bash

u=$(echo "$(whoami)")
if echo "$1" | grep "P"; then
	[[ -n "$(ps -A | pgrep -f "/usr/share/idiomind/bcle.sh")" ]] && killall bcle.sh &
	[[ -n "$(ps -A | pgrep -f "/usr/share/idiomind/chng.sh")" ]] && killall chng.sh &
	[[ -d $DT/.idadtmptts_$u ]] && rm -fr $DT/.idadtmptts_$u
	[[ -n "$(ps -A | pgrep -f "yad --form ")" ]] && kill -9 $(pgrep -f "yad --form ") &
	exit
elif echo "$1" | grep "S"; then
	[[ -n "$(ps -A | pgrep -f "/usr/share/idiomind/bcle.sh")" ]] && killall bcle.sh &
	[[ -n "$(ps -A | pgrep -f "notify-osd")" ]] && killall notify-osd &
	[[ -n "$(ps -A | pgrep -f "play")" ]] && killall play &
	[[ -n "$(ps -A | pgrep -f "/usr/share/idiomind/play.sh")" ]] && killall play.sh &
	[[ -n "$(ps -A | pgrep -f "/usr/share/idiomind/chng.sh")" ]] && killall chng.sh &
	[[ -n "$(ps -A | pgrep -f "yad --form ")" ]] && kill -9 $(pgrep -f "yad --form ") &
	[[ -d /tmp/.idmtp1.$u/.idadtmptts_$u ]] && rm -fr /tmp/.idmtp1.$u/.idadtmptts_$u
	exit
elif echo "$1" | grep "V"; then
	[[ -n "$(ps -A | pgrep -f "/usr/share/idiomind/chng.sh")" ]] && killall chng.sh &
	[[ -n "$(ps -A | pgrep -f "yad --form ")" ]] && kill -9 $(pgrep -f "yad --form ") &
	exit
elif echo "$1" | grep "L"; then
	[[ -n "$(ps -A | pgrep -f "/usr/share/idiomind/bcle.sh")" ]] && killall bcle.sh &
	[[ -n "$(ps -A | pgrep -f "notify-osd")" ]] && killall notify-osd &
	[[ -n "$(ps -A | pgrep -f "play")" ]] && killall play &
	[[ -n "$(ps -A | pgrep -f "/usr/share/idiomind/chng.sh")" ]] && killall chng.sh &
	[[ -n "$(ps -A | pgrep -f "yad --form ")" ]] && kill -9 $(pgrep -f "yad --form ") &
	[[ -d /tmp/.idmtp1.$u/.idadtmptts_$u ]] && rm -fr /tmp/.idmtp1.$u/.idadtmptts_$u
	exit
elif echo "$1" | grep "play"; then
	[[ -n "$(ps -A | pgrep -f "/usr/share/idiomind/bcle.sh")" ]] && killall bcle.sh &
	[[ -n "$(ps -A | pgrep -f "/usr/share/idiomind/chng.sh")" ]] && killall chng.sh &
	[[ -n "$(ps -A | pgrep -f "tls.sh")" ]] && killall tls.sh &
	[[ -n "$(ps -A | pgrep -f "notify-osd")" ]] && killall notify-osd &
	[[ -n "$(ps -A | pgrep -f "play")" ]] && killall play &
	[[ -d /tmp/.idmtp1.$u/.idadtmptts_$u ]] && rm -fr /tmp/.idmtp1.$u/.idadtmptts_$u
	[[ -f /tmp/.idmtp1.$u/.p__$u ]] && rm -fr /tmp/.idmtp1.$u/.p__$u
	exit
elif echo "$1" | grep "feed"; then
	[[ -n "$(ps -A | pgrep -f "rsstail")" ]] && killall rsstail &
	[[ -n "$(ps -A | pgrep -f "strt.sh")" ]] && killall strt.sh &
	exit
fi

#!/bin/bash
source /usr/share/idiomind/ifs/c.conf

if echo "$1" | grep "playm"; then
    killall bcle.sh &
    [ -n "$(ps -A | pgrep -f "/usr/share/idiomind/bcle.sh")" ] && killall bcle.sh &
    [ -n "$(ps -A | pgrep -f "chng.sh")" ] && killall chng.sh &
    [ -n "$(ps -A | pgrep -f "yad --form ")" ] && kill -9 $(pgrep -f "yad --form ") &
    exit
elif echo "$1" | grep "play"; then
    killall bcle.sh &
    [ -n "$(ps -A | pgrep -f "/usr/share/idiomind/bcle.sh")" ] && killall bcle.sh &
    [ -n "$(ps -A | pgrep -f "chng.sh")" ] && killall chng.sh &
    [ -n "$(ps -A | pgrep -f "tls.sh")" ] && killall tls.sh &
    [ -n "$(ps -A | pgrep -f "notify-osd")" ] && killall notify-osd &
    [ -n "$(ps -A | pgrep -f "play")" ] && killall play &
    [ -d "$DT/p" ] && rm -fr "$DT/p"
    [ -f "$DT/.p_" ] && rm -fr "$DT/.p_"
    exit
elif echo "$1" | grep "tpc"; then
    [ -n "$(ps -A | pgrep -f "bcle.sh")" ] && killall bcle.sh &
    [ -n "$(ps -A | pgrep -f "notify-osd")" ] && killall notify-osd &
    [ -n "$(ps -A | pgrep -f "play")" ] && killall play &
    [ -n "$(ps -A | pgrep -f "play.sh")" ] && killall play.sh &
    [ -n "$(ps -A | pgrep -f "chng.sh")" ] && killall chng.sh &
    exit
elif echo "$1" | grep "S"; then
    killall bcle.sh &
    [ -n "$(ps -A | pgrep -f "bcle.sh")" ] && killall bcle.sh &
    [ -n "$(ps -A | pgrep -f "notify-osd")" ] && killall notify-osd &
    [ -n "$(ps -A | pgrep -f "play")" ] && killall play &
    [ -n "$(ps -A | pgrep -f "play.sh")" ] && killall play.sh &
    [ -n "$(ps -A | pgrep -f "chng.sh")" ] && killall chng.sh &
    [ -n "$(ps -A | pgrep -f "yad --form ")" ] && kill -9 $(pgrep -f "yad --form ") &
    [ -d "$DT/p" ] && rm -fr "$DT/p"
    exit
elif echo "$1" | grep "V"; then
    [ -n "$(ps -A | pgrep -f "chng.sh")" ] && killall chng.sh &
    [ -n "$(ps -A | pgrep -f "yad --form ")" ] && kill -9 $(pgrep -f "yad --form ") &
    exit
elif echo "$1" | grep "L"; then
    killall bcle.sh &
    [ -n "$(ps -A | pgrep -f "/usr/share/idiomind/bcle.sh")" ] && killall bcle.sh &
    [ -n "$(ps -A | pgrep -f "notify-osd")" ] && killall notify-osd &
    [ -n "$(ps -A | pgrep -f "play")" ] && killall play &
    [ -n "$(ps -A | pgrep -f "chng.sh")" ] && killall chng.sh &
    [ -n "$(ps -A | pgrep -f "yad --form ")" ] && kill -9 $(pgrep -f "yad --form ") &
    [ -d "$DT/p" ] && rm -fr "$DT/p"
    exit
elif echo "$1" | grep "feed"; then
    [ -n "$(ps -A | pgrep -f "rsstail")" ] && killall rsstail &
    killall strt.sh &
    [ -f "$DT/.uptf" ] && rm -fr "$DT/.uptf"
    [ -f "$DT/.uptp" ] && rm -fr "$DT/.uptp"
    exit
fi

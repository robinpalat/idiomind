#!/bin/bash
[ -z "$DM" ] && source /usr/share/idiomind/ifs/c.conf

on_quit() {
    [ -n "$(ps -A | pgrep -f "/usr/share/idiomind/bcle.sh")" ] && killall bcle.sh &
    [ -n "$(ps -A | pgrep -f "/usr/share/idiomind/bcle.sh")" ] && killall bcle.sh &
    [ -n "$(ps -A | pgrep -f "chng.sh")" ] && killall chng.sh &
    [ -n "$(ps -A | pgrep -f "notify-osd")" ] && killall notify-osd &
    [ -n "$(ps -A | pgrep -f "play")" ] && killall play &
    [ -n "$(ps -A | pgrep -f "mplayer")" ] && killall mplayer &
    [ -f "$DT/.p_" ] && rm -fr "$DT/.p_" "$DT/tpp"
    exit
}

on_play() {
    killall bcle.sh &
    [ -n "$(ps -A | pgrep -f "/usr/share/idiomind/bcle.sh")" ] && killall bcle.sh &
    [ -n "$(ps -A | pgrep -f "/usr/share/idiomind/bcle.sh")" ] && killall bcle.sh &
    [ -n "$(ps -A | pgrep -f "chng.sh")" ] && killall chng.sh &
    [ -n "$(ps -A | pgrep -f "notify-osd")" ] && killall notify-osd &
    [ -n "$(ps -A | pgrep -f "play")" ] && killall play &
    [ -n "$(ps -A | pgrep -f "mplayer")" ] && killall mplayer &
    [ -f "$DT/.p_" ] && rm -fr "$DT/.p_" "$DT/tpp"
    exit
}

on_playm() {
    killall bcle.sh &
    [ -n "$(ps -A | pgrep -f "/usr/share/idiomind/bcle.sh")" ] && killall bcle.sh &
    [ -n "$(ps -A | pgrep -f "/usr/share/idiomind/bcle.sh")" ] && killall bcle.sh &
    [ -n "$(ps -A | pgrep -f "chng.sh")" ] && killall chng.sh &
    [ -f "$DT/.p_" ] && rm -fr "$DT/.p_" "$DT/tpp"
    exit
}

on_lang() {
    killall bcle.sh &
    [ -n "$(ps -A | pgrep -f "/usr/share/idiomind/bcle.sh")" ] && killall bcle.sh &
    [ -n "$(ps -A | pgrep -f "notify-osd")" ] && killall notify-osd &
    [ -n "$(ps -A | pgrep -f "play")" ] && killall play &
    [ -n "$(ps -A | pgrep -f "chng.sh")" ] && killall chng.sh &
    [ -d "$DT/p" ] && rm -fr "$DT/p"
    exit
}

on_add() {
    killall bcle.sh &
    [ -n "$(ps -A | pgrep -f "/usr/share/idiomind/add.sh")" ] && killall add.sh &
    [ -n "$(ps -A | pgrep -f "add.sh")" ] && killall add.sh &
    [ -n "$(ps -A | pgrep -f "mogrify")" ] && killall mogrify &
    [ -n "$(ps -A | pgrep -f "yad --progress")" ] && kill -9 $(pgrep -f "yad --progress") &
    [ -f "$DT/.n_s_pr" ] && rm -f "$DT/.n_s_pr"
    exit
}

on_addons() {
    killall strt.sh &
    [ -n "$(ps -A | pgrep -f "wget -q -c -T 51")" ] && kill -9 $(pgrep -f "wget -q -c -T 51") &
    [ -f "$DT/.uptp" ] && rm -fr "$DT/.uptp"
    exit
}

case "$1" in
    1)
    on_quit ;;
    2)
    on_play ;;
    3)
    on_playm ;;
    4)
    on_lang ;;
    5)
    on_add ;;
    6)
    on_addons ;;
esac

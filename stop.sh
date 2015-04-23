#!/bin/bash
[ -z "$DM" ] && source /usr/share/idiomind/ifs/c.conf

playm() {
    killall bcle.sh &
    [ -n "$(ps -A | pgrep -f "/usr/share/idiomind/bcle.sh")" ] && killall bcle.sh &
    [ -n "$(ps -A | pgrep -f "/usr/share/idiomind/bcle.sh")" ] && killall bcle.sh &
    [ -n "$(ps -A | pgrep -f "chng.sh")" ] && killall chng.sh &
    [ -f "$DT/.p_" ] && rm -fr "$DT/.p_" "$DT/tpp"
    exit
}

play() {
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

S() {
    killall bcle.sh &
    [ -n "$(ps -A | pgrep -f "bcle.sh")" ] && killall bcle.sh &
    [ -n "$(ps -A | pgrep -f "notify-osd")" ] && killall notify-osd &
    [ -n "$(ps -A | pgrep -f "play")" ] && killall play &
    [ -n "$(ps -A | pgrep -f "play.sh")" ] && killall play.sh &
    [ -n "$(ps -A | pgrep -f "chng.sh")" ] && killall chng.sh &
    exit
}

V() {
    [ -n "$(ps -A | pgrep -f "chng.sh")" ] && killall chng.sh &
    exit
}

L() {
    killall bcle.sh &
    [ -n "$(ps -A | pgrep -f "/usr/share/idiomind/bcle.sh")" ] && killall bcle.sh &
    [ -n "$(ps -A | pgrep -f "notify-osd")" ] && killall notify-osd &
    [ -n "$(ps -A | pgrep -f "play")" ] && killall play &
    [ -n "$(ps -A | pgrep -f "chng.sh")" ] && killall chng.sh &
    [ -d "$DT/p" ] && rm -fr "$DT/p"
    exit
}

add() {
    killall bcle.sh &
    [ -n "$(ps -A | pgrep -f "/usr/share/idiomind/add.sh")" ] && killall add.sh &
    [ -n "$(ps -A | pgrep -f "add.sh")" ] && killall add.sh &
    [ -n "$(ps -A | pgrep -f "mogrify")" ] && killall mogrify &
    [ -n "$(ps -A | pgrep -f "yad --progress")" ] && kill -9 $(pgrep -f "yad --progress") &
    [ -f "$DT/.n_s_pr" ] && rm -f "$DT/.n_s_pr"
    exit
}

feed() {
    killall strt.sh &
    [ -f "$DT/.uptp" ] && rm -fr "$DT/.uptp"
    exit
}

case "$1" in
    playm)
    playm ;;
    play)
    play ;;
    S)
    S ;;
    V)
    V ;;
    L)
    L ;;
    feed)
    feed ;;
esac

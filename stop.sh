#!/bin/bash

[ -z "$DM" ] && source /usr/share/idiomind/ifs/c.conf

on_quit() {
    if ps -A | pgrep -f "/usr/share/idiomind/bcle.sh"; then killall bcle.sh & fi
    if ps -A | pgrep -f "/usr/share/idiomind/bcle.sh"; then killall bcle.sh; fi
    if ps -A | pgrep -f "/usr/share/idiomind/chng.sh"; then killall chng.sh; fi
    if ps -A | pgrep -f "/usr/share/idiomind/mngr.sh"; then killall mngr.sh & fi
    if ps -A | pgrep -f "/usr/share/idiomind/vwr.sh"; then killall vwr.sh & fi
    if ps -A | pgrep -f "play"; then killall play & fi
    if ps -A | pgrep -f "mplayer"; then killall mplayer & fi
    if ps -A | pgrep -f "yad --notebook "; then
    kill -9 $(pgrep -f "yad --multi-progress ") &
    kill -9 $(pgrep -f "yad --list ") &
    kill -9 $(pgrep -f "yad --text-info ") &
    kill -9 $(pgrep -f "yad --form ") &
    kill -9 $(pgrep -f "yad --notebook ") & fi
    if [ -f /tmp/.clipw ]; then
    kill "$(< /tmp/.clipw)"; rm -f /tmp/.clipw; fi
    if [ -f "$DT/.p_" ]; then
    #notify-send "$(gettext "Playback stopped")"
    rm -f "$DT/.p_" "$DT/tpp"
    rm -f "$DT/index.m3u"; fi
    exit
}

on_play() {
    killall bcle.sh &
    if ps -A | pgrep -f "/usr/share/idiomind/bcle.sh"; then killall bcle.sh & fi
    if ps -A | pgrep -f "/usr/share/idiomind/chng.sh"; then killall chng.sh; fi
    if ps -A | pgrep -f "notify-osd"; then (sleep 6 && killall notify-osd) & fi
    if ps -A | pgrep -f "play"; then killall play & fi
    if ps -A | pgrep -f "mplayer"; then killall mplayer & fi
    [ -f "$DT/.p_" ] && rm -fr "$DT/.p_"
    [ -f "$DT/.p" ] && rm -fr "$DT/.p"
    [ -f "$DT/index.m3u" ] && rm -fr "$DT/index.m3u"
    exit
}

on_playm() {
    killall bcle.sh &
    if ps -A | pgrep -f "/usr/share/idiomind/bcle.sh"; then killall bcle.sh & fi
    if ps -A | pgrep -f "/usr/share/idiomind/chng.sh"; then killall chng.sh & fi
    [ -f "$DT/.p_" ] && rm -fr "$DT/.p_"
    exit
}

on_lang() {
    killall bcle.sh &
    if ps -A | pgrep -f "/usr/share/idiomind/bcle.sh"; then killall bcle.sh & fi
    if ps -A | pgrep -f "/usr/share/idiomind/chng.sh"; then killall chng.sh; fi
    if ps -A | pgrep -f "notify-osd"; then killall notify-osd & fi
    if ps -A | pgrep -f "play"; then killall play & fi
    [ -d "$DT/p" ] && rm -fr "$DT/p"
    exit
}

on_add() {
    killall bcle.sh &
    if ps -A | pgrep -f "/usr/share/idiomind/add.sh"; then killall add.sh & fi
    if ps -A | pgrep -f "add.sh"; then killall add.sh & fi
    if ps -A | pgrep -f "mogrify"; then killall mogrify & fi
    if ps -A | pgrep -f "yad --progress"; then kill -9 $(pgrep -f "yad --progress") & fi
    [ -f "$DT/.n_s_pr" ] && rm -f "$DT/.n_s_pr"
    exit
}

on_addons() {
    killall strt.sh &
    if ps -A | pgrep -f "wget -q -c -T 51"; then kill -9 $(pgrep -f "wget -q -c -T 51") & fi
    kill $(cat "$DT/.uptp")
    [ -f "$DT/.uptp" ] && rm -fr "$DT/.uptp"
    exit
}

on_edit() {
    if ps -A | pgrep -f "/usr/share/idiomind/mngr.sh"; then killall mngr.sh & fi
    [ -f "$DT/.uptp" ] && rm -fr "$DT/.uptp"
    exit
}

on_play2() {
    killall bcle.sh &
    if ps -A | pgrep -f "/usr/share/idiomind/bcle.sh"; then killall bcle.sh & fi
    if ps -A | pgrep -f "/usr/share/idiomind/chng.sh"; then killall chng.sh; fi
    if ps -A | pgrep -f "notify-osd"; then killall notify-osd & fi
    if ps -A | pgrep -f "play"; then killall play & fi
    if ps -A | pgrep -f "mplayer"; then killall mplayer & fi
    [ -f "$DT/.p_" ] && rm -fr "$DT/.p_"
    exit
}

case $1 in
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
    7)
    on_edit ;;
    8)
    on_play2 ;;
esac

#!/bin/bash

DT="/tmp/.idiomind-$USER"
on_quit() {
    if ps -A |pgrep -f "/usr/share/idiomind/bcle.sh"; then killall "/usr/share/idiomind/bcle.sh" & fi
    if ps -A |pgrep -f "/usr/share/idiomind/bcle.sh"; then killall "/usr/share/idiomind/bcle.sh"; fi
    if ps -A |pgrep -f "/usr/share/idiomind/chng.sh"; then killall "/usr/share/idiomind/chng.sh"; fi
    if ps -A |pgrep -f "/usr/share/idiomind/mngr.sh"; then killall "/usr/share/idiomind/mngr.sh" & fi
    if ps -A |pgrep -f "/usr/share/idiomind/vwr.sh"; then killall"/usr/share/idiomind/vwr.sh" & fi
    if ps -A |pgrep -f "/usr/share/idiomind/main.sh"; then killall "/usr/share/idiomind/main.sh" & fi
    if ps -A |pgrep -f "yad --fixed --form"; then
    kill -9 $(pgrep -f "yad --fixed --form") & fi
    if ps -A |pgrep -f "play"; then killall play & fi
    if ps -A |pgrep -f "yad --notebook "; then
    kill -9 $(pgrep -f "yad --multi-progress ") &
    kill -9 $(pgrep -f "yad --list ") &
    kill -9 $(pgrep -f "yad --text-info ") &
    kill -9 $(pgrep -f "yad --form ") &
    kill -9 $(pgrep -f "yad --notebook ") & fi
    if [ -f /tmp/.clipw ]; then
        ( sleep 1; notify-send "$(gettext "Clipboard watcher stopped")" -t 4000 ) &
        kill "$(< /tmp/.clipw)"; rm -f /tmp/.clipw; fi
    if [ -n "$(< $DT/playlck)" ]; then
        if ps -A |pgrep -f "mplayer"; then killall mplayer & fi
        > "$DT/playlck"; rm -f "$DT/tpp"
        [ -f "$DT/list.m3u" ] && rm -f "$DT/list.m3u"
    fi
    exit
} >/dev/null 2>&1

on_play() {
    [ -e "$DT/playlck" ] && > "$DT/playlck"
    killall bcle.sh &
    if ps -A |pgrep -f "mplayer"; then killall mplayer & fi
    if ps -A |pgrep -f "play"; then killall play & fi
    if ps -A |pgrep -f "/usr/share/idiomind/bcle.sh"; then killall bcle.sh & fi
    if ps -A |pgrep -f "/usr/share/idiomind/chng.sh"; then killall chng.sh; fi
    if ps -A |pgrep -f "notify-osd"; then killall notify-osd & fi
    [ -e "$DT/list.m3u" ] && rm -f "$DT/list.m3u"
    exit
}

on_playm() {
    [ -e "$DT/playlck" ] && > "$DT/playlck"
    killall bcle.sh &
    if ps -A |pgrep -f "/usr/share/idiomind/bcle.sh"; then killall bcle.sh & fi
    if ps -A |pgrep -f "/usr/share/idiomind/chng.sh"; then killall chng.sh & fi
    [ -e "$DT/playlck" ] && > "$DT/playlck"
    exit
}

on_lang() {
    [ -e "$DT/playlck" ] && > "$DT/playlck"
    killall bcle.sh &
    if ps -A |pgrep -f "/usr/share/idiomind/bcle.sh"; then killall bcle.sh & fi
    if ps -A |pgrep -f "/usr/share/idiomind/chng.sh"; then killall chng.sh; fi
    if ps -A |pgrep -f "notify-osd"; then killall notify-osd & fi
    if ps -A |pgrep -f "play"; then killall play & fi
    > "$DT/tpe"
    exit
}

on_add() {
    killall bcle.sh &
    if ps -A |pgrep -f "/usr/share/idiomind/add.sh"; then killall add.sh & fi
    if ps -A |pgrep -f "add.sh"; then killall add.sh & fi
    if ps -A |pgrep -f "mogrify"; then killall mogrify & fi
    if ps -A |pgrep -f "yad --progress"; then kill -9 $(pgrep -f "yad --progress") & fi
    [ -e "$DT/.n_s_pr" ] && rm -f "$DT/.n_s_pr"
    exit
}

on_edit() {
    if ps -A |pgrep -f "/usr/share/idiomind/mngr.sh"; then killall mngr.sh & fi
    [ -e "$DT/.uptp" ] && rm -fr "$DT/.uptp"
    exit
}

on_play2() {
    [ -e "$DT/playlck" ] && > "$DT/playlck"
    killall bcle.sh &
    if ps -A |pgrep -f "/usr/share/idiomind/bcle.sh"; then killall bcle.sh & fi
    if ps -A |pgrep -f "/usr/share/idiomind/chng.sh"; then killall chng.sh; fi
    if ps -A |pgrep -f "notify-osd"; then killall notify-osd & fi
    if ps -A |pgrep -f "play"; then killall play & fi
    if ps -A |pgrep -f "mplayer"; then killall mplayer & fi
    [ -e "$DT/list.m3u" ] && rm -f "$DT/list.m3u"
    exit
}

on_play3() {
    if ps -A |pgrep -f "play"; then killall play & fi
    if ps -A |pgrep -f "mplayer"; then killall mplayer & fi
    [ -f "$DT/list.m3u" ] && rm -f "$DT/list.m3u"
    exit
}

on_practice() {
    dir="/usr/share/idiomind/practice"
    if ps -A |pgrep -f "$dir/prct.sh"; then killall "$dir/prct.sh" & fi
    if ps -A |pgrep -f play; then  killall play & fi
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
    9)
    on_play3 ;;
    10)
    on_practice ;;
esac

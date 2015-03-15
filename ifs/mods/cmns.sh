#!/bin/bash
# -*- ENCODING: UTF-8 -*-

function internet() {

        curl -v www.google.com 2>&1 \
        | grep -m1 "HTTP/1.1" >/dev/null 2>&1 || { 
        yad --window-icon=idiomind --on-top \
        --image=info --name=Idiomind --class=Idiomind \
        --text=" $(gettext "You have not internet connection")\n " \
        --image-on-top --center --sticky \
        --width=360 --height=120 --borders=3 \
        --skip-taskbar --title=Idiomind \
        --button="$(gettext "OK")":0 >&2; exit 1;}
}

function msg() {
        
        yad --window-icon=idiomind --name=idiomind \
        --image=$2 --on-top --text="$1" --class=Idiomind \
        --image-on-top --center --sticky --button="$(gettext "OK")":0 \
        --width=360 --height=120 --borders=5 --title=Idiomind
}

function msg_2() { # decide
    
        yad --name=Idiomind --on-top --text="$1" --image="$2" \
        --image-on-top --width=360 --height=120 --borders=3 \
        --class=Idiomind --window-icon=idiomind --sticky --center \
        --title=Idiomind --button="$4":1 --button="$3":0
}

function nmfile() {
        
  echo -n "${1^}" | md5sum | rev | cut -c 4- | rev
}

function include() {
        
  for f in $1/*; do source "$f"; done

}


function lnglss() {

    [ "${1^}" = English ] && lg=en
    [ "${1^}" = French ] && lg=fr
    [ "${1^}" = German ] && lg=de
    [ "${1^}" = Chinese ] && lg=zh-cn
    [ "${1^}" = Italian ] && lg=it
    [ "${1^}" = Japanese ] && lg=ja
    [ "${1^}" = Portuguese ] && lg=pt
    [ "${1^}" = Spanish ] && lg=es
    [ "${1^}" = Vietnamese ] && lg=vi
    [ "${1^}" = Russian ] && lg=ru
    echo "$lg"
}


function try() {
        
    "$@"
    exit=$?
    [ $exit -ne 0 ] && val=0 || val=1
    echo "[$val]"
    
}

function btry() {
        
    "$@"
    exit=$?
    [ $exit -ne 0 ] && continue || break
    
}


function check_index1() {
    
    for i in "${@}"; do
        if [ -n "$(cat "$i" | sort -n | uniq -dc)" ]; then
            cat "$i" | awk '!array_temp[$0]++' > $DT/tmp
            sed '/^$/d' $DT/tmp > "$i"; rm -f $DT/tmp
        fi
    done
}

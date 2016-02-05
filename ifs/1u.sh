#!/bin/bash
# -*- ENCODING: UTF-8 -*-

TEXTDOMAIN=idiomind
export TEXTDOMAIN
TEXTDOMAINDIR=/usr/share/locale
export TEXTDOMAINDIR
Encoding=UTF-8
alias gettext='gettext "idiomind"'

source /usr/share/idiomind/default/sets.cfg
lang1="${!lang[@]}"; declare lt=( $lang1 )
lang2="${!slang[@]}"; declare ls=( $lang2 )
text="<span font_desc='Free Sans Bold 14'>$(gettext "Welcome") ${USER^} </span>
\n      $(gettext "To get started, please configure the following:")\n"
sets=( 'gramr' 'wlist' 'trans' 'dlaud' 'ttrgt' 'clipw' 'stsks' \
'langt' 'langs' 'synth' 'txaud' 'intrf' )

if [[ ! $(which yad) ]]; then
zenity --info --text="$(gettext "Oops. sorry! To run idiomind we need to use a GUI output with yad.\nPlease install [yad], you can use:")
\nadd-apt-repository ppa:robinpalat/idiomind
apt-get update
apt-get install yad"
exit 1
fi

_info() {
    yad --form --title="$(gettext "Notice")" \
    --text="$(gettext "Some things are still not working for these languages:") Chinese, Japanese, Russian." \
    --image=info \
    --window-icon=info \
    --skip-taskbar --center --on-top \
    --width=340 --height=120 --borders=5 \
    --button="$(gettext "OK")":0
}

emrk='!'
for val in "${!lang[@]}"; do
    declare clocal="$(gettext "${val}")"
    list1="${list1}${emrk}${clocal}"
done
unset clocal
for val in "${!slang[@]}"; do
    declare clocal="$(gettext "${val}")"
    list2="${list2}${emrk}${clocal}"
done

function set_lang() {
    language="$1"
    if [ ! -d "$DM_t/$language/.share/images" ]; then
        mkdir -p "$DM_t/$language/.share/images"
    fi
    if [ ! -d "$DM_t/$language/.share/audio" ]; then
        mkdir -p "$DM_t/$language/.share/audio"
    fi
    if [ ! -d "$DM_t/$language/.share/data" ]; then
        mkdir -p "$DM_t/$language/.share/data"
        cdb="$DM_t/$language/.share/data/${language}.db"
        echo -n "create table if not exists Words \
        (Word TEXT, Example TEXT, Definition TEXT);" |sqlite3 ${cdb}
        echo -n "create table if not exists Config \
        (Study TEXT, Expire INTEGER);" |sqlite3 ${cdb}
        echo -n "PRAGMA foreign_keys=ON" |sqlite3 ${cdb}
    fi
    for n in {0..3}; do touch "$DM_t/$language/.share/$n.cfg"; done
    echo "$language" > "$DC_s/6.cfg"
}

dlg=$(yad --form --title="Idiomind" \
--text="$text" \
--class=Idiomind --name=Idiomind \
--window-icon=idiomind \
--image-on-top --buttons-layout=end --align=right --center --on-top \
--width=470 --height=270 --borders=15 \
--field="$(gettext "Select foreign language"):CB" "$list1" \
--field="$(gettext "Select native language"):CB" "$list2" \
--button=Cancel:1 \
--button=gtk-ok:0)
ret=$?

if [ $ret -eq 1 ]; then
    killall 1u.sh & exit 1

elif [ $ret -eq 0 ]; then
    target=$(echo "$dlg" |cut -d "|" -f1)
    source=$(echo "$dlg" |cut -d "|" -f2)
    
    if [ -z "$dlg" ]; then
    /usr/share/idiomind/ifs/1u.sh & exit 1
    elif [ -z $source ]; then
    /usr/share/idiomind/ifs/1u.sh & exit 1
    elif [ -z $target ]; then
    /usr/share/idiomind/ifs/1u.sh t & exit 1
    elif [ $target = $source ]; then
    /usr/share/idiomind/ifs/1u.sh t & exit 1
    fi
    
    mkdir "$HOME/.idiomind"
    if [ $? -ne 0 ]; then
    yad --title=Idiomind \
    --text="$(gettext "Error occurred trying to write in file system")\n" \
    --image=error \
    --name=idiomind --class=idiomind \
    --window-icon=idiomind \
    --image-on-top --sticky --skip-taskbar --center \
    --width=420 --height=120 --borders=2 \
    --button=gtk-ok:1 & exit 1
    fi
    
    DM_t="$HOME/.idiomind/topics"
    [ ! -d  "$HOME/.config" ] && mkdir "$HOME/.config"
    mkdir -p "$HOME/.config/idiomind/addons"
    DC_s="$HOME/.config/idiomind"

    for val in "${lt[@]}"; do
        if [[ ${target} = $(gettext ${val}) ]]; then
            export lgtl=$val
        fi
    done
    for val in "${ls[@]}"; do
        if [[ ${source} = $(gettext ${val}) ]]; then
            export lgsl=$val
        fi
    done
    
    set_lang ${lgtl}

    if ! grep -q ${lgsl} <<<"$(sqlite3 ${cdb} "PRAGMA table_info(Words);")"; then
        sqlite3 ${cdb} "alter table Words add column ${lgsl} TEXT;"
    fi
    
    echo ${lgsl} >> "$DC_s/6.cfg"

    if echo "$target$source" |grep -oE 'Chinese|Japanese|Russian'; then _info; fi

    > "$DC_s/1.cfg"
    for n in {0..11}; do 
    echo -e "${sets[$n]}=\"\"" >> "$DC_s/1.cfg"; done
    touch "$DC_s/4.cfg"
    echo -e "usrid=\"\"\npassw=\"\"\ncntct=\"\"" > "$DC_s/3.cfg"
    /usr/share/idiomind/ifs/tls.sh first_run
    export u=1
    idiomind -s
fi
exit 0

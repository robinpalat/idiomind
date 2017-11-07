#!/bin/bash
# -*- ENCODING: UTF-8 -*-

TEXTDOMAIN=idiomind
TEXTDOMAINDIR=/usr/share/locale
export TEXTDOMAINDIR TEXTDOMAIN
alias gettext='gettext "idiomind"'
source /usr/share/idiomind/default/sets.cfg
lang1="${!tlangs[@]}"; declare lt=( $lang1 )
lang2="${!slangs[@]}"; declare ls=( $lang2 )
text="<span font_desc='Free Sans Bold 14'>$(gettext "Welcome") ${USER^} </span>
\n      $(gettext "To get started, please configure the following:")\n"

if [[ ! $(which yad) ]]; then
zenity --info --title="$(gettext "Installing YAD")" \
--text="$(gettext "Sorry, to run idiomind we need to use a GUI output with yad.\nPlease install 'yad', you can use:")
\nsudo add-apt-repository ppa:robinpalat/idiomind
sudo apt-get update
sudo apt-get install yad\n
$(gettext "You can also download the source code and compile it yourself.\nPlease go to:") https://sourceforge.net/projects/yad-dialog"
    exit 1
else
    yv="$(yad --version |cut -f1 -d' ')"
    yadversion() { test "$(echo "$@" |tr " " "\n" |sort -V |head -n 1)" != "$1"; }
    if yadversion "$yad_version" "$yv"; then
zenity --info --title="$(gettext "Installing YAD")" \
--text="$(gettext "Sorry, idiomind is using a more recent version of yad.\nPlease update 'yad', you can use:")
\nsudo add-apt-repository ppa:robinpalat/idiomind
sudo apt-get update
sudo apt-get install yad\n
$(gettext "You can also download the source code and compile it yourself.\nPlease go to:") https://sourceforge.net/projects/yad-dialog"
        exit 1
    fi
fi

_info() {
    yad --form --title="$(gettext "Notice")" \
    --text="$(gettext "Note that these languages may present some text display errors:") Chinese, Japanese, Russian." \
    --image=dialog-information \
    --name=Idiomind --class=Idiomind \
    --window-icon=dialog-information \
    --skip-taskbar --center --on-top \
    --width=340 --height=120 --borders=5 \
    --button="$(gettext "OK")":0
}

emrk='!'
for val in "${!tlangs[@]}"; do
    declare clocal="$(gettext "${val}")"
    list1="${list1}${emrk}${clocal}"
done
unset clocal
for val in "${!slangs[@]}"; do
    declare clocal="$(gettext "${val}")"
    list2="${list2}${emrk}${clocal}"
done

function set_lang() {
    lang="$1"
    if [ ! -d "$DM_t/$lang/.share/images" ]; then
        mkdir -p "$DM_t/$lang/.share/images"
    fi
    if [ ! -d "$DM_t/$lang/.share/audio" ]; then
        mkdir -p "$DM_t/$lang/.share/audio"
    fi
    if [ ! -d "$DM_t/$lang/.share/data" ]; then
        mkdir -p "$DM_t/$lang/.share/data"
        cdb="$DM_t/$lang/.share/data/$lang.db"
        echo -n "create table if not exists Words \
        (Word TEXT, Example TEXT, Definition TEXT);" |sqlite3 ${cdb}
        echo -n "create table if not exists Config \
        (Study TEXT, Expire INTEGER);" |sqlite3 ${cdb}
        echo -n "PRAGMA foreign_keys=ON" |sqlite3 ${cdb}
    fi
    for n in {0..3}; do touch "$DM_t/$lang/.share/$n.cfg"; done
    echo "$lang" > "$DC_s/6.cfg"
}

dlg=$(yad --form --title="Idiomind" \
--text="$text" \
--class=Idiomind --name=Idiomind \
--window-icon=idiomind \
--image-on-top --buttons-layout=end --align=right --fixed --center --on-top \
--width=450 --height=250 --borders=12 \
--field="$(gettext "Select foreign language"):CB" "$list1" \
--field="$(gettext "Select native language"):CB" "$list2" \
--button="$(gettext "Cancel")":1 \
--button="$(gettext "OK")":0)
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
        --text="$(gettext "An error occurred while trying to write on file system")\n" \
        --image=error \
        --name=Idiomind --class=Idiomind \
        --window-icon=idiomind \
        --skip-taskbar --center \
        --width=420 --height=120 --borders=2 \
        --button="$(gettext "OK")":1 & exit 1
    fi
    DM_t="$HOME/.idiomind/topics"
    [ ! -d  "$HOME/.config" ] && mkdir "$HOME/.config"
    mkdir -p "$HOME/.config/idiomind/addons"
    DC_s="$HOME/.config/idiomind"

    for val in "${lt[@]}"; do
        if [[ ${target} = $(gettext ${val}) ]]; then
            export tlng=$val
        fi
    done
    export slng=${source}
    set_lang ${tlng}
    if ! grep -q ${slng} <<<"$(sqlite3 ${cdb} "PRAGMA table_info(Words);")"; then
        sqlite3 ${cdb} "alter table Words add column ${slng} TEXT;"
    fi
    echo ${slng} >> "$DC_s/6.cfg"
    if echo "$target" |grep -oE 'Chinese|Japanese|Russian'; then _info; fi
    > "$DC_s/1.cfg"
    for n in {0..12}; do echo -e "${csets[$n]}=\"\"" >> "$DC_s/1.cfg"; done
    touch "$DC_s/4.cfg"
    echo -e "authr=\"\"\npass=\"\"\ncntt=\"\"" > "$DC_s/3.cfg"
    /usr/share/idiomind/ifs/tls.sh first_run
    export u=1
    idiomind -s
fi
exit 0

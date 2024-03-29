#!/bin/bash
# -*- ENCODING: UTF-8 -*-


TEXTDOMAIN=idiomind
TEXTDOMAINDIR=/usr/share/locale
export TEXTDOMAINDIR TEXTDOMAIN
alias gettext='gettext "idiomind"'
source /usr/share/idiomind/default/sets.cfg
lang1="${!tlangs[@]}"; declare lt=( $lang1 )
lang2="${!slangs[@]}"; declare ls=( $lang2 )
text="<span font_desc='Free Sans Bold 14'>$(gettext "Welcome") </span>
\n      $(gettext "To get started, please configure the following:")"
sx=$(xrandr -q |grep -w Screen |sed 's/.*current //;s/,.*//' |awk '{print $1}')
sy=$(xrandr -q |grep -w Screen |sed 's/.*current //;s/,.*//' |awk '{print $3}')
sx=$(echo $((($sx-500)/2)))
sy=$(echo $((($sy-500)/2)))

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
    tlng="$1"
    if [ ! -d "$DM_t/$tlng/.share/images" ]; then
        mkdir -p "$DM_t/$tlng/.share/images"
    fi
    if [ ! -d "$DM_t/$tlng/.share/audio" ]; then
        mkdir -p "$DM_t/$tlng/.share/audio"
    fi
    if [ ! -d "$DM_t/$tlng/.share/data" ]; then
        mkdir -p "$DM_t/$tlng/.share/data"
        tlngdb="$DM_t/$tlng/.share/data/$tlng.db"
        echo -n "create table if not exists Words \
        (Word TEXT, Example TEXT, Definition TEXT);" |sqlite3 ${tlngdb}
        echo -n "create table if not exists Config \
        (Study TEXT, Expire INTEGER);" |sqlite3 ${tlngdb}
        echo -n "PRAGMA foreign_keys=ON" |sqlite3 ${tlngdb}
    fi
    
    sqlite3 ${cfgdb} "update lang set tlng=\"${tlng}\";"
    sqlite3 ${cfgdb} "update lang set slng=\"${slng}\";"
    
    shrdb="$DM_t/$tlng/.share/data/config"
    if [ ! -f "${shrdb}" ]; then
        "/usr/share/idiomind/ifs/mkdb.sh" share
    fi
}

dlg=$(yad --form --title="Idiomind" \
--text="$text\n" \
--class=Idiomind --name=Idiomind \
--image=/usr/share/idiomind/images/logo.png \
--window-icon=/usr/share/idiomind/images/logo.png \
--image-on-top --buttons-layout=end --align=right \
--fixed --geometry="+$sx+$sy" --center --on-top \
--width=500 --height=260 --borders=15 \
--field="\t\t\t$(gettext "Select the language you are learning")  :CB" "$list1" \
--field="\t\t\t$(gettext "Select your language")  :CB" "$list2" \
--field=" :LBL" " "  \
--field="$(gettext "Set recommended Initialization configurations")  :chk" "TRUE" \
--field=" :LBL" " "  \
--button="$(gettext "Cancel")":1 \
--button="$(gettext "OK")!gtk-apply":0)
ret=$?

if [ $ret -eq 1 ]; then
    killall 1u.sh & exit 1

elif [ $ret -eq 0 ]; then
    target=$(echo "$dlg" |cut -d "|" -f1)
    source=$(echo "$dlg" |cut -d "|" -f2)
    iniset=$(echo "$dlg" |cut -d "|" -f4)
    
    if [ -z "$dlg" ]; then
    /usr/share/idiomind/ifs/1u.sh & exit 1
    elif [ -z "$source" ]; then
    /usr/share/idiomind/ifs/1u.sh & exit 1
    elif [ -z "$target" ]; then
    /usr/share/idiomind/ifs/1u.sh t & exit 1
    elif [ "$target" = "$source" ]; then
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
    DC_s="$HOME/.config/idiomind"
    DT=/tmp/.idiomind-$USER

    [ ! -d  "$DC_s" ] && mkdir -p "$DC_s/addons"
    touch "$DC_s/tpc"
    
    export cfgdb="$DC_s/config"
    if [ ! -f "${cfgdb}" ]; then
        "/usr/share/idiomind/ifs/mkdb.sh" config "$iniset"
    fi
    
    for val in "${lt[@]}"; do
        if [[ "${target}" = $(gettext ${val}) ]]; then
            export tlng="$val"
        fi
    done
    export slng="${source}"
    set_lang "${tlng}"
    
    if ! grep -q "${slng}" <<<"$(sqlite3 ${tlngdb} "PRAGMA table_info(Words);")"; then
        sqlite3 ${tlngdb} "alter table Words add column '${slng}' TEXT;"
    fi
    
    if echo "$target" |grep -oE 'Chinese|Japanese|Russian'; then _info; fi
    
    /usr/share/idiomind/ifs/tls.sh first_run "$iniset"
    
    export u=1
    idiomind -s
fi
exit 0

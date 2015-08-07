#!/bin/bash
# -*- ENCODING: UTF-8 -*-

TEXTDOMAIN=idiomind
export TEXTDOMAIN
TEXTDOMAINDIR=/usr/share/locale
export TEXTDOMAINDIR
Encoding=UTF-8
alias gettext='gettext "idiomind"'

text="<span font_desc='Free Sans Bold 14'>$(gettext "Welcome") ${USER^} </span>
\n      $(gettext "To get started, please configure the following:")\n"
lang=( 'English' 'Spanish' 'Italian' 'Portuguese' 'German' \
'Japanese' 'French' 'Vietnamese' 'Chinese' 'Russian' )
sets=( 'gramr' 'wlist' 'trans' 'ttrgt' 'clipw' 'stsks' \
'langt' 'langs' 'synth' 'txaud' 'intrf' )

_info() {
    
    yad --form --title="$(gettext "Notice")" \
    --text="$(gettext "Some features do not yet work with this language"). ($1)\n" \
    --image=info \
    --window-icon=info \
    --skip-taskbar --center --on-top \
    --width=460 --height=120 --borders=5 \
    --button="$(gettext "OK")":0
}

function set_lang() {
    
    if [ ! -d "$DM_t/$1" ]; then
    mkdir "$DM_t/$1"
    touch "$DM_t/$1/.1.cfg"
    touch "$DM_t/$1/.2.cfg"
    touch "$DM_t/$1/.3.cfg"
    mkdir -p "$DM_t/$1/.share/images"; fi
    echo "$1" > "$DC_s/6.cfg"
}

if [ ! -f /usr/bin/yad ]; then
zenity --info --title="Idiomind" \
--window-icon="/usr/share/idiomind/images/icon.png" \
--text="$(gettext "Missing dependency to start.
It seems that you have no installed on your system the program YAD.\t
You can get it from here:  www.sourceforge.net/projects/yad-dlg
or install it using the following commands:

sudo add-apt-repository ppa:robinpalat/idiomind
sudo apt-get update
sudo apt-get install yad")" \
--no-wrap & exit; fi

dlg=$(yad --form --title="Idiomind" \
--text="$text" \
--class=Idiomind --name=Idiomind \
--window-icon="/usr/share/idiomind/images/icon.png" \
--image-on-top --buttons-layout=end --align=right --center --on-top \
--width=460 --height=270 --borders=15 \
--field="$(gettext "Select foreign language"):CB" " !English!French!German!Italian!Japanese!Portuguese!Russian!Spanish!Vietnamese!Chinese" \
--field="$(gettext "Select native language"):CB" " !English!French!German!Italian!Japanese!Portuguese!Russian!Spanish!Vietnamese!Chinese" \
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
    fi
    
    mkdir "$HOME/.idiomind"
    if [ $? -ne 0 ]; then
    yad --title=Idiomind \
    --text="$(gettext "Error occurred trying to write in file system")\n" \
    --image=error \
    --name=idiomind --class=idiomind \
    --window-icon="$DS/images/icon.png" \
    --image-on-top --sticky --skip-taskbar --center \
    --width=420 --height=120 --borders=2 \
    --button=gtk-ok:1 & exit 1
    fi
    
    mkdir -p "$HOME/.idiomind/topics/saved"
    DM_t="$HOME/.idiomind/topics"
    [ ! -d  "$HOME/.config" ] && mkdir "$HOME/.config"
    mkdir -p "$HOME/.config/idiomind/s"
    DC_s="$HOME/.config/idiomind/s"
    mkdir "$HOME/.config/idiomind/addons"
    
    n=0
    while [ ${n} -lt 10 ]; do
        if echo "$target" | grep "${lang[$n]}"; then
        set_lang "${lang[$n]}"
        if grep -o -E 'Chinese|Japanese|Russian|Vietnamese' <<< "$target";
        then _info "$target"; fi
        break
        fi
        ((n=n+1))
    done
    
    n=0
    while [ ${n} -lt 10 ]; do
        if echo "$source" | grep "${lang[$n]}"; then
        echo "${lang[$n]}" >> "$DC_s/6.cfg" & break
        fi
        ((n=n+1))
    done
    
    n=0; > "$DC_s/1.cfg"
    while [ ${n} -lt 11 ]; do
    echo -e "${sets[$n]}=\"\"" >> "$DC_s/1.cfg"
    ((n=n+1))
    done
    touch "$DC_s/4.cfg"
    
    b=$(tr -dc a-z < /dev/urandom |head -c 1)
    c=$((RANDOM%100))
    id="$b$c"
    id=${id:0:3}
config="usrid=\"$id\"
iuser=\"\"
cntct=\"\""
    echo -e "${config}" > "$DC_s/3.cfg"
    touch "$DC_s/elist_first_run" "$DC_s/img_first_run"
    
    idiomind -s

    exit
else
    exit 1
fi

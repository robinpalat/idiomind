#!/bin/bash
# -*- ENCODING: UTF-8 -*-

#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#  27.02.2015

TEXTDOMAIN=idiomind
export TEXTDOMAIN
TEXTDOMAINDIR=/usr/share/locale
export TEXTDOMAINDIR
Encoding=UTF-8
alias gettext='gettext "idiomind"'
user=$(echo "$(whoami)")
text="<big><big><big>$(gettext "Welcome") $USER </big></big></big>
$(gettext "To get started, please configure the following.")\n"
lang=('English' 'Spanish' 'Italian' 'Portuguese' 'German' \
'Japanese' 'French' 'Vietnamese' 'Chinese' 'Russian')
sets=('grammar' 'list' 'tasks' 'trans' 'text' 'audio' \
'repeat' 'videos' 'loop' 't_lang' 's_lang' 'synth' 'edit' \
'words' 'sentences' 'marks' 'practice' 'news' 'saved')

_info() {
    
    yad --form --title="$(gettext "Information")" \
    --text="$(gettext "Some features do not yet work with this language:") $1 ." \
    --image=info \
    --window-icon=info \
    --skip-taskbar --center --on-top \
    --width=400 --height=120 --borders=5 \
    --button="$(gettext "OK")":0
}

function set_lang() {
    
    if [ ! -d "$DM_t/$1" ]; then
    mkdir "$DM_t/$1"
    touch "$DM_t/$1/.1.cfg"
    touch "$DM_t/$1/.2.cfg"
    touch "$DM_t/$1/.3.cfg"
    mkdir "$DM_t/$1/.share"; fi
    echo "$1" > "$DC_s/6.cfg"
}

if [ ! -f /usr/bin/yad ]; then
zenity --info --window-icon="/usr/share/idiomind/images/icon.png" \
--text="$(gettext "Missing dependency to start.
It seems that you have no installed on your system the program YAD.\t
You can get it from here:  www.sourceforge.net/projects/yad-dlg
or install it using the following commands:

sudo add-apt-repository ppa:robinpala/idiomind
sudo apt-get update
sudo apt-get install yad")" \
--title="Idiomind" --no-wrap & exit; fi

dlg=$(yad --form --title="Idiomind" \
--text="$text" \
--class=Idiomind --name=Idiomind \
--window-icon="/usr/share/idiomind/images/icon.png" \
--image-on-top --fixed --align=center --center --on-top --buttons-layout=end \
--width=420 --height=285 --borders=15 \
--field="$(gettext "Select the language you are studying")":lbl " " \
--field=":CB" " !English!French!German!Italian!Japanese!Portuguese!Russian!Spanish!Vietnamese!Chinese" \
--field="$(gettext "Select your native language")":lbl " " \
--field=":CB" " !English!French!German!Italian!Japanese!Portuguese!Russian!Spanish!Vietnamese!Chinese" \
--button=Cancel:1 \
--button=gtk-ok:0)

ret=$?

if [ $ret -eq 1 ]; then
    killall 1u.sh & exit 1

elif [ $ret -eq 0 ]; then
    target=$(echo "$dlg" | cut -d "|" -f2)
    source=$(echo "$dlg" | cut -d "|" -f4)
    
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
    --text=" $(gettext "Error while trying to write on") \'/home/$user/\'\n" \
    --image=error \
    --name=idiomind --class=idiomind \
    --window-icon="$DS/images/icon.png" \
    --image-on-top --sticky --fixed --skip-taskbar --center \
    --width=320 --height=80 --borders=2 \
    --button=gtk-ok:1 & exit 1
    fi
    
    mkdir -p "$HOME/.idiomind/topics/saved"
    DM_t="$HOME/.idiomind/topics"
    [ ! -d  "$HOME/.config" ] && mkdir "$HOME/.config"
    mkdir -p "$HOME/.config/idiomind/s"
    DC_s="$HOME/.config/idiomind/s"
    mkdir "$HOME/.config/idiomind/addons"

    n=0
    while [ $n -lt 10 ]; do
        if echo "$target" | grep "${lang[$n]}"; then
        set_lang "${lang[$n]}"
        if grep -o -E 'Chinese|Japanese|Russian|Vietnamese' <<< "$target";
        then _info "$target"; fi
        break
        fi
        ((n=n+1))
    done
    
    n=0
    while [ $n -lt 10 ]; do
        if echo "$source" | grep "${lang[$n]}"; then
        echo "${lang[$n]}" >> "$DC_s/6.cfg" & break
        fi
        ((n=n+1))
    done

    n=0; > "$DC_s/1.cfg"
    while [ $n -lt 19 ]; do
    echo -e "${sets[$n]}=\"\"" >> "$DC_s/1.cfg"
    ((n=n+1))
    done
    touch "$DC_s/4.cfg"

    b=$(tr -dc a-z < /dev/urandom | head -c 1)
    c=$(echo $(($RANDOM%100)))
    echo $c$b > "$DC_s/5.cfg"

    idiomind -s

    exit
else
    exit 1
fi

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

LANGUAGE=$LANGUAGE
[ -z $LANGUAGE ] && LANGUAGE=en
TEXTDOMAIN=idiomind
export TEXTDOMAIN
TEXTDOMAINDIR=/usr/share/locale
export TEXTDOMAINDIR
Encoding=UTF-8
alias gettext='gettext "idiomind"'
user=$(echo "$(whoami)")

text="<big><big><big>  Welcome  </big></big></big>
$(gettext "     To get started, please configure the following:")\n"

function set_lang() {
    
    if echo "$source" | grep $1; then
    
        if [ ! -d "$DIR1"/$1 ]; then
            mkdir "$DIR1"/$1
            touch "$DIR1"/$1/.cfg.1
            touch "$DIR1"/$1/.cfg.2
            touch "$DIR1"/$1/.cfg.3
            mkdir "$DIR1"/$1/.share
        fi
        echo $2 > $DIR2/s/cfg.10
        echo $1 >> $DIR2/s/cfg.10
    fi
}


if [ ! -f /usr/bin/yad ]; then
zenity --info --window-icon="idiomind" \
--text="$(gettext "Missing a dependency to start.
It seems that you have no installed on your system the program YAD.\t
You can get it from here:  www.sourceforge.net/projects/yad-dialog
or install it using the following commands:

sudo add-apt-repository ppa:robinpala/idiomind
sudo apt-get update
sudo apt-get install yad")" \
--title="Idiomind" --no-wrap & exit
fi

dialog=$(yad --center --width=500 --height=300 --fixed \
    --image-on-top --on-top --class=idiomind --name=idiomind \
    --window-icon=idiomind --buttons-layout=end --text="$text" \
    --title="Idiomind" --form --borders=15 --align=center --button=Cancel:1 --button=gtk-ok:0 \
    --field="$(gettext "Select the language you are studying:")":lbl \
    --field=":CB" !""\
    --field="$(gettext "Select your native language:")":lbl \
    --field=":CB" \
    !"English!French!German!Italian!Japanese!Portuguese!Russian!Spanish!Vietnamese!Chinese" !"" \
    !"English!French!German!Italian!Japanese!Portuguese!Russian!Spanish!Vietnamese!Chinese")

ret=$?

if [[ $ret -eq 1 ]]; then
    killall 1u.sh & exit 1

elif [[ $ret -eq 0 ]]; then
    source=$(echo "$dialog" | cut -d "|" -f2)
    target=$(echo "$dialog" | cut -d "|" -f4)
    
    if [ -z "$dialog" ]; then
        /usr/share/idiomind/ifs/1u.sh & exit 1
    elif [ -z $source ]; then
        /usr/share/idiomind/ifs/1u.sh & exit 1
    elif [ -z $target ]; then
        /usr/share/idiomind/ifs/1u.sh t & exit 1
    fi
    
    mkdir "$HOME"/.idiomind/
    
    if [ $? -ne 0 ]; then
        yad --name=idiomind \
        --image=error --button=gtk-ok:1\
        --text=" $(gettext "Error while trying to write on") /home/$user/</b>\\n" \
        --image-on-top --sticky --fixed \
        --width=320 --height=80 \
        --borders=2 --title=Idiomind \
        --skip-taskbar --center \
        --window-icon=idiomind & exit 1
    fi
    
    mkdir -p "$HOME"/.idiomind/topics/saved
    DIR1="$HOME"/.idiomind/topics
    [ ! -d  "$HOME"/.config ] && mkdir "$HOME"/.config
    mkdir "$HOME"/.config/idiomind
    DIR2="$HOME"/.config/idiomind
    mkdir "$DIR2"/s
    mkdir "$DIR2"/addons
    
    if echo "$target" | grep "English"; then
        echo "en" > $DIR2/s/cfg.9
        echo "english" >> $DIR2/s/cfg.9
    fi
    
    if echo "$target" | grep "French"; then
        echo "fr" > $DIR2/s/cfg.9
        echo "french" >> $DIR2/s/cfg.9
    fi
    
    if echo "$target" | grep "German"; then
        echo "de" > $DIR2/s/cfg.9
        echo "german" >> $DIR2/s/cfg.9
    fi
    
    if echo "$target" | grep "Italian"; then
        echo "it" > $DIR2/s/s/cfg.9
        echo "italian" >> $DIR2/s/cfg.9
    fi
    
    if echo "$target" | grep "Japanese"; then
        echo "ja" > $DIR2/s/cfg.9
        echo "japanese" >> $DIR2/s/cfg.9
    fi
    
    if echo "$target" | grep "Portuguese"; then
        echo "pt" > $DIR2/s/cfg.9
        echo "portuguese" >> $DIR2/s/cfg.9
    fi
    
    if echo "$target" | grep "Spanish"; then
        echo "es" > $DIR2/s/cfg.9
        echo "spanish" >> $DIR2/s/cfg.9
    fi
    
    if echo "$target" | grep "Vietnamese"; then
        echo "vi" > $DIR2/s/cfg.9
        echo "vietnamese" >> $DIR2/s/cfg.9
    fi
    
    
    if echo "$target" | grep "Chinese"; then
        echo "zh-cn" > $DIR2/s/cfg.9
        echo "Chinese" >> $DIR2/s/cfg.9
    fi
    
    if echo "$target" | grep "Russian"; then
        echo "ru" > $DIR2/s/cfg.9
        echo "Russian" >> $DIR2/s/cfg.9
    fi
    
    if echo "$source" | grep "English"; then
        set_lang English en
    fi
    
    if echo "$source" | grep "French"; then
        set_lang French fr
    fi
    
    if echo "$source" | grep "German"; then
        set_lang German de
    fi
    
    if echo "$source" | grep "Italian"; then
        set_lang Italian it
    fi
    
    if echo "$source" | grep "Japanese"; then
        set_lang Japanese ja
    fi
    
    if echo "$source" | grep "Portuguese"; then
        set_lang Portuguese pt
    fi
    
    if echo "$source" | grep "Spanish"; then
        set_lang Spanish es
    fi
    
    if echo "$source" | grep "Chinese"; then
        set_lang Chinese "zh-cn"
    fi
    
    if echo "$source" | grep "Vietnamese"; then
        set_lang Vietnamese vi
    fi
    
    if echo "$source" | grep "Russian"; then
        set_lang Russian ru
    fi
    
    b=$(tr -dc a-z < /dev/urandom | head -c 1)
    c=$(echo $(($RANDOM%100)))
    echo $c$b > $DIR2/s/cfg.4
    touch $DIR2/s/cfg.3
    touch $DIR2/s/cfg.8
    touch $DIR2/s/cfg.6
    touch $DIR2/s/cfg.12

    exit 1
else
    killall 1u.sh & exit 1
fi

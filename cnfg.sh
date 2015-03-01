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
#  

#source /usr/share/idiomind/ifs/c.conf
Encoding=UTF-8
wth=$(sed -n 5p $DC_s/cfg.18)
eht=$(sed -n 6p $DC_s/cfg.18)
info1="$(echo "$(gettext "Do you want to change the interface language program?")" | xargs -n6 | sed 's/^/  /')"
info2="$(echo "$(gettext "You want to change the language setting to learn?")" | xargs -n6 | sed 's/^/  /')"
ICON=$DS/images/icon.png
cd $DS/addons

info_="$(gettext "\nIdiomind is a small program that helps you learn foreign words, this is useful when you have to remember a lot of new vocabulary in the language you are studying.\n\nLicense: GPLv3\nIdiomind is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, Either version 3 of the License, or (at your option) any later version.\nThis program is distributed in the hope That it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.\nYou should have received a copy of the GNU General Public License along this program. If not, see https://www.gnu.org/licenses/gpl.html\nCode\nhttps://github.com/robinsato/idiomind")"

autostart="[Desktop Entry]
Name=Idiomind
GenericName=idiomind
Comment=Vocabulary learning tool
Exec=idiomind autostart
Terminal=false
Type=Application
Categories=languages;Education;
Icon=idiomind
MimeType=application/x-idmnd;
StartupNotify=true
Encoding=UTF-8"

if [ ! -d "$DC" ]; then
    $DS/ifs/1u.sh
    sleep 1
    $DS/cnfg.sh & exit
fi

function confirm() {
    
    yad --form --center --borders=8 --image=$2 \
    --title="Idiomind" --on-top --window-icon=idiomind \
    --skip-taskbar --button="$(gettext "Nope")":1 \
    --button="$(gettext "Yes")":0 --text="$1\n" \
    --width=350 --height=120
}

function set_lang() {
    
    if [ ! -d "$DM_t"/$1 ]; then
        mkdir "$DM_t"/$1
        mkdir "$DM_t"/$1/.share
    fi
    echo "$2" > $DC_s/cfg.10
    echo "$1" >> $DC_s/cfg.10
    $DS/stop.sh L
    $DS/stop.sh feed
        
    if [ -f "$DM/topics/$1/.cfg.8" ]; then
        LST=$(sed -n 1p "$DM/topics/$1/.cfg.8")
        "$DM/topics/$1/$LST/tpc.sh"
    else
        rm $DC_s/cfg.8 && touch $DC_s/cfg.8
    fi

    $DS/mngr.sh mkmn
}

c=$(echo $(($RANDOM%100000)))
KEY=$c
cnf1=$(mktemp $DT/cnf1.XXXX)
cnf3=$(mktemp $DT/cnf3.XXXX)

[[ -f $DC_s/cfg.1 ]] && sttng3=$(sed -n 3p $DC_s/cfg.1) || sttng3=FALSE
[[ -f $DC_s/cfg.1 ]] && sttng4=$(sed -n 4p $DC_s/cfg.1) || sttng4=FALSE
[[ -f $DC_s/cfg.1 ]] && sttng5=$(sed -n 5p $DC_s/cfg.1) || sttng5=FALSE
[[ -f $DC_s/cfg.1 ]] && sttng6=$(sed -n 6p $DC_s/cfg.1) || sttng6=FALSE
[[ -f $DC_s/cfg.1 ]] && sttng8=$(sed -n 8p $DC_s/cfg.1) || sttng8=""
[[ -f $DC_s/cfg.1 ]] && sttng9=$(sed -n 9p $DC_s/cfg.1) || sttng9=""

yad --plug=$KEY --tabnum=1 --borders=15 --scroll \
    --separator="\\n" --form --no-headers --align=right \
    --field="$(gettext "General Options")\t":lbl "#1" \
    --field=":lbl" "#2"\
    --field="$(gettext "Colorize words to grammar (Experimental)")":CHK $sttng3 \
    --field="$(gettext "List words after adding a sentence")":CHK $sttng4 \
    --field="$(gettext "Perform tasks at startup")":CHK $sttng5 \
    --field="$(gettext "Speak to pass the items")":CHK $sttng6 \
    --field=" :lbl" "#7"\
    --field="<small>$(gettext "Speech Synthesizer\nDefault espeak")</small>":CB5 "$sttng8" \
    --field="<small>$(gettext "Use this program\nfor audio editing")</small>":CB5 "$sttng9" \
    --field=" :lbl" "#10"\
    --field="$(gettext "Check for Updates")":BTN "/usr/share/idiomind/ifs/tls.sh check_updates" \
    --field="$(gettext "Quick Help")":BTN "/usr/share/idiomind/ifs/tls.sh help" \
    --field="$(gettext "Feedback")":BTN "/usr/share/idiomind/ifs/tls.sh fback >/dev/null 2>&1" \
    --field="$(gettext "Topic Saved")":BTN "/usr/share/idiomind/ifs/upld.sh vsd" \
    --field=" :lbl" "#14"\
    --field="$(gettext "Languages")\t":lbl "#15" \
    --field=":lbl" "#16"\
    --field="$(gettext "Language Learning")":CB "$lgtl!English!Chinese!French!German!Italian!Japanese!Portuguese!Russian!Spanish!Vietnamese" \
    --field="$(gettext "Your Language")":CB "$lgsl!English!Chinese!French!German!Italian!Japanese!Portuguese!Russian!Spanish!Vietnamese" > "$cnf1" &
cat $DC_s/cfg.21 | yad --plug=$KEY --tabnum=2 --list --expand-column=2 \
    --text="<sub>  $(gettext "Double click to set") </sub>" \
    --no-headers --dclick-action="/usr/share/idiomind/ifs/dclik.sh" --print-all \
    --column=icon:IMG --column=Action & printf "$info_" | yad --plug=$KEY --tabnum=3 --text-info \
    --text="<big><big><b>Idiomind v2.2-beta</b></big></big>\\n<sup>$(gettext "Vocabulary learning tool")\\n<a href='https://sourceforge.net/projects/idiomind/'>Homepage</a> (c) 2013-2015 Robin Palat</sup>" \
    --show-uri --fontname=Arial --margins=10 --wrap --text-align=center &
yad --notebook --key=$KEY --name=idiomind --class=idiomind --skip-taskbar \
    --sticky --center --window-icon=$ICON --window-icon=idiomind \
    --tab="$(gettext "Preferences")" --tab="  $(gettext "Addons")  " --borders=5 \
    --tab="  $(gettext "About")  " \
    --width=450 --height=340 --title="$(gettext "Settings")" --button="$(gettext "Close")":0
    
    ret=$?
    
    if [ $ret -eq 0 ]; then
        rm -f $DT/.lc
        cp -f "$cnf1" $DC_s/cfg.1
        
        [ ! -d  $HOME/.config/autostart ] && mkdir $HOME/.config/autostart
        config_dir=$HOME/.config/autostart
        if [[ "$(sed -n 5p $DC_s/cfg.1)" = "TRUE" ]]; then
            if [ ! -f $config_dir/idiomind.desktop ]; then
            
                if [ ! -d "$HOME/.config/autostart" ]; then
                    mkdir "$HOME/.config/autostart"
                fi
                echo "$autostart" > $config_dir/idiomind.desktop
                chmod +x $config_dir/idiomind.desktop
            fi
        else
            if [ -f $config_dir/idiomind.desktop ]; then
                rm $config_dir/idiomind.desktop
            fi
        fi
        
        ln=$(cat "$cnf1" | sed -n 18p)
        ls=$(cat "$cnf1" | sed -n 19p)
        
        if echo $ln | grep "English" && [ English != $lgtl ] ; then
            confirm "$info2" dialog-question
            [[ $? -eq 0 ]] && set_lang English en
        fi
        if echo $ln | grep "Spanish" && [ Spanish != $lgtl ] ; then
            confirm "$info2" dialog-question
            [[ $? -eq 0 ]] && set_lang Spanish es
        fi
        if echo $ln | grep "Italian" && [ Italian != $lgtl ] ; then
            confirm "$info2" dialog-question
            [[ $? -eq 0 ]] && set_lang Italian it
        fi
        if echo $ln | grep "Portuguese" && [ Portuguese != $lgtl ] ; then
            confirm "$info2" dialog-question
            [[ $? -eq 0 ]] && set_lang Portuguese pt
        fi
        if echo $ln | grep "German" && [ German != $lgtl ] ; then
            confirm "$info2" dialog-question
            [[ $? -eq 0 ]] && set_lang German de
        fi
        if echo $ln | grep "Japanese" && [ Japanese != $lgtl ] ; then
            confirm "$info2" dialog-question
            [[ $? -eq 0 ]] && set_lang Japanese ja
        fi
        if echo $ln | grep "French" && [ French != $lgtl ] ; then
            confirm "$info2" dialog-question
            [[ $? -eq 0 ]] && set_lang French fr
        fi
        if echo $ln | grep "Vietnamese" && [ Vietnamese != $lgtl ] ; then
            confirm "$info2" dialog-question
            [[ $? -eq 0 ]] && set_lang Vietnamese vi
        fi
        if echo $ln | grep "Chinese" && [ Chinese != $lgtl ] ; then
            confirm "$info2" dialog-question
            [[ $? -eq 0 ]] && set_lang Chinese zh-cn
        fi
        if echo $ln | grep "Russian" && [ Russian != $lgtl ] ; then
            confirm "$info2" dialog-question
            [[ $? -eq 0 ]] && set_lang Russian ru
        fi

        if echo $ls | grep "English" && [ English != $lgsl ] ; then
            confirm "$info1" dialog-warning
            if [ $? -eq 0 ]; then
                echo "en" > $DC_s/cfg.9
                echo "english" >> $DC_s/cfg.9
            fi
        fi
        if echo $ls | grep "French" && [ French != $lgsl ] ; then
            confirm "$info1" dialog-warning
            if [ $? -eq 0 ]; then
                echo "fr" > $DC_s/cfg.9
                echo "french" >> $DC_s/cfg.9
            fi
        fi
        if echo $ls | grep "German" && [ German != $lgsl ] ; then
            confirm "$info1" dialog-warning
            if [ $? -eq 0 ]; then
                echo "de" > $DC_s/cfg.9
                echo "german" >> $DC_s/cfg.9
            fi
        fi
        if echo $ls | grep "Italian" && [ Italian != $lgsl ] ; then
            confirm "$info1" dialog-warning
            if [ $? -eq 0 ]; then
                echo "it" > $DC_s/s/cfg.9
                echo "italian" >> $DC_s/cfg.9
            fi
        fi
        if echo $ls | grep "Japanese" && [ Japanese != $lgsl ] ; then
            confirm "$info1" dialog-warning
            if [ $? -eq 0 ]; then
                echo "ja" > $DC_s/cfg.9
                echo "japanese" >> $DC_s/cfg.9
            fi
        fi
        if echo $ls | grep "Portuguese" && [ Portuguese != $lgsl ] ; then
            confirm "$info1" dialog-warning
            if [ $? -eq 0 ]; then
                echo "pt" > $DC_s/cfg.9
                echo "portuguese" >> $DC_s/cfg.9
            fi
        fi
        if echo $ls | grep "Spanish" && [ Spanish != $lgsl ] ; then
            confirm "$info1" dialog-warning
            if [ $? -eq 0 ]; then
                echo "es" > $DC_s/cfg.9
                echo "spanish" >> $DC_s/cfg.9
            fi
        fi
        if echo $ls | grep "Vietnamese" && [ Vietnamese != $lgsl ] ; then
            confirm "$info1" dialog-warning
            if [ $? -eq 0 ]; then
                echo "vi" > $DC_s/cfg.9
                echo "vietnamese" >> $DC_s/cfg.9
            fi
        fi
        if echo $ls | grep "Chinese" && [ Chinese != $lgsl ] ; then
            confirm "$info1" dialog-warning
            if [ $? -eq 0 ]; then
                echo "zh-cn" > $DC_s/cfg.9
                echo "chinese" >> $DC_s/cfg.9
            fi
        fi
        if echo $ls | grep "Russian" && [ Russian != $lgsl ] ; then
            confirm "$info1" dialog-warning
            if [ $? -eq 0 ]; then
                echo "ru" > $DC_s/cfg.9
                echo "russian" >> $DC_s/cfg.9
            fi
        fi

        rm -f $cnf1 $cnf2 $cnf3 & exit 1
        
    elif [ $ret -eq 1 ]; then
        rm -f $cnf1 $cnf2 $cnf3 & exit 1
        
    else
        rm -f $cnf1 $cnf2 $cnf3 & exit 1
    fi
exit 0

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

source /usr/share/idiomind/ifs/c.conf
Encoding=UTF-8
wth=520
eht=400
info1="$(gettext "Do you want to change the interface language program?")"
info2="$(gettext "You want to change the language setting to learn?")"
cd "$DS/addons"

autostart="[Desktop Entry]
Name=Idiomind
GenericName=Learning Tool
Comment=Vocabulary learning tool
Exec=idiomind autostart
Terminal=false
Type=Application
Icon=idiomind
StartupWMClass=Idiomind"

lang=('English' 'Spanish' 'Italian' 'Portuguese' 'German' \
'Japanese' 'French' 'Vietnamese' 'Chinese' 'Russian')
sets=('grammar' 'list' 'tasks' 'trans' 'text' 'audio' \
'repeat' 'videos' 'loop' 't_lang' 's_lang' 'synth' 'edit')
c=$(echo $(($RANDOM%100000))); KEY=$c
cnf1=$(mktemp "$DT"/cnf1.XXXX)

if [ ! -d "$DC" ]; then
    "$DS/ifs/1u.sh" & exit
fi

function confirm() {
    
    yad --form --center --borders=8 --image=$2 \
    --title="Idiomind" --on-top --window-icon=idiomind \
    --skip-taskbar --button="$(gettext "No")":1 \
    --button="$(gettext "Yes")":0 --text="$1\n" \
    --width=350 --height=120
}

function set_lang() {
    
    if [ ! -d "$DM_t/$1" ]; then
        mkdir "$DM_t/$1"
        mkdir "$DM_t/$1/.share"; fi
    echo "$1" > "$DC_s/6.cfg"
    echo "$lgsl" >> "$DC_s/6.cfg"
    "$DS/stop.sh" L
    if [ -f "$DM/topics/$1/.8.cfg" ]; then
        lst=$(sed -n 1p "$DM/topics/$1/.8.cfg")
        "$DM/topics/$1/$lst/tpc.sh" 1
    else
        rm "$DC_s/4.cfg" && touch "$DC_s/4.cfg"
    fi
    "$DS/mngr.sh" mkmn
}

if [ ! -f "$DC_s/1.cfg" ] || [ -z "$(<"$DC_s/1.cfg")" ]; then
sets=('grammar' 'list' 'tasks' 'trans' 'text' 'audio' \
'repeat' 'videos' 'loop' 't_lang' 's_lang' 'synth' 'edit'\
 'words' 'sentences' 'marks' 'practice' 'news' 'saved')
n=0; > "$DC_s/1.cfg"
while [ $n -lt 19 ]; do
    echo -e "${sets[$n]}=\"\"" >> "$DC_s/1.cfg"
    ((n=n+1))
done
fi

source "$DC_s/1.cfg"
if [ "$text" != TRUE ] && [ "$audio" != TRUE ]; then audio=TRUE; fi
yad --plug=$KEY --tabnum=1 \
--separator='|' --form --align=right --scroll \
--always-print-result --print-all \
--field="$(gettext "General Options")\t":lbl " " \
--field=":LBL" " " \
--field="$(gettext "Colorize words to grammar")":CHK "$grammar" \
--field="$(gettext "List words after adding a sentence")":CHK "$list" \
--field="$(gettext "Perform tasks at startup")":CHK "$tasks" \
--field="$(gettext "Use automatic translation, if available")":CHK "$trans" \
--field=" :LBL" " " \
--field="$(gettext "Play Options")\t":LBL " " \
--field=":LBL" " " \
--field="$(gettext "Text")":CHK "$text" \
--field="$(gettext "Audio")":CHK "$audio" \
--field="$(gettext "Repeat")":CHK "$repeat" \
--field="$(gettext "Only videos")":CHK "$videos" \
--field="$(gettext "Time for play Loop")":SCL "$loop" \
--field=" :LBL" " " \
--field="$(gettext "Languages")\t":LBL " " \
--field=":LBL" " " \
--field="$(gettext "Language Learning")":CB "$lgtl!English!Chinese!French!German!Italian!Japanese!Portuguese!Russian!Spanish!Vietnamese" \
--field="$(gettext "Your Language")":CB "$lgsl!English!Chinese!French!German!Italian!Japanese!Portuguese!Russian!Spanish!Vietnamese" \
--field=" :LBL" "2" \
--field=":LBL" "2" \
--field="$(gettext "Speech Synthesizer (default espeak)")":CB5 "$synth" \
--field="$(gettext "Use this program for audio editing")":CB5 "$edit" \
--field="$(gettext "Check for Updates")":BTN "$DS/ifs/tls.sh check_updates" \
--field="$(gettext "Quick Help")":BTN "$DS/ifs/tls.sh help" \
--field="$(gettext "Topic Saved")":BTN "$DS/ifs/upld.sh 'vsd'" \
--field="$(gettext "Feedback")":BTN "$DS/ifs/tls.sh 'fback'" \
--field="$(gettext "About")":BTN "$DS/ifs/tls.sh 'about'" > "$cnf1" &
cat "$DC_s/2.cfg" | yad --plug=$KEY --tabnum=2 --list --expand-column=2 \
--text="<sub>  $(gettext "Double click to set") </sub>" --print-all \
--no-headers --dclick-action="$DS/ifs/dclik.sh" \
--column=icon:IMG --column=Action &
yad --notebook --key=$KEY --name=Idiomind --class=Idiomind \
--sticky --center --window-icon=idiomind --borders=5  \
--tab="$(gettext "Preferences")" --tab="$(gettext "Addons")" \
--width=$wth --height=$eht --title="$(gettext "Settings")" \
--button="$(gettext "Cancel")":1 --button="$(gettext "OK")":0
ret=$?

    if [ $ret -eq 0 ]; then
        n=1; v=0
        while [ $n -le 21 ]; do
            val=$(cut -d "|" -f$n < "$cnf1")
            if [ -n "$val" ]; then
                sed -i "s/${sets[$v]}=.*/${sets[$v]}=$val/g" "$DC_s/1.cfg"
                ((v=v+1))
            fi
            ((n=n+1))
        done

        val=$(cut -d "|" -f22 < "$cnf1")
        sed -i "s/${sets[11]}=.*/${sets[11]}=$val/g" "$DC_s/1.cfg"
        val=$(cut -d "|" -f23 < "$cnf1")
        sed -i "s/${sets[12]}=.*/${sets[12]}=$val/g" "$DC_s/1.cfg"
        
        [ ! -d  "$HOME/.config/autostart" ] \
        && mkdir "$HOME/.config/autostart"
        config_dir="$HOME/.config/autostart"
        
        if cut -d "|" -f3 < "$cnf1" | grep "TRUE"; then
            if [ ! -f "$config_dir/idiomind.desktop" ]; then
                echo "$autostart" > "$config_dir/idiomind.desktop"
            fi
        else
            if [ -f "$config_dir/idiomind.desktop" ]; then
                rm "$config_dir/idiomind.desktop"
            fi
        fi
        
        n=0
        while [ $n -lt 10 ]; do
            if cut -d "|" -f18 < "$cnf1" | grep "${lang[$n]}" && \
            [ "${lang[$n]}" != "$lgtl" ] ; then
                confirm "$info2" dialog-question
                [ $? -eq 0 ] && set_lang "${lang[$n]}"
                lgtl="${lang[$n]}" & break
            fi
            ((n=n+1))
        done
        
        n=0
        while [ $n -lt 10 ]; do
            if cut -d "|" -f19 < "$cnf1" | grep "${lang[$n]}" && \
            [ "${lang[$n]}" != "$lgsl" ] ; then
                confirm "$info1" dialog-warning
                if [ $? -eq 0 ]; then
                    echo "$lgtl" > "$DC_s/6.cfg"
                    echo "${lang[$n]}" >> "$DC_s/6.cfg"
                    break
                fi
            fi
            ((n=n+1))
        done
        
        rm -f "$cnf1" "$DT/.lc" & exit 1
    else
        rm -f "$cnf1" "$DT/.lc" & exit 1
    fi
    

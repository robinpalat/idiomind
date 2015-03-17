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
wth=$(($(sed -n 2p $DC_s/10.cfg)-450))
eht=$(($(sed -n 3p $DC_s/10.cfg)-80))
IFS=$'\n'
info1="$(echo "$(gettext "Do you want to change the interface language program?")" | xargs -n6 | sed 's/^/  /')"
info2="$(echo "$(gettext "You want to change the language setting to learn?")" | xargs -n6 | sed 's/^/  /')"
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

langs="English
Spanish
Italian
Portuguese
German
Japanese
French
Vietnamese
Chinese
Russian"

c=$(echo $(($RANDOM%100000))); KEY=$c
cnf1=$(mktemp $DT/cnf1.XXXX)

if [ ! -d "$DC" ]; then
    "$DS/ifs/1u.sh" & exit
fi

function confirm() {
    
    yad --form --center --borders=8 --image=$2 \
    --title="Idiomind" --on-top --window-icon=idiomind \
    --skip-taskbar --button="$(gettext "Nope")":1 \
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

[ ! -f "$DC_s/1.cfg" ] && touch "$DC_s/1.cfg"
n=1
while read val; do
    declare set"$n"="$val"
    ((n=n+1))
done < "$DC_s/1.cfg"
[ "$set9" = "$set10" ] && set10=TRUE

yad --plug=$KEY --tabnum=1 --borders=5 --scroll --columns=2 \
--separator="\n" --form --no-headers --align=right \
--field=" :LBL" " " \
--field=" :LBL" " " \
--field="$(gettext "Words")":CHK "$set1" \
--field="$(gettext "Sentences")":CHK "$set2" \
--field="$(gettext "Marks")":CHK "$set3" \
--field="$(gettext "Difficult and learning")":CHK "$set4" \
--field="$(gettext "New Episodes")":CHK "$set5" \
--field="$(gettext "Saved Episodes")":CHK "$set6" \
--field=" :LBL" " " \
--field=" :LBL" " " \
--field="$(gettext "Colorize words to grammar")":CHK "$set7" \
--field="$(gettext "List words after adding a sentence")":CHK "$set8" \
--field=" :LBL" " " \
--field="$(gettext "Speech Synthesizer Default espeak")":LBL " " \
--field="$(gettext "Use this program for audio editing")":LBL " " \
--field="$(gettext "Time for play Loop")":LBL " " \
--field=" :LBL" " " \
--field=" :LBL" " " \
--field="$(gettext "Language Learning")":LBL " " \
--field="$(gettext "Your Language")":LBL " " \
--field=" :LBL" " " \
--field=" :LBL" " " \
--field="<small>$(gettext "Check for Updates")</small>":BTN "$DS/ifs/tls.sh check_updates" \
--field="<small>$(gettext "Quick Help")</small>":BTN "$DS/ifs/tls.sh help" \
--field=" :LBL" " " \
--field="$(gettext "Play Options")\t":LBL " " \
--field=":LBL" " " \
--field="$(gettext "Texto")":CHK "$set9" \
--field="$(gettext "Audio")":CHK "$set10" \
--field="$(gettext "Repeat")":CHK "$set11" \
--field="$(gettext "Only videos")":CHK "$set12" \
--field=" :LBL" " " \
--field=" :LBL" " " \
--field="$(gettext "General Options")\t":lbl " " \
--field=":LBL" " " \
--field="$(gettext "Perform tasks at startup")":CHK "$set13" \
--field="$(gettext "Usar traduccion automatica\nsi esta disponible")":CHK "$set14" \
--field=" :LBL" " " \
--field=" ":CB5 "$set15" \
--field=" ":CB5 "$set16" \
--field=" ":SCL "$set17" \
--field="\n$(gettext "Languages")\t":LBL " " \
--field=":LBL" " " \
--field="":CB "$lgtl!English!Chinese!French!German!Italian!Japanese!Portuguese!Russian!Spanish!Vietnamese" \
--field="":CB "$lgsl!English!Chinese!French!German!Italian!Japanese!Portuguese!Russian!Spanish!Vietnamese" \
--field=" :LBL" " " \
--field=" :LBL" " " \
--field="<small>$(gettext "Topic Saved")</small>":BTN "$DS/ifs/upld.sh 'vsd'" \
--field="<small>$(gettext "Feedback")</small>":BTN "$DS/ifs/tls.sh 'fback'" \
--field="<small>$(gettext "About")</small>":BTN "$DS/ifs/tls.sh 'about'" | sed '/^$/d' > "$cnf1" &
cat "$DC_s/2.cfg" | yad --plug=$KEY --tabnum=2 --list --expand-column=2 \
--text="<sub>  $(gettext "Double click to set") </sub>" --print-all \
--no-headers --dclick-action="$DS/ifs/dclik.sh" \
--column=icon:IMG --column=Action &
yad --notebook --key=$KEY --name=Idiomind --class=Idiomind \
--sticky --center --window-icon=idiomind --borders=5  \
--tab="$(gettext "Preferences")" --tab="  $(gettext "Addons")  " \
--width=$wth --height=$eht --title="$(gettext "Settings")" \
--button="$(gettext "Cancel")":1 --button="$(gettext "OK")":0
    
    ret=$?
    
    if [ $ret -eq 0 ]; then

        [ ! -d  "$HOME/.config/autostart" ] \
        && mkdir "$HOME/.config/autostart"
        config_dir="$HOME/.config/autostart"
        if [[ "$(sed -n 36p "$DC_s/1.cfg")" = "TRUE" ]]; then
            if [ ! -f "$config_dir/idiomind.desktop" ]; then
                echo "$autostart" > "$config_dir/idiomind.desktop"
                chmod +x "$config_dir/idiomind.desktop"
            fi
        else
            if [ -f "$config_dir/idiomind.desktop" ]; then
                rm "$config_dir/idiomind.desktop"
            fi
        fi
        
        while read -r lang; do
            if sed -n 18p "$cnf1" | grep "$lang" && \
            [ "$lang" != "$lgtl" ] ; then
                confirm "$info2" dialog-question
                [ $? -eq 0 ] && set_lang "$lang"
                lgtl="$lang" & break
            fi
        done <<< "$langs"
        
        while read -r lang; do
            if sed -n 19p "$cnf1" | grep "$lang" && \
            [ "$lang" != "$lgsl" ] ; then
                confirm "$info1" dialog-warning
                if [ $? -eq 0 ]; then
                    echo "$lgtl" > "$DC_s/6.cfg"
                    echo "$lang" >> "$DC_s/6.cfg"
                    break
                fi
            fi
        done <<< "$langs"
        
        if ([ "$(cat "$cnf1")" != "$(cat "$DC_s/1.cfg")" ] \
        && [ -n "$(cat "$cnf1")" ]); then
            cat "$cnf1" > "$DC_s/1.cfg"; fi

        rm -f "$cnf1" "$DT/.lc" & exit 1
    else
        rm -f "$cnf1" "$DT/.lc" & exit 1
    fi

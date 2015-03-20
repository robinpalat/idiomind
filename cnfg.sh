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
wth=$(($(sed -n 2p $DC_s/10.cfg)-500))
eht=$(($(sed -n 3p $DC_s/10.cfg)-200))
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

sets=('grammar' 'list' 'tasks' 'trans' 'text' 'audio' \
'repeat' 'videos' 'loop' 't_lang' 's_lang' 'synth' 'edit')

c=$(echo $(($RANDOM%100000))); KEY=$c
> $DT/cnf1
cnf1=$DT/cnf1

if [ ! -d "$DC" ]; then
    "$DS/ifs/1u.sh" & exit
fi



#sed -i '${n}s/.*/TRUE/' $DC_s/cfg.5

#sed -i "3s/size=.*/size=$du/" "$DC_a/1.cfg"

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

if [ ! -f "$DC_s/1.cfg" ]; then
sets=('words' 'sentences' 'marks' 'difficult' 'news' 'archive' \
'text' 'audio' 'grammar' 'repeat' 'videos' 'list' \
'synth' 'edit' 'loop' 'tasks' 'trans' 't_lang' 's_lang')
n=0; > "$DC_s/1.cfg"
while [ $n -le 18 ]; do
    echo -e "${sets[$n]}=\"\"" >> "$DC_s/1.cfg"
    ((n=n+1))
done
fi



#declare set"$n"="${sets[$n]}=\"$val\""


#sed -i '/${sets[$n]}=.*/a\${sets[$n]}=11'



#sed -i "s/${sets[2]}=.*/${sets[2]}=25/g" "$DC_s/1.cfg" # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!



#n=1
#while read val; do
    #declare set"$n"="${sets[$n]}=\"$val\""
    

    #((n=n+1))
#done < "$DC_s/1.cfg"




source "$DC_s/1.cfg"
[ "$synth" = FALSE ] && synth="_"
[ "$edit" = FALSE ] && edit="_"
[ "$synth" = TRUE ] && synth="_"
[ "$edit" = TRUE ] && edit="_"
[ -z "$synth" ] && synth="_"
[ -z "$edit" ] && edit="_"

yad --plug=$KEY --tabnum=1 \
--separator="|" --form --align=right --scroll \
--always-print-result --print-all \
--field="$(gettext "General Options")\t":lbl " " \
--field=":LBL" " " \
--field="$(gettext "Colorize words to grammar")":CHK "$grammar" \
--field="$(gettext "List words after adding a sentence")":CHK "$list" \
--field="$(gettext "Perform tasks at startup")":CHK "$tasks" \
--field="$(gettext "Usar traduccion automatica si esta disponible")":CHK "$trans" \
--field=" :LBL" " " \
--field="$(gettext "Play Options")\t":LBL " " \
--field=":LBL" " " \
--field="$(gettext "Texto")":CHK "$text" \
--field="$(gettext "Audio")":CHK "$audio" \
--field="$(gettext "Repeat")":CHK "$repeat" \
--field="$(gettext "Only videos")":CHK "$videos" \
--field="$(gettext "Time for play Loop")":SCL "$loop" \
--field=" :LBL" " " \
--field="$(gettext "Languages")\t":LBL " " \
--field=":LBL" " " \
--field="$(gettext "Language Learning")":CB "$lgtl!English!Chinese!French!German!Italian!Japanese!Portuguese!Russian!Spanish!Vietnamese" \
--field="$(gettext "Your Language")":CB "$lgsl!English!Chinese!French!German!Italian!Japanese!Portuguese!Russian!Spanish!Vietnamese" \
--field=" :LBL" " " \
--field=":LBL" " " \
--field="$(gettext "Speech Synthesizer Default espeak")":CB5 "$synth" \
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
        while [ $n -le 24 ]; do
            val=$(cut -d "|" -f$n < "$cnf1")
            if [ -n "$val" ] || [ $n = 22] || [ $n = 23 ]; then
                sed -i "s/${sets[$v]}=.*/${sets[$v]}=$val/g" "$DC_s/1.cfg"
                ((v=v+1))
            fi
            ((n=n+1))
        done

        [ ! -d  "$HOME/.config/autostart" ] \
        && mkdir "$HOME/.config/autostart"
        config_dir="$HOME/.config/autostart"
        if [[ "$(sed -n 5p "$DC_s/1.cfg")" = "TRUE" ]]; then
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
            if sed -n 12p "$cnf1" | grep "$lang" && \
            [ "$lang" != "$lgtl" ] ; then
                confirm "$info2" dialog-question
                [ $? -eq 0 ] && set_lang "$lang"
                lgtl="$lang" & break
            fi
        done <<< "$langs"
        
        while read -r lang; do
            if sed -n 13p "$cnf1" | grep "$lang" && \
            [ "$lang" != "$lgsl" ] ; then
                confirm "$info1" dialog-warning
                if [ $? -eq 0 ]; then
                    echo "$lgtl" > "$DC_s/6.cfg"
                    echo "$lang" >> "$DC_s/6.cfg"
                    break
                fi
            fi
        done <<< "$langs"
        
        #if ([ "$(cat "$cnf1")" != "$(cat "$DC_s/1.cfg")" ] \
        #&& [ -n "$(cat "$cnf1")" ]); then
            #cat "$cnf1" > "$DC_s/1.cfg"; fi

        rm -f "$DT/.lc" & exit 1
    else
        rm -f "$DT/.lc" & exit 1
    fi

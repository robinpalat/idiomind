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
source $DS/ifs/mods/cmns.sh
DCF="$DC/addons/Learning with news"
DSF="$DS/addons/Learning with news"

if [ ! -d $DM_tl/Feeds ]; then

    mkdir $DM_tl/Feeds
    mkdir $DM_tl/Feeds/.conf
    mkdir $DM_tl/Feeds/content
    mkdir $DM_tl/Feeds/kept
    mkdir $DM_tl/Feeds/kept/.audio
    mkdir $DM_tl/Feeds/kept/words
    mkdir "$DC_a/Learning with news"
    cd $DM_tl/Feeds/.conf/
    touch cfg.0 cfg.1 cfg.3 cfg.4 .updt.lst
fi

if [ ! -d "$DC_a/Learning with news/$lgtl" ]; then

    mkdir "$DC_a/Learning with news/$lgtl"
    mkdir "$DC_a/Learning with news/$lgtl/rss"
    cp -f "$DSF/examples/$lgtl" "$DCF/$lgtl/rss/$sample"
fi


[ -f "$DCF/$lgtl/.rss" ] && url_rss=$(sed -n 1p "$DCF/$lgtl/.rss")

if [ -z "$1" ]; then

    [[ -z "$url_rss" ]] && url_rss=" "
    cd "$DCF/$lgtl/rss"
    DIR1="$DC/addons/Learning with news"
    [ -f "$DIR1/.cnf" ] && st2=$(sed -n 1p "$DIR1/.cnf") || st2=FALSE

    scrp=$(cd "$DCF/$lgtl/rss/"; ls * | egrep -v "$url_rss" \
    | tr "\\n" '!' | sed 's/!\+$//g')

    CNFG=$(yad --on-top --form --center \
    --text="$(gettext "Updates RSS feeds") $lgtl\n" --borders=15 \
    --window-icon=idiomind --skip-taskbar \
    --width=420 --height=300 --always-print-result \
    --title="Feeds - $lgtl" \
    --button="$(gettext "Delete")":2 \
    --button="gtk-add:5" \
    --button="$(gettext "Update")":4 \
    --field="  $(gettext "Active subscription"):CB" "$url_rss!$scrp" \
    --field="$(gettext "Update at startup")":CHK $st2)
    ret=$?
        
        st1="$(echo "$CNFG" | cut -d "|" -f1)"
        st2="$(echo "$CNFG" | cut -d "|" -f2)"
        
        if [ $ret -eq 1 ]; then
            sed -i "1s/.*/$st2/" "$DIR1/.cnf" & exit 1

        elif [ $ret -eq 2 ]; then
            if echo "$st1" | grep -o "Sample"; then
            
                "$DSF/cnfg.sh" & exit
                
            elif echo "$st1" | grep -o "Sample"; then

                "$DSF/cnfg.sh" & exit

            else
                msg_2 "$(gettext " Are you sure you want to delete this subscription?") \n\n" dialog-question "$(gettext "Yes")" "$(gettext "No")"

                    ret=$(echo $?)
                    
                    if [ $ret -eq 1 ]; then
                        "$DSF/cnfg.sh" & exit
                    
                    elif [ $ret -eq 0 ]; then
                        if [ "$(cat "$DCF/$lgtl/.rss")" = "$st1" ]; then
                            rm "$DCF/$lgtl/.rss" "$DCF/$lgtl/link"
                        fi
                        rm "$DCF/$lgtl/rss/$st1"
                        "$DSF/cnfg.sh" & exit
                    fi
            fi
                    
        elif [ $ret -eq 5 ]; then
        
            dirs="$DCF/$lgtl/rss"
            nwfd=$(yad --width=480 --height=100 \
            --center --on-top --window-icon=idiomind --align=right \
            --skip-taskbar --button="$(gettext "Cancel")":1 --button=Ok:0 \
            --form --title=" $(gettext "New Chanel")" --borders=5 \
            --field=""$(gettext "Name")":: " "" \
            --field=""$(gettext "URL")":: " "" \ )
            
                if [[ -z "$(echo "$nwfd" | cut -d "|" -f1)" ]]; then
                    "$DSF/cnfg.sh" & exit
                elif [[ -z "$(echo "$nwfd" | cut -d "|" -f2)" ]]; then
                    "$DSF/cnfg.sh" & exit
                fi
            
                if [ "$?" -eq 0 ]; then
                    name=$(echo "$nwfd" | cut -d "|" -f1)
                    link=$(echo "$nwfd" | cut -d "|" -f2)
                    
                    [[ "$(echo "$name" | wc -c)" -gt 40 ]] && \
                    nme="${name:0:37}..." || nme="$name"
                    
                    echo '#!/bin/bash
                    source /usr/share/idiomind/ifs/c.conf
                    cd "$DC_a/Learning with news/$lgtl/rss"
                    echo "'$nme'" > ../.rss
                    echo '$link' > ../link
                    exit' > "$dirs/$nme"
                    chmod +x  "$dirs/$nme"
                    "$DSF/cnfg.sh" & exit
                    
                elif [ "$?" -eq 1 ]; then
                    "$DSF/cnfg.sh" & exit
                fi
        
        elif [ $ret -eq 4 ]; then
            sh "$DCF/$lgtl/rss/$st1"
            "$DSF/strt.sh" & exit 1
        else
            sed -i "1s/.*/$st2/" "$DIR1/.cnf"
            exit 1
        fi
        
elif [ "$1" = NS ]; then

    msg "$(gettext "Error")" info

elif [ "$1" = edit ]; then

    slct=$(mktemp $DT/slct.XXXX)

if [[ "$(cat "$DM_tl/Feeds/.conf/cfg.0" | wc -l)" -ge 20 ]]; then
dd="id01
$DSF/images/save.png
$(gettext "Create topic")
id02
$DSF/images/del.png
$(gettext "Delete news")
id03
$DSF/images/del.png
$(gettext "Delete saved")
id04
$DSF/images/edit.png
$(gettext "Subscriptions")"
else
dd="id02
$DSF/images/del.png
$(gettext "Delete news")
id03
$DSF/images/del.png
$(gettext "Delete saved")
id04
$DSF/images/edit.png
$(gettext "Subscriptions")"
fi

    echo "$dd" | yad --list --on-top \
    --expand-column=2 --center --print-column=1 \
    --width=290 --name=idiomind --class=idiomind \
    --height=240 --title="$(gettext "Edit")" --skip-taskbar \
    --window-icon=idiomind --no-headers --hide-column=1 \
    --buttons-layout=end --borders=0 --button=Ok:0 \
    --column=id:TEXT --column=icon:IMG --column=Action:TEXT > "$slct"
    ret=$?
    slt=$(cat "$slct")
    
    if  [[ "$ret" -eq 0 ]]; then
        if echo "$slt" | grep -o "id01"; then
            "$DSF/add.sh" new_topic
        elif echo "$slt" | grep -o "id02"; then
            "$DSF/mngr.sh" delete_news
        elif echo "$slt" | grep -o "id03"; then
            "$DSF/mngr.sh" delete_saved
        elif echo "$slt" | grep -o "id04"; then
            "$DSF/cnfg.sh"
        fi
        rm -f "$slct"

    elif [[ "$ret" -eq 1 ]]; then
        exit 1
    fi
fi

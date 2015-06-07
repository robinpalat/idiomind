#!/bin/bash
# -*- ENCODING: UTF-8 -*-

[ -z "$DM" ] && source /usr/share/idiomind/ifs/c.conf
source "$DS/ifs/mods/cmns.sh"
DMC="$DM_tl/Podcasts/cache"
DCP="$DM_tl/Podcasts/.conf/"
date=$(date +%d)

if [ "$1" = new_item ]; then

    DMC="$DM_tl/Podcasts/cache"
    DCP="$DM_tl/Podcasts/.conf"
    fname="$(nmfile "${item}")"
    if [ -s "$DCP/2.lst" ]; then
    sed -i -e "1i$item\\" "$DCP/2.lst"
    else
    echo "$item" > "$DCP/2.lst"; fi
    check_index1 "$DCP/2.lst" "$DCP/.22.cfg"
    notify-send -i info "$(gettext "Saved")" "$item" -t 3000
    exit
    
elif [ "$1" = sv_as ]; then

    fname=$(echo -n "$item" | md5sum | rev | cut -c 4- | rev)
    [ -f "$DMC/$fname.mp3" ] && file="$DMC/$fname.mp3"
    [ -f "$DMC/$fname.ogg" ] && file="$DMC/$fname.ogg"
    [ -f "$DMC/$fname.m4v" ] && file="$DMC/$fname.m4v"
    [ -f "$DMC/$fname.mp4" ] && file="$DMC/$fname.mp4"
    cd "$HOME"
    sv=$(yad --file --save --title="$(gettext "Save as")" \
    --filename="$item${file: -4}" \
    --window-icon="$DS/images/icon.png" \
    --skip-taskbar --center --on-top \
    --width=600 --height=500 --borders=10 \
    --button="$(gettext "Cancel")":1 \
    --button="$(gettext "Save")":0)
    ret=$?
    if [[ $ret -eq 0 ]]; then
    cp "$file" "$sv"; fi
    
        
elif [ "$1" = delete_item ]; then

    touch "$DT/ps_lk"
    fname="$(nmfile "${item}")"
    
    if ! grep -Fxo "$item" < "$DCP/1.lst"; then
    
        msg_2 "$(gettext "Are you sure you want to delete this episode here?")\n" gtk-delete "$(gettext "Yes")" "$(gettext "Cancel")" "$(gettext "Confirm")"
        ret=$(echo "$?")
    
        if [[ $ret -eq 0 ]]; then
            
            [ "$DMC/$fname.mp3" ] && rm "$DMC/$fname.mp3"
            [ "$DMC/$fname.ogg" ] && rm "$DMC/$fname.ogg"
            [ "$DMC/$fname.mp4" ] && rm "$DMC/$fname.mp4"
            [ "$DMC/$fname.m4v" ] && rm "$DMC/$fname.m4v"
            [ "$DMC/$fname.flv" ] && rm "$DMC/$fname.flv"
            [ "$DMC/$fname.jpg" ] && rm "$DMC/$fname.jpg"
            [ "$DMC/$fname.png" ] && rm "$DMC/$fname.png"
            [ "$DMC/$fname.html" ] && rm "$DMC/$fname.html"
            [ "$DMC/$fname.item" ] && rm "$DMC/$fname.item"
            cd "$DCP"
            grep -vxF "$item" "$DCP/.22.cfg" > "$DCP/.22.cfg.tmp"
            sed '/^$/d' "$DCP/.22.cfg.tmp" > "$DCP/.22.cfg"
            grep -vxF "$item" "$DCP/2.lst" > "$DCP/2.lst.tmp"
            sed '/^$/d' "$DCP/2.lst.tmp" > "$DCP/2.lst"
            rm "$DCP"/*.tmp; fi

    else
        notify-send -i info "$(gettext "Done")" "$item"
        cd "$DCP"
        grep -vxF "$item" "$DCP/.22.cfg" > "$DCP/.22.cfg.tmp"
        sed '/^$/d' "$DCP/.22.cfg.tmp" > "$DCP/.22.cfg"
        grep -vxF "$item" "$DCP/2.lst" > "$DCP/2.lst.tmp"
        sed '/^$/d' "$DCP/2.lst.tmp" > "$DCP/2.lst"
        rm "$DCP"/*.tmp
    fi
            
    rm -f "$DT/ps_lk"; exit 1

elif [ "$1" = deleteall ]; then
    
    if [ "$(wc -l < "$DCP/2.lst")" -gt 0 ]; then
    chk="--field="$(gettext "Delete saved episodes")":CHK"; fi
    if [ "$(wc -l < "$DCP/1.lst")" -lt 0 ]; then exit 1; fi
    
    dl=$(yad --form --title="$(gettext "Confirm")" \
    --image=gtk-delete \
    --name=Idiomind --class=Idiomind \
    --always-print-result --print-all --separator="|" \
    --window-icon="$DS/images/icon.png" --center --on-top \
    --width=400 --height=120 --borders=3 \
    --text="$(gettext "Are you sure you want to delete all episodes?")" "$chk" \
    --button="$(gettext "Cancel")":1 \
    --button="$(gettext "Yes")":0)
    ret="$?"
            
    if [[ $ret -eq 0 ]]; then

        rm "$DM_tl/Podcasts/cache"/*
        rm "$DM_tl/Podcasts/.conf/1.lst"
        rm "$DM_tl/Podcasts/$date"
        touch "$DM_tl/Podcasts/.conf/1.lst"

        if [ $(cut -d "|" -f1 <<<"$dl") = TRUE ]; then

            rm "$DCP/2.lst" "$DCP/.22.cfg"
            touch "$DCP/2.lst" "$DCP/.22.cfg"
        fi
    fi

    exit
fi

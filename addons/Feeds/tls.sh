#!/bin/bash

source /usr/share/idiomind/ifs/c.conf
source "$DS/ifs/mods/cmns.sh"

if [ "$1" = play ]; then
    
    killall play
    DCP="$DM_tl/Feeds/.conf"
    [ -f "$DCP/0.cfg" ] && st3=$(sed -n 2p "$DCP/0.cfg") || st3=FALSE
    [ $st3 = FALSE ] && fs="" || fs='-fs'
    
    if [ -f "$DM_tl/Feeds/cache/$2.mp3" ]; then
        play "$DM_tl/Feeds/cache/$2.mp3" & exit
    elif [ -f "$DM_tl/Feeds/cache/$2.ogg" ]; then
        play "$DM_tl/Feeds/cache/$2.ogg" & exit
    elif [ -f "$DM_tl/Feeds/cache/$2.mp4" ]; then
        mplayer "$fs" "$DM_tl/Feeds/cache/$2.mp4" \
        >/dev/null 2>&1 & exit
    elif [ -f "$DM_tl/Feeds/cache/$2.m4v" ]; then
        mplayer "$fs" "$DM_tl/Feeds/cache/$2.m4v" \
        >/dev/null 2>&1 & exit
    elif [ -f "$DM_tl/Feeds/cache/$2.avi" ]; then
        mplayer "$fs" "$DM_tl/Feeds/cache/$2.avi" \
        >/dev/null 2>&1 & exit
    elif [ -f "$DM_tl/Feeds/cache/$2.flv" ]; then
        mplayer "$fs" "$DM_tl/Feeds/cache/$2.flv" \
        >/dev/null 2>&1 & exit
    elif [ -f "$DM_tl/Feeds/cache/$2.mov" ]; then
        mplayer "$fs" "$DM_tl/Feeds/cache/$2.mov" \
        >/dev/null 2>&1 & exit
    fi
fi

tmpl1="<?xml version='1.0' encoding='UTF-8'?>
<xsl:stylesheet version='1.0'
xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
xmlns:itunes='http://www.itunes.com/dtds/podcast-1.0.dtd'
xmlns:media='http://search.yahoo.com/mrss/'
xmlns:atom='http://www.w3.org/2005/Atom'>
<xsl:output method='text'/>
<xsl:template match='/'>
<xsl:for-each select='/rss/channel'>
<xsl:value-of select='title'/><xsl:text>-!-</xsl:text>
<xsl:value-of select='link'/><xsl:text>-!-</xsl:text>
<xsl:value-of select='image'/><xsl:text>-!-</xsl:text>
<xsl:value-of select='image/@url'/><xsl:text>-!-</xsl:text>
<xsl:value-of select='itunes:image[@type=\"image/jpeg\"]/@href'/><xsl:text>-!-</xsl:text>
</xsl:for-each>
</xsl:template>
</xsl:stylesheet>"
tmpl2="<?xml version='1.0' encoding='UTF-8'?>
<xsl:stylesheet version='1.0'
xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
xmlns:itunes='http://www.itunes.com/dtds/podcast-1.0.dtd'
xmlns:media='http://search.yahoo.com/mrss/'
xmlns:atom='http://www.w3.org/2005/Atom'>
<xsl:output method='text'/>
<xsl:template match='/'>
<xsl:for-each select='/rss/channel/item'>
<xsl:value-of select='enclosure/@url'/><xsl:text>-!-</xsl:text>
<xsl:value-of select='media:cache[@type=\"audio/mpeg\"]/@url'/><xsl:text>-!-</xsl:text>
<xsl:value-of select='title'/><xsl:text>-!-</xsl:text>
<xsl:value-of select='media:cache[@type=\"audio/mpeg\"]/@duration'/><xsl:text>-!-</xsl:text>
<xsl:value-of select='itunes:summary'/><xsl:text>-!-</xsl:text>
<xsl:value-of select='description'/><xsl:text>EOL</xsl:text>
</xsl:for-each>
</xsl:template>
</xsl:stylesheet>"
tmpl3="<?xml version='1.0' encoding='UTF-8'?>
<xsl:stylesheet version='1.0'
xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
xmlns:itunes='http://www.itunes.com/dtds/podcast-1.0.dtd'
xmlns:media='http://search.yahoo.com/mrss/'
xmlns:atom='http://www.w3.org/2005/Atom'>
<xsl:output method='text'/>
<xsl:template match='/'>
<xsl:for-each select='/rss/channel/item'>
<xsl:value-of select='enclosure/@url'/><xsl:text>-!-</xsl:text>
<xsl:value-of select='media:cache[@type=\"image/jpeg\"]/@url'/><xsl:text>-!-</xsl:text>
<xsl:value-of select='media:content[@type=\"image/jpeg\"]/@url'/><xsl:text>-!-</xsl:text>
<xsl:value-of select='title'/><xsl:text>-!-</xsl:text>
<xsl:value-of select='media:cache[@type=\"image/jpeg\"]/@duration'/><xsl:text>-!-</xsl:text>
<xsl:value-of select='itunes:summary'/><xsl:text>-!-</xsl:text>
<xsl:value-of select='description'/><xsl:text>EOL</xsl:text>
</xsl:for-each>
</xsl:template>
</xsl:stylesheet>"

if [ "$1" = set_channel ]; then
    
    feed="$2"
    num="$3"
    DCP="$DM_tl/Feeds/.conf"
    
    xml="$(xsltproc - "$feed" <<< "$tmpl1" 2> /dev/null)"
    items1="$(echo "$xml" | tr '\n' ' ' | tr -s '[:space:]' \
    | sed 's/EOL/\n/g' | head -n 1 | sed -r 's|-\!-|\n|g')"

    xml="$(xsltproc - "$feed" <<< "$tmpl2" 2> /dev/null)"
    items2="$(echo "$xml" | tr '\n' ' ' | tr -s [:space:] \
    | sed 's/EOL/\n/g' | head -n 1 | sed -r 's|-\!-|\n|g')"
    
    xml="$(xsltproc - "$feed" <<< "$tmpl3" 2> /dev/null)"
    items3="$(echo "$xml" | tr '\n' ' ' | tr -s [:space:] \
    | sed 's/EOL/\n/g' | head -n 1  | sed -r 's|-\!-|\n|g')"

    fchannel() {
        
        n=1;
        while read -r find; do

            if [ $(wc -w <<< "${find}") -ge 1 ] && [ -z "$name" ]; then
                name="$find"
                n=2; fi
                
            if [ -n "$(grep 'http:/' <<< "${find}")" ] && [ -z "$link" ]; then
                link="$find"
                n=3; fi
                
            if [ -n "$(grep -E '.jpeg|.jpg|.png' <<< "${find}")" ] && [ -z "$logo" ]; then
                logo="$find"; fi
                
            let n++
        done <<< "$items1"
    }
   
    ftype1() {
        
        n=1
        while read -r find; do
            [[ $n = 3 || $n = 5 || $n = 6 ]] && continue
            if ([ -n "$(grep -o -E '\.mp3|\.mp4|\.ogg|\.avi|\.m4v|\.mov|\.flv' <<< "${find}")" ] && [ -z "$media" ]); then

            media="$n"; type=1; break; fi
            let n++
        done <<< "$items2"
        
        n=3
        while read -r find; do
            if ([ $(wc -w <<< "${find}") -ge 1 ] && [ $(wc -w <<< "${find}") -le 180 ] && [ -z "$title" ]); then
            title="$n"; break; fi
            let n++
        done <<< "$items2"

        n=5
        while read -r find; do
            if ([ $(wc -w <<< "${find}") -ge 1 ] && [ -z "$summ" ]); then
            summ="$n"; break; fi
            let n++
        done <<< "$items2"
    }
    
    ftype2() {

        n=1
        while read -r find; do
            if ([ -n "$(grep -o -E '\.jpg|\.jpeg|\.png' <<< "${find}")" ] && [ -z "$image" ]); then
            image="$n"; type=2; break ; fi
            let n++
        done <<< "$items3"
        
        n=4
        while read -r find; do
            if ([ $(wc -w <<< "${find}") -ge 1 ] && [ -z "$title" ]); then
            title="$n"; break ; fi
            let n++
        done <<< "$items3"
        
        n=6
        while read -r find; do
            if ([ $(wc -w <<< "${find}") -ge 1 ] && [ -z "$summ" ]); then
                summ="$n"; break ; fi
            let n++
        done <<< "$items3"
    }

    find_images() {

        n=1
        while read -r find; do
            if ([ -n "$(grep -E '\.jpg|\.jpeg|.png' <<< "${find}")" ] && [ -z "$image" ]); then
                type=2
                image="$n"; break; fi
            if ([ -n "$(grep -o 'media:thumbnail url="[^"]*' | grep -o '[^"]*$')" <<< "${find}" ] && [ -z "$image" ]); then
                image="$n"; break; fi
                type=2
            if ([ -n "$(grep -o 'img src="[^"]*' | grep -o '[^"]*$')" <<< "${find}" ] && [ -z "$image" ]); then
                type=2
                image="$n"; break; fi
            let n++
        done <<< "$items3"
    }
    
    find_summ() {

        n=1
        while read -r find; do
            if [ $(wc -w <<< "${find}") -ge 1 ]; then
                summ="$n"; break; fi
            let n++
        done <<< "$items3"
    }
    
    fchannel
    ftype1
    if [ -z "$type" ]; then
        ftype2
        if [ -z $image ]; then
        find_images
        fi
        if [ -z $summ ]; then
            find_summ
        fi
    fi

    if [[ -n "$title" && -n "$summ" && -z "$image" && -z "$media" ]]; then
        type=3
    fi
    
    if [ -n "$type" ]; then

echo -e "channel=\"$name\"
link=\"$link\"
logo=\"$logo\"
ntype=\"$type\"
nmedia=\"$media\"
ntitle=\"$title\"
nsumm=\"$summ\"
nimage=\"$image\"
url=\"$feed\"" > "$DCP/$num.rss"

        exit 0
    else
        msg "$(gettext "Couldn't download the specified URL\n")" info
        rm -f "$DT/cpt.lock" & exit 1
    fi
    
elif [ "$1" = check ]; then

    source $DS/ifs/mods/cmns.sh
    DCP="$DM_tl/Feeds/.conf"
    DSP="$DS_a/Feeds"
    [[ -e "$DT/cpt.lock" ]] && exit || touch "$DT/cpt.lock"

    internet

    source="$DCP/$2.rss"
    [ -z "$lnk" ] && exit 1
    [ ! -f "$DCP/$2.rss" ] && printf "$tpl" > "$DCP/$2.rss"
    cp "$DCP/$2.rss" "$DCP/$2.rss_"
    podcast_items="$(xsltproc - "$lnk" <<< "$tmpl2" 2> /dev/null)"
    podcast_items="$(echo "$podcast_items" | tr '\n' ' ' | tr -s [:space:] | sed 's/EOL/\n/g' | head -n 2)"
    item="$(echo "$podcast_items" | sed -n 1p)"
    if [ -z "$(echo $item | sed 's/^ *//; s/ *$//; /^$/d')" ]; then
    msg "$(gettext "Couldn't download the specified URL\n")" info
    rm -f "$DT/cpt.lock" & exit 1
    fi
    field="$(echo "$item" | sed -r 's|-\!-|\n|g')"

    yad --scroll --columns=2 --skip-taskbar --separator='\n' \
    --width=800 --height=600 --form --on-top --window-icon=idiomind \
    --text="<small> $(gettext "\tIn this table you can define fields according to their cache,  most of the time the default values is right. ")</small>" --name=Idiomind --class=Idiomind \
    --button=gtk-apply:0 --borders=5 --title="$ttl" --always-print-result \
    --field="":CB "$(sed -n 1p $DCP/$2.rss)!$mn" \
    --field="":CB "$(sed -n 2p $DCP/$2.rss)!$mn" \
    --field="":CB "$(sed -n 3p $DCP/$2.rss)!$mn" \
    --field="":CB "$(sed -n 4p $DCP/$2.rss)!$mn" \
    --field="":CB "$(sed -n 5p $DCP/$2.rss)!$mn" \
    --field="":CB "$(sed -n 6p $DCP/$2.rss)!$mn" \
    --field="":CB "$(sed -n 7p $DCP/$2.rss)!$mn" \
    --field="":TXT "$(echo "$field" | sed -n 1p)" \
    --field="":TXT "$(echo "$field" | sed -n 2p)" \
    --field="":TXT "$(echo "$field" | sed -n 3p | sed 's/\://g')" \
    --field="":TXT "$(echo "$field" | sed -n 4p | sed 's/\://g')" \
    --field="":TXT "$(echo "$field" | sed -n 5p)" \
    --field="\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t":TXT "$(echo "$field" | sed -n 6p)" \
    --field="":TXT "$(echo "$field" | sed -n 7p)" | head -n 7 > $DT/f.tmp
    [[ -n "$(cat "$DT/f.tmp")" ]] && mv -f $DT/f.tmp "$DCP/$2.rss" || cp -f "$DCP/$2.rss_" "$DCP/$2.rss"
    [[ -f "$DCP/$2.rss_" ]] && rm "$DCP/$2.rss_"
    [[ -e "$DT/cpt.lock" ]] && rm -f "$DT/cpt.lock" & exit


elif [ "$1" = syndlg ]; then

    DCP="$DM_tl/Feeds/.conf"
    SYNCDIR="$(sed -n 1p $DCP/5.cfg)"

    cd $HOME
    DIR="$(yad --center --form --on-top --window-icon=idiomind \
    --borders=10 --separator="" --title=" " --always-print-result \
    --text="$(gettext "Mountpoint or path where new episodes should be synced.")" \
    --print-all --name=Idiomind --class=Idiomind \
    --width=460 --height=200 --field="":CDIR "$SYNCDIR" \
    --button="$(gettext "Cancel")":1 --button="gtk-apply":0)"
    [ "$?" -eq 1 ] && exit 1 

    echo "$DIR" > $DT/s.tmp
    mv -f $DT/s.tmp $DCP/5.cfg
    exit

elif [ "$1" = sync ]; then
   
    DCP="$DM_tl/Feeds/.conf"
    SYNCDIR="$(sed -n 1p $DCP/5.cfg)"

    if [ ! -d "$SYNCDIR" ]; then
            cd $HOME
            DIR="$(yad --center --form --on-top --window-icon=idiomind \
            --borders=10 --separator="" --title=" " --always-print-result \
            --text="$(gettext "Set mountpoint or path where new episodes should be synced.")" \
            --print-all --button="$(gettext "OK")":0 --name=Idiomind --class=Idiomind \
            --width=460 --height=170 --field="":CDIR "$SYNCDIR")"
            echo "$DIR" > $DT/s.tmp
            mv -f $DT/s.tmp $DCP/5.cfg
            if [ ! -d "$SYNCDIR" ]; then
                msg " $(gettext "The directory \'"$SYNCDIR"\' does not exist.\n Exiting.")" \
                dialog-warning & exit 1; fi
            [ ! -d "$DIR" ] && exit 1
    fi
    notify-send -i idiomind "$(gettext "Synchronizing...")" " "
    touch $DT/l_sync; SYNCDIR="$(sed -n 1p $DCP/5.cfg)"
    rsync -az --delete --exclude="*.txt" --exclude="*.png" \
    --exclude="*.i" --ignore-errors $DM_tl/Feeds/cache/ "$SYNCDIR"

    exit=$?
    if [ $exit = 0 ] ; then
        log="$(cd "$SYNCDIR"; ls *.mp3 | wc -l)"
        notify-send -i idiomind "$(gettext "Complete synchronization")" "$log $(gettext "synchronized episodes(s)")" -t 8000
    else
        notify-send -i dialog-warning "$(gettext "Error while syncing")" " " -t 8000
    fi
    rm -f $DT/l_sync
fi

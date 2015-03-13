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


tmplchannel="<?xml version='1.0' encoding='UTF-8'?>
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
tmplitem1="<?xml version='1.0' encoding='UTF-8'?>
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
tmplitem2="<?xml version='1.0' encoding='UTF-8'?>
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


    mediatype () {

        if echo "${1}" | grep -o ".mp3"; then ex="mp3"; tp="aud"
        elif echo "${1}" | grep -o ".mp4"; then ex="mp4"; tp="vid"
        elif echo "${1}" | grep -o ".ogg"; then ex="ogg"; tp="aud"
        elif echo "${1}" | grep -o ".avi"; then ex="avi"; tp="vid"
        elif echo "${1}" | grep -o ".m4v"; then ex="m4v"; tp="vid"
        elif echo "${1}" | grep -o ".mov"; then ex="mov"; tp="vid"
        fi
    }
    
    feed="$2"
    DCP="$DM_tl/Feeds/.conf"

    fchannel() {
        
        channel="$(xsltproc - "$feed" <<< "$tmplchannel" 2> /dev/null)"
        channel="$(echo "$channel" | tr '\n' ' ' \
        | tr -s '[:space:]' | sed 's/EOL/\n/g' | head -n 1)"
        fields="$(echo "$channel" | sed -r 's|-\!-|\n|g')"
        n=1;
        while read -r find; do
            if ([ $(wc -w <<< "${find}") -ge 1 ] && [ -z "$name" ]); then
                name="$n"
                n=2; fi
            if ([ -n "$(grep 'http:/' <<< "${find}")" ] && [ -z "$link" ]); then
                link="$n"
                n=3; fi
            if ([ -n "$(grep -E '.jpeg|.jpg|.png' <<< "${find}")" ] && [ -z "$logo" ]); then
                logo="$n"; fi
            let n++
        done <<< "$fields"

        echo
        echo "[channel]    name: $name ____ link: $link ____ logo: $logo"
        echo
    }
   

    ftype1() {
        items="$(xsltproc - "$feed" <<< "$tmplitem1" 2> /dev/null)"
        items="$(echo "$items" | tr '\n' ' ' | tr -s [:space:] | sed 's/EOL/\n/g' | head -n 2)"
        item="$(echo "$items" | sed -n 1p)"
        if [ -z "$(echo $item | sed 's/^ *//; s/ *$//; /^$/d')" ]; then
        msg "$(gettext "Couldn't download the specified URL\n")" info
        rm -f "$DT/cpt.lock" & exit 1
        fi
        items="$(echo "$item" | sed -r 's|-\!-|\n|g')"
        n=1; 
        while read -r find; do
            if ([ -n "$(grep -E '.mp3|.mp4|.ogg|.avi|.m4v|.mov|.flv' <<< "${find}")" ] && [ -z "$media" ]); then
                media="$n"; type=1
                n=2; fi
            if ([ $(wc -w <<< "${find}") -ge 1 ] && [ -z "$title" ]); then
                title="$n"
                n=4; fi
            if ([ $(wc -w <<< "${find}") -ge 1 ] && [ -z "$summ" ]); then
                summ="$n"; fi
            let n++
        done <<< "$items"
        
        echo
        echo "[1]    media: $media ____ title: $title ____ summ: $summ"
        echo
    }
    
    
    ftype2() {
        items="$(xsltproc - "$feed" <<< "$tmplitem2" 2> /dev/null)"
        items="$(echo "$items" | tr '\n' ' ' | tr -s [:space:] | sed 's/EOL/\n/g' | head -n 2)"
        item="$(echo "$items" | sed -n 1p)"

        n=1;
        while read -r find; do
            if ([ -n "$(grep -E '.jpg|.jpeg|.png' <<< "${find}")" ] && [ -z "$image" ]); then
                image="$n"; type=2
                n=2; fi
            if ([ $(wc -w <<< "${find}") -ge 1 ] && [ -z "$title" ]); then
                title="$n"
                n=4; fi
            if ([ $(wc -w <<< "${find}") -ge 1 ] && [ -z "$summ" ]); then
                summ="$n"; fi
            let n++
        done <<< "$items"

        echo
        echo "[2] $c    image: $image ____ title: $title ____ summ: $summ"
        echo

        if [ -z $image ]; then
        
            n=1
            while read -r find; do
                if ([ -n "$(grep -E '.jpg|.jpeg|.png' <<< "${find}")" ] && [ -z "$image" ]); then
                    type=2
                    image="$n"; break; fi
                if ([ -n "$(grep -o 'media:thumbnail url="[^"]*' | grep -o '[^"]*$')" <<< "${find}" ] && [ -z "$image" ]); then
                    image="$n"; break; fi
                    type=2
                if ([ -n "$(grep -o 'img src="[^"]*' | grep -o '[^"]*$')" <<< "${find}" ] && [ -z "$image" ]); then
                    type=2
                    image="$n"; break; fi
                let n++
            done <<< "$items"
        fi
        
        echo
        echo "[3] $c   image: $image ____ summ: $summ"
        echo
    }
    


    fchannel
    ftype1
    if [ -z "$type" ]; then
        ftype2
    fi
    

    if [ -z $summ ]; then
        n=1
        while read -r find; do
            if [ $(wc -w <<< "${find}") -ge 1 ]; then
                summ="$n"; break; fi
            let n++
        done <<< "$items"
    fi
    
    
    if [ -z "$logo" ]; then
        enclosure_url=$(curl -s -I -L -w %"{url_effective}" \
        --url "$enclosure" | tail -n 1)
        mediatype "$enclosure_url"
        cd "$DT_r"; wget -q -c -T 30 -O "media.$ex" "$enclosure_url"
        eyeD3 --write-images="$DT_r" "media.$ex"
        if ls | grep -E '.jpeg|.jpg|.png'; then
            logo="5"; fi
        rm -f "$DT"/*jpeg "$DT"/*jpg "$DT"/*png
        logo=3
    fi
    
    
    if [[ -n "$title" && -n "$summ" && -z "$image" && -z "$media" ]]; then
        type=3
    fi
    
    if [ -n "$type" ]; then
        echo "$feed|$type|$name|$link|$logo|$title|$media|$image|$summ" >> "$DCP/15.cfg"
        exit 0
    else
        exit 1
    fi
    






echo "$sumlink" | grep -o 'img src="[^"]*' | grep -o '[^"]*$' | sed -n 1p




















elif [ "$1" = check ]; then

    source $DS/ifs/mods/cmns.sh
    DCP="$DM_tl/Feeds/.conf"
    DSP="$DS_a/Feeds"
    [[ -e "$DT/cpt.lock" ]] && exit || touch "$DT/cpt.lock"

    internet

    tpl="$(gettext "Enclosure audio/video")\n _______\n$(gettext "Episode title")\n _______\n$(gettext "Summary/Description")\n _______\n _______\n _______"
    mn=" _______!$(gettext "Enclosure audio/video")!$(gettext "Episode title")!$(gettext "Summary/Description")"

    lnk=$(sed -n "$2"p $DCP/4.cfg)
    [ -z "$lnk" ] && exit 1
    [ ! -f "$DCP/$2.rss" ] && printf "$tpl" > "$DCP/$2.rss"
    cp "$DCP/$2.rss" "$DCP/$2.rss_"
    podcast_items="$(xsltproc - "$lnk" <<< "$tmplitem1" 2> /dev/null)"
    podcast_items="$(echo "$podcast_items" | tr '\n' ' ' | tr -s [:space:] | sed 's/EOL/\n/g' | head -n 2)"
    item="$(echo "$podcast_items" | sed -n 1p)"
    if [ -z "$(echo $item | sed 's/^ *//; s/ *$//; /^$/d')" ]; then
    msg "$(gettext "Couldn't download the specified URL\n")" info
    rm -f "$DT/cpt.lock" & exit 1
    fi
    field="$(echo "$item" | sed -r 's|-\!-|\n|g')"

    yad --scroll --columns=2 --skip-taskbar --separator='\n' \
    --width=800 --height=600 --form --on-top --window-icon=idiomind \
    --text="<small> $(gettext "\tIn this table you can define fields according to their cache,  most of the time the default values is right. ")</small>" \
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
    --print-all --button="gtk-apply":0 \
    --width=460 --height=200 --field="":CDIR "$SYNCDIR")"

    echo "$DIR" > $DT/s.tmp
    mv -f $DT/s.tmp $DCP/5.cfg
    exit


elif [ "$1" = syncronize ]; then
   
    DCP="$DM_tl/Feeds/.conf"
    SYNCDIR="$(sed -n 1p $DCP/5.cfg)"

    if [ ! -d "$SYNCDIR" ]; then
            cd $HOME
            DIR="$(yad --center --form --on-top --window-icon=idiomind \
            --borders=10 --separator="" --title=" " --always-print-result \
            --text="$(gettext "Set mountpoint or path where new episodes should be synced.")" \
            --print-all --button="$(gettext "OK")":0 \
            --width=460 --height=170 --field="":CDIR "$SYNCDIR")"
            echo "$DIR" > $DT/s.tmp
            mv -f $DT/s.tmp $DCP/5.cfg
            if [ ! -d "$SYNCDIR" ]; then
                msg "$(gettext "Failed: No directory\n ")" \
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
        notify-send -i idiomind "$(gettext "Synchronization was completed")" "$log $(gettext "synchronized episodes(s)")" -t 8000
    else
        notify-send -i dialog-warning "$(gettext "Error while syncing")" " " -t 8000
    fi
    rm -f $DT/l_sync
fi

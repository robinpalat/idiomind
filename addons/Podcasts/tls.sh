#!/bin/bash

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/mods/cmns.sh

if [ "$1" = play ]; then

    if [ -f "$DM_tl/Podcasts/content/$2.mp3" ]; then
        drtx="$DM_tl/Podcasts/content"
    elif [ -f "$DM_tl/Podcasts/kept/$2.mp3" ]; then
        drtx="$DM_tl/Podcasts/kept"
    fi
    
    killall play
    play "$drtx/$2.mp3" && exit
    
elif [ "$1" = dclk ]; then

    audio="$DM_tl/Podcasts/kept/.audio"
    contn="$DM_tl/Podcasts/content"
    echo "$3" > $DT/word.x
    var="$2"
    if [ -f "$audio/${3,,}.mp3" ]; then 
        play "$audio/${3,,}.mp3"
    else
        play "$contn/$var/${3,,}.mp3"
    fi

elif [ "$1" = check ]; then

    source $DS/ifs/mods/cmns.sh
    DCF="$DC/addons/Podcasts"
    DSF="$DS/addons/Podcasts"

    internet
    XSLT_STYLESHEET="<?xml version='1.0' encoding='UTF-8'?>
    <xsl:stylesheet version='1.0'
      xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
      xmlns:itunes='http://www.itunes.com/dtds/podcast-1.0.dtd'
      xmlns:media='http://search.yahoo.com/mrss/'
      xmlns:atom='http://www.w3.org/2005/Atom'>
      <xsl:output method='text'/>
      <xsl:template match='/'>
        <xsl:for-each select='/rss/channel/item'>
          <xsl:value-of select='enclosure/@url'/><xsl:text>|</xsl:text>
          <xsl:value-of select='media:contentt[@type=\"audio/mpeg\"]/@url'/><xsl:text>|</xsl:text>
          <xsl:value-of select='title'/><xsl:text>|</xsl:text>
          <xsl:value-of select='pubDate'/><xsl:text>|</xsl:text>
          <xsl:value-of select='itunes:duration'/><xsl:text>|</xsl:text>
          <xsl:value-of select='media:contentt[@type=\"audio/mpeg\"]/@duration'/><xsl:text>|</xsl:text>
          <xsl:value-of select='itunes:summary'/><xsl:text>|</xsl:text>
          <xsl:value-of select='description'/><xsl:text>EOL</xsl:text>
        </xsl:for-each>
      </xsl:template>
    </xsl:stylesheet>"

    tpl="Enclosure\n ----\nTitle\n ----\n ----\n ----\nSummary\n ----"
    o=" ----!Title!Enclosure!Summary"
    
    lnk=$(sed -n "$2"p $DCF/$lgtl/link)
    [ -z "$lnk" ] && exit 1
    
    [ ! -f "$DCF/$lgtl/$2.xml" ] && printf "$tpl" > "$DCF/$lgtl/$2.xml"
    
    PODCAST_ITEMS="$(xsltproc - "$lnk" <<< "$XSLT_STYLESHEET" 2> /dev/null)"
    PODCAST_ITEMS="$(echo "$PODCAST_ITEMS" | tr '\n' ' ' | tr -s [:space:] | sed 's/EOL/\n/g' | head -n 2)"
    ITEM="$(echo "$PODCAST_ITEMS" | sed -n 1p)"
    
    [ -z "$(echo $ITEM | sed 's/^ *//; s/ *$//; /^$/d')" ] && msg "$(gettext "Couldn't download the specified URL\n")" info && exit 1

    field="$(echo "$ITEM" | tr -s '||' '\n')"

    yad --scroll --columns=2 --skip-taskbar --separator='\n' \
    --width=800 --height=650 --form --on-top --window-icon=idiomind \
    --text="<small> $(gettext " In this table you can define fields according to their content ")</small>" \
    --button=gtk-apply:0 --borders=5 --title="$ttl" --always-print-result \
    --field="":CB "$(sed -n 1p $DCF/$lgtl/$2.xml)!$o" \
    --field="":CB "$(sed -n 2p $DCF/$lgtl/$2.xml)!$o" \
    --field="":CB "$(sed -n 3p $DCF/$lgtl/$2.xml)!$o" \
    --field="":CB "$(sed -n 4p $DCF/$lgtl/$2.xml)!$o" \
    --field="":CB "$(sed -n 5p $DCF/$lgtl/$2.xml)!$o" \
    --field="":CB "$(sed -n 6p $DCF/$lgtl/$2.xml)!$o" \
    --field="":CB "$(sed -n 7p $DCF/$lgtl/$2.xml)!$o" \
    --field="":TXT "$(echo "$field" | sed -n 1p)" \
    --field="":TXT "$(echo "$field" | sed -n 2p)" \
    --field="":TXT "$(echo "$field" | sed -n 3p | sed 's/\://g')" \
    --field="":TXT "$(echo "$field" | sed -n 4p | sed 's/\://g')" \
    --field="":TXT "$(echo "$field" | sed -n 5p)" \
    --field="\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t":TXT "$(echo "$field" | sed -n 6p)" \
    --field="":TXT "$(echo "$field" | sed -n 7p)" | head -n 7 > $DT/f.tmp
    mv -f $DT/f.tmp "$DCF/$lgtl/$2.xml" & exit


elif [ "$1" = syncronize ]; then

    DCF="$DC/addons/Podcasts"
    SYNCDIR="$(sed -n 1p $DCF/cfg.5)"

    if [ ! -d "$SYNCDIR" ]; then
            cd $HOME
            DIR="$(yad --center --form --on-top --window-icon=idiomind \
            --borders=15 --separator="" --title=" " --always-print-result \
            --text="$(gettext "Set mountpoint or path where new episodes should be synced.")" \
            --print-all --button="$(gettext "Syncronize")":0 \
            --width=420 --height=200 --field="":CDIR "$SYNCDIR")"
            echo "$DIR" > $DT/s.tmp
            mv -f $DT/s.tmp $DCF/cfg.5

            [ ! -d "$DIR" ] && exit 1
    fi

    #notify-send -i idiomind "$(gettext "Syncing")" "$(gettext " ")" -t 3000
    touch $DT/l_sync
    rsync -az --delete --ignore-errors "$DM_tl/Podcasts/content" "$SYNCDIR"

    exit=$?
    if [ $exit = 0 ] ; then
        log="$(cd "$DM_tl/Podcasts/content"; ls *.mp3 | wc -l)"
        notify-send -i idiomind "$(gettext "synchronization was completed")" "$log $(gettext "synchronized episodes(s)")" -t 3000
    else
        notify-send -i dialog-warning "$(gettext "Error while syncing")" " " -t 3000
    fi
    rm -f $DT/l_sync
fi

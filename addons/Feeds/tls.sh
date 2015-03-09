#!/bin/bash

source /usr/share/idiomind/ifs/c.conf
source "$DS/ifs/mods/cmns.sh"

#tmplitem="<?xml version='1.0' encoding='UTF-8'?>
#<xsl:stylesheet version='1.0'
  #xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
  #xmlns:itunes='http://www.itunes.com/dtds/feed-1.0.dtd'
  #xmlns:media='http://search.yahoo.com/mrss/'
  #xmlns:atom='http://www.w3.org/2005/Atom'>
  #<xsl:output method='text'/>
  #<xsl:template match='/'>
    #<xsl:for-each select='/rss/channel/item'>
      #<xsl:value-of select='enclosure/@url'/><xsl:text>-!-</xsl:text>
      #<xsl:value-of select='media:cache[@type=\"audio/mpeg\"]/@url'/><xsl:text>-!-</xsl:text>
      #<xsl:value-of select='title'/><xsl:text>-!-</xsl:text>
      #<xsl:value-of select='media:cache[@type=\"audio/mpeg\"]/@duration'/><xsl:text>-!-</xsl:text>
      #<xsl:value-of select='itunes:summary'/><xsl:text>-!-</xsl:text>
      #<xsl:value-of select='description'/><xsl:text>EOL</xsl:text>
    #</xsl:for-each>
  #</xsl:template>
#</xsl:stylesheet>"


tmplitem="<?xml version='1.0' encoding='UTF-8'?>
<xsl:stylesheet version='1.0'
  xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
  xmlns:itunes='http://www.itunes.com/dtds/feed-1.0.dtd'
  xmlns:media='http://search.yahoo.com/mrss/'
  xmlns:atom='http://www.w3.org/2005/Atom'>
  <xsl:output method='text'/>
  <xsl:template match='/'>
    <xsl:for-each select='/rss/channel/item'>
      <xsl:value-of select='enclosure/@url'/><xsl:text>-!-</xsl:text>
      <xsl:value-of select='media:cache[@type=\"image/jpeg\"]/@url'/><xsl:text>-!-</xsl:text>
      <xsl:value-of select='title'/><xsl:text>-!-</xsl:text>
      <xsl:value-of select='media:cache[@type=\"image/jpeg\"]/@duration'/><xsl:text>-!-</xsl:text>
      <xsl:value-of select='itunes:summary'/><xsl:text>-!-</xsl:text>
      <xsl:value-of select='description'/><xsl:text>EOL</xsl:text>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>"


if [ "$1" = play ]; then
    
    killall play
    DCF="$DM_tl/Feeds/.conf"
    [ -f "$DCF/0.cfg" ] && st3=$(sed -n 2p "$DCF/0.cfg") || st3=FALSE
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
    
elif [ "$1" = check ]; then

    source $DS/ifs/mods/cmns.sh
    DCF="$DM_tl/Feeds/.conf"
    DSF="$DS/addons/Feeds"
    [[ -e "$DT/cft.lock" ]] && exit || touch "$DT/cft.lock"

    internet

    tpl="$(gettext "Image")\n - - -\n$(gettext "Title")\n - - -\n$(gettext "Summary")\n - - -\n - - -\n - - -"
    mn=" - - -!$(gettext "Image")!$(gettext "Title")!$(gettext "Summary")"

    lnk=$(sed -n "$2"p $DCF/4.cfg)
    [ -z "$lnk" ] && exit 1
    [ ! -f "$DCF/$2.xml" ] && printf "$tpl" > "$DCF/$2.xml"
    cp "$DCF/$2.xml" "$DCF/$2.xml_"
    feed_items="$(xsltproc - "$lnk" <<< "$tmplitem" 2> /dev/null)"
    feed_items="$(echo "$feed_items" | tr '\n' ' ' | tr -s [:space:] | sed 's/EOL/\n/g' | head -n 2)"
    item="$(echo "$feed_items" | sed -n 1p)"
    if [ -z "$(echo $item | sed 's/^ *//; s/ *$//; /^$/d')" ]; then
    msg "$(gettext "Couldn't download the specified URL\n")" info
    rm -f "$DT/cft.lock" & exit 1
    fi
    field="$(echo "$item" | sed -r 's|-\!-|\n|g')"

    yad --scroll --columns=2 --skip-taskbar --separator='\n' \
    --width=800 --height=600 --form --on-top --window-icon=idiomind \
    --text="<small> $(gettext "\tIn this table you can define fields according to their cache,  most of the time the default values is right. ")</small>" \
    --button=gtk-apply:0 --borders=5 --title="$ttl" --always-print-result \
    --field="":CB "$(sed -n 1p $DCF/$2.xml)!$mn" \
    --field="":CB "$(sed -n 2p $DCF/$2.xml)!$mn" \
    --field="":CB "$(sed -n 3p $DCF/$2.xml)!$mn" \
    --field="":CB "$(sed -n 4p $DCF/$2.xml)!$mn" \
    --field="":CB "$(sed -n 5p $DCF/$2.xml)!$mn" \
    --field="":CB "$(sed -n 6p $DCF/$2.xml)!$mn" \
    --field="":CB "$(sed -n 7p $DCF/$2.xml)!$mn" \
    --field="":TXT "$(echo "$field" | sed -n 1p)" \
    --field="":TXT "$(echo "$field" | sed -n 2p)" \
    --field="":TXT "$(echo "$field" | sed -n 3p | sed 's/\://g')" \
    --field="":TXT "$(echo "$field" | sed -n 4p | sed 's/\://g')" \
    --field="":TXT "$(echo "$field" | sed -n 5p)" \
    --field="\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t":TXT "$(echo "$field" | sed -n 6p)" \
    --field="":TXT "$(echo "$field" | sed -n 7p)" | head -n 7 > $DT/f.tmp
    [[ -n "$(cat "$DT/f.tmp")" ]] && mv -f $DT/f.tmp "$DCF/$2.xml" || cp -f "$DCF/$2.xml_" "$DCF/$2.xml"
    [[ -f "$DCF/$2.xml_" ]] && rm "$DCF/$2.xml_"
    [[ -e "$DT/cft.lock" ]] && rm -f "$DT/cft.lock" & exit

fi

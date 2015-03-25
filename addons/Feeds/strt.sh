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
source "$DS/ifs/mods/cmns.sh"
include "$DS/ifs/mods/add"
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
</xsl:for-each>
</xsl:template>
</xsl:stylesheet>"
tmplitem="<?xml version='1.0' encoding='UTF-8'?>
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
tpc_sh='#!/bin/bash
source /usr/share/idiomind/ifs/c.conf
[ ! -f "$DM_tl/Feeds/.conf/8.cfg" ] \
&& echo "11" > "$DM_tl/Feeds/.conf/8.cfg"
echo "$tpc" > "$DC_s/4.cfg"
echo fd >> "$DC_s/4.cfg"
idiomind topic
exit 1'
DSP="$DS/addons/Feeds"
DMC="$DM_tl/Feeds/cache"
DCP="$DM_tl/Feeds/.conf"
DT_r=$(mktemp -d $DT/XXXX)
rssf="$DCP/4.cfg"
cp -f "$rssf" "$DT_r/rss_list"


function conditions() {
    
    [ ! -f "$DCP/1.cfg" ] && touch "$DCP/1.cfg"
    
    
    if ([ -f "$DT/.uptp" ] && [ -z "$1" ]); then
        msg_2 "$(gettext "Wait till it finishes a previous process")\n" info OK gtk-stop
        ret=$(echo $?)
        [ $ret -eq 1 ] && "$DS/stop.sh" feed
        [ $ret -eq 0 ] && exit 1
    
    elif [[ -f "$DT/.uptp" && "$1" = A ]]; then
        exit 1
    fi
    
    if [ ! -d "$DM_tl/Feeds/cache" ]; then
        mkdir -p "DM_tl/Feeds/.conf"
        mkdir -p "DM_tl/Feeds/cache"
    fi
    
    if ([ ! -f "$DM_tl/Feeds/tpc.sh" ] || \
    [ "$(wc -l < "$DM_tl/Feeds/tpc.sh")" -ge 15 ]); then
        echo "$tpc_sh" > "$DM_tl/Feeds/tpc.sh"
        chmod +x "$DM_tl/Feeds/tpc.sh"
        echo "14" > "$DM_tl/Feeds/.conf/8.cfg"
        cd "$DM_tl/Feeds/.conf/"
        touch 0.cfg 1.cfg 3.cfg 4.cfg .updt.lst
        "$DS/mngr.sh" mkmn
    fi
    
    n=1; DCP="$DM_tl/Feeds/.conf"
    while [ $n -le "$(wc -l < "$rssf")" ]; do
        if ([ -n "$(grep -v   " _______" < "$DCP/$n.rss" | uniq -dc)" ] \
        || [ $(wc -l < "$DCP/$n.rss") != 7 ] \
        || [ ! -f "$DCP/$n.rss" ]); then
                echo "$n" > $DT/dupl.cnf
                msg "$(gettext "Se encontró un error (01) en la configuración de un feed") ($n)\n " dialog-warning
                [ -f "$DT/.uptp" ] && rm -fr "$DT_r" "$DT/.uptp"
            exit 1
        fi
        let n++
    done
    
    nps="$(wc -l < "$rssf")"
    if [ "$nps" -le 0 ]; then
        msg "$(gettext "Missing URL. Please check the settings in the preferences dialog.")\n" info
        [ -f "$DT/.uptp" ] && rm -fr "$DT_r" "$DT/.uptp"
        exit 1; fi
    internet
}

mediatype () {

    if echo "${1}" | grep -q ".mp3"; then ex=mp3; tp=aud
    elif echo "${1}" | grep -q ".mp4"; then ex=mp4; tp=vid
    elif echo "${1}" | grep -q ".ogg"; then ex=ogg; tp=aud
    elif echo "${1}" | grep -q ".avi"; then ex=avi; tp=vid
    elif echo "${1}" | grep -q ".m4v"; then ex=m4v; tp=vid
    elif echo "${1}" | grep -q ".mov"; then ex=mov; tp=vid
    else
        msg "$(gettext "Se encontró un error (02) en la configuración de un feed") ($n)\n " dialog-warning;
        continue; fi
}

get_images () {
    
    cd "$DT_r"; p=TRUE; rm -f *.jpeg *.jpg
    
    if [ "$tp" = aud ]; then
        
        eyeD3 --write-images="$DT_r" "media.$ex"
        
        if ls | grep '.jpeg'; then img="$(ls | grep '.jpeg')"
        else img="$(ls | grep '.jpg')"; fi
        
        if [ ! -f "$DT_r/$img" ]; then
        
            wget -q -O- "$FEED" | grep -o '<itunes:image href="[^"]*' \
            | grep -o '[^"]*$' | xargs wget -c
            
            if ls | grep '.jpeg'; then img="$(ls | grep '.jpeg')"
            elif ls | grep '.png'; then img="$(ls | grep '.png')"
            else img="$(ls | grep '.jpg')"; fi
        fi
        
        if [ ! -f "$DT_r/$img" ]; then
        
            cp -f "$DSP/images/audio.png" "$DMC/$fname.png"
            p=""
        fi

    elif [ "$tp" = vid ]; then
        
        exec 3<&0; mplayer -ss 60 -nosound -noconsolecontrols -vo jpeg -frames 3 "media.$ex" <&3 &&

        if ls | grep '.jpeg'; then img="$(ls | grep '.jpeg' | head -n1)"
        else img="$(ls | grep '.jpg' | head -n1)"; fi
        
        if [ ! -f "$DT_r/$img" ]; then
            
            cp -f "$DSP/images/video.png" "$DMC/$fname.png"
            p=""
        fi
    fi
    
    if [ "$p" = TRUE ] && [ -f "$DT_r/$img" ]; then
        
        convert "$DT_r/$img" -interlace Plane -thumbnail 52x44^ \
        -gravity center -extent 52x44 -quality 100% tmp.jpg
        convert tmp.jpg -bordercolor white \
        -border 2 \( +clone -background black \
        -shadow 60x3+2+2 \) +swap -background transparent \
        -layers merge +repage "$DMC/$fname.png"
        rm -f *.jpeg *.jpg
    fi
}

fetch_podcasts() {

    n=1
    while read FEED; do
        
        if [ -z "$FEED" ]; then
            break; msg "$(gettext "Se encontró un error (03) en la configuración de un feed") ($n)\n " dialog-warning &
            [ -f "$DT/.uptp" ] && rm -fr "$DT_r" "$DT/.uptp"
            exit 1; fi
        
        channel_info="$(xsltproc - "$FEED" <<< "$tmplchannel" 2> /dev/null)"
        channel_info="$(echo "$channel_info" | tr '\n' ' ' \
        | tr -s '[:space:]' | sed 's/EOL/\n/g' | head -n 1)"
        field="$(echo "$channel_info" | sed -r 's|-\!-|\n|g' \
        | iconv -c -f utf8 -t ascii \
        | sed 's/\://g' | sed 's/\&/&amp;/g')"
        channel=$(echo "$field" | sed -n 1p)
        link=$(echo "$field" | sed -n 2p)
        podcast_items="$(xsltproc - "$FEED" <<< "$tmplitem" 2> /dev/null)"
        podcast_items="$(echo "$podcast_items" | tr '\n' ' ' \
        | tr -s '[:space:]' | sed 's/EOL/\n/g' | head -n "$nps")"
        podcast_items="$(echo "$podcast_items" | sed '/^$/d')"
        n_enc=$(grep -Fxon "$(gettext "Enclosure audio/video")" < "$DCP/$n.rss" \
        | sed -n 's/^\([0-9]*\)[:].*/\1/p')
        n_tit=$(grep -Fxon "$(gettext "Episode title")" < "$DCP/$n.rss" \
        | sed -n 's/^\([0-9]*\)[:].*/\1/p')
        n_sum=$(grep -Fxon "$(gettext "Summary/Description")" < "$DCP/$n.rss" \
        | sed -n 's/^\([0-9]*\)[:].*/\1/p')
        
        while read -r item; do

            fields="$(echo "$item" | sed -r 's|-\!-|\n|g')"
            enclosure=$(echo "$fields" | sed -n "$n_enc"p)
            
            if [ -z "$enclosure" ]; then continue; fi
            
            title=$(echo "$fields" | sed -n "$n_tit"p \
            | iconv -c -f utf8 -t ascii | sed 's/\://g' \
            | sed 's/\&/&amp;/g' | sed 's/^\s*./\U&\E/g' \
            | sed 's/<[^>]*>//g' | sed 's/^ *//; s/ *$//; /^$/d')
            #sumlink=$(echo "$fields" | sed -n "$n_sum"p)
            summary=$(echo "$fields" | sed -n "$n_sum"p \
            | iconv -c -f utf8 -t ascii \
            | sed 's/\&quot;/\"/g' | sed "s/\&#039;/\'/g" \
            | sed '/</ {:k s/<[^>]*>//g; /</ {N; bk}}' \
            | sed 's/<!\[CDATA\[\|\]\]>//g' \
            | sed 's/ *<[^>]\+> */ /g' \
            | sed 's/[<>£§]//g' \
            | sed 's/&amp;/\&/g' \
            | sed 's/\(\. [A-Z][^ ]\)/\.\n\1/g' | sed 's/\. //g' \
            | sed 's/\(\? [A-Z][^ ]\)/\?\n\1/g' | sed 's/\? //g' \
            | sed 's/\(\! [A-Z][^ ]\)/\!\n\1/g' | sed 's/\! //g' \
            | sed 's/\(\… [A-Z][^ ]\)/\…\n\1/g' | sed 's/\… //g')
            fname="$(nmfile "${title}")"
            
            if ([ "$(echo "$title" | wc -c)" -ge 180 ] \
            || [ -z "$title" ]); then
                    msg "$(gettext "Se encontró un error (04) en la configuración de un feed") ($n)\n $title" info;
                    continue; fi
                 
            if ! grep -Fxo "$title" < "$DCP/1.cfg"; then
            
                enclosure_url=$(curl -s -I -L -w %"{url_effective}" \
                --url "$enclosure" | tail -n 1)
                
                mediatype "$enclosure_url"
                
                if [ ! -f "$DMC/$fname.$ex" ]; then
                cd "$DT_r"; wget -q -c -T 30 -O "media.$ex" "$enclosure_url"
                else
                cd "$DT_r"; mv -f "$DMC/$fname.$ex" "media.$ex"
                fi
                
                if [ -z "$channel" ]; then
                    channel="$(eyeD3 --no-color "media.$ex" \
                    | grep -o -P '(?<=title:).*(?=artist:)' \
                    | sed -e 's/^[ \t]*//g' | tr -s '\ \t' \
                    | sed -e "s/[[:space:]]\+/ /g" | sed 's/\&/&amp;/g' \
                    | sed 's/^ *//; s/ *$//; /^$/d' | tr -s ':')"
                fi
                
                get_images
                wait
                
                mv -f "media.$ex" "$DMC/$fname.$ex"
                printf "\n$summary" > "$DMC/$fname.txt"
                echo -e "channel=\"$channel\"" > "$DMC/$fname.i"
                echo -e "link=\"$link\"" >> "$DMC/$fname.i"
                echo -e "title=\"$title\"" >> "$DMC/$fname.i"
                if [ -s "$DCP/1.cfg" ]; then
                sed -i -e "1i$title\\" "$DCP/1.cfg"
                else
                echo "$title" > "$DCP/1.cfg"; fi
                if grep '^$' "$DCP/1.cfg"; then
                sed -i '/^$/d' "$DCP/1.cfg"; fi
                echo "$title" >> "$DCP/.11.cfg"
                echo "$title" >> "$DT_r/log"
            fi

        done <<<"$podcast_items"

        let n++
    
    done < "$DT_r/rss_list"
}

remove_items() {
    
    n=50
    while [[ $n -le "$(wc -l < "$DCP/1.cfg")" ]]; do
        item="$(sed -n "$n"p "$DCP/1.cfg")"
        if ! grep -Fxo "$title" < "$DCP/2.cfg"; then
            fname="$(nmfile "${item}")"
            [ -f "$DMC/$fname.mp4" ] && rm "$DMC/$fname.mp4"
            [ -f "$DMC/$fname.ogg" ] && rm "$DMC/$fname.ogg"
            [ -f "$DMC/$fname.avi" ] && rm "$DMC/$fname.avi"
            [ -f "$DMC/$fname.m4v" ] && rm "$DMC/$fname.m4v"
            [ -f "$DMC/$fname.flv" ] && rm "$DMC/$fname.flv"
            [ -f "$DMC/$fname.mov" ] && rm "$DMC/$fname.mov"
            [ -f "$DMC/$fname.png" ] && rm "$DMC/$fname.png"
            [ -f "$DMC/$fname.txt" ] && rm "$DMC/$fname.txt"
            [ -f "$DMC/$fname.i" ] && rm "$DMC/$fname.i"
        fi
        grep -vxF "$item" "$DCP/1.cfg" > "$DT/item.tmp"
        sed '/^$/d' "$DT/item.tmp" > "$DCP/1.cfg"
        let n++
    done
}

check_index() {
    
    check_index1 "$DCP/1.cfg"
    if grep '^$' "$DCP/1.cfg"; then
    sed -i '/^$/d' "$DCP/1.cfg"; fi
    cp -f "$DCP/1.cfg" "$DCP/.11.cfg"
    
    df_img="$DSP/images/item.png"
    while read item; do
        fname="$(nmfile "${item}")"
        if ([ -f "$DMC/$fname.mp3" ] || [ -f "$DMC/$fname.mp4" ] || \
        [ -f "$DMC/$fname.ogg" ] || [ -f "$DMC/$fname.avi" ] || \
        [ -f "$DMC/$fname.m4v" ] || [ -f "$DMC/$fname.flv" ]); then
            echo ok
        else
            echo "$item" >> "$DT/cchk"; fi
        if [ ! -f "$DMC/$fname.png" ]; then
            cp "$df_img" "$DMC/$fname.png"
        fi
    done < "$DCP/1.cfg"
    
    if [ -f "$DT/cchk" ]; then
        while read item; do
            grep -vxF "$item" "$DCP/.11.cfg" > "$DCP/.11.cfg.tmp"
            sed '/^$/d' "$DCP/.11.cfg.tmp" > "$DCP/.11.cfg"
            grep -vxF "$item" "$DCP/1.cfg" > "$DCP/1.cfg.tmp"
            sed '/^$/d' "$DCP/1.cfg.tmp" > "$DCP/1.cfg"
        done < "$DT/cchk"
        [ -f "$DCP/*.tmp" ] && rm "$DCP/*.tmp"
    fi
}

conditions

if [ "$1" != A ]; then
    echo "$tpc" > "$DC_s/4.cfg"
    echo fd >> "$DC_s/4.cfg"
    echo "11" > "$DCP/8.cfg"
    (sleep 2 && notify-send -i idiomind "$(gettext "Checking for new downloads")" "$(gettext "Updating") $nps $(gettext "feeds...")" -t 6000) &
fi

echo "updating" > "$DT/.uptp"
nps=5
fetch_podcasts

[ -f "$DT_r/log" ] && nd="$(wc -l < "$DT_r/log")" || nd=0
rm -fr "$DT_r" "$DT/.uptp"

if [ "$nd" -gt 0 ]; then
    remove_items
    #check_index
    echo "$(date "+%a %d %B")" > "$DM_tl/Feeds/.dt"
    [ "$1" != A ] && notify-send -i idiomind \
    "$(gettext "Update finished")" "$(gettext "Downloaded") $nd $(gettext "episode(s)")" -t 8000
    exit 0
else
    if [[ ! -n "$1" && "$1" != A ]]; then
        notify-send -i idiomind \
        "$(gettext "No new episodes")" "$(gettext "Downloaded") $nd $(gettext "episode(s)")" -t 8000
    fi
    exit 0
fi

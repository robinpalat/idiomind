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
tmplitem2="<?xml version='1.0' encoding='UTF-8'?>
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


conditions() {
    
    [ ! -f "$DCP/1.cfg" ] && touch "$DCP/1.cfg"
    
    if [ -f "$DT/.uptp" ] && [ -z "$1" ]; then
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

        if [ -n "$(sed -n "$n"p "$rssf")" ]; then
        
            source "$DCP/$n.rss"
            if ([ -z "$channel" ] && [ -z "$ntype" ] && [ -z "$ntitle" ]) \
            && ([ -z "$nmedia" ] || [ -z "$nimage" ]); then
                echo "$n" > $DT/dupl.cnf
                msg " $(gettext "Something wrong on feeds configuration")\n $(gettext "Error")1  $(gettext "URL")$n" dialog-warning
                [ -f "$DT/.uptp" ] && rm -fr "$DT_r" "$DT/.uptp"
            exit 1
            fi
        fi
        let n++
    done
    
    nps="$(wc -l < "$rssf" | sed '/^\s*$/d')"
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
    elif echo "${1}" | grep -o ".jpg"; then ex=jpg; tp=txt
    elif echo "${1}" | grep -o ".jpeg"; then ex=jpeg; tp=txt
    elif echo "${1}" | grep -o ".png"; then ex=png; tp=txt
    else
        msg " $(gettext "Something wrong on feeds configuration")\n $(gettext "Error")2  $(gettext "URL")$n" dialog-warning;
        continue; fi
}

get_images_main () {
    
    cd "$DT_r"
    
    echo "$sumlink" | grep -o 'img src="[^"]*' | grep -o '[^"]*$' | sed -n 1p

    #if ls | grep '.jpeg'; then img="$(ls | grep '.jpeg')"
    #elif ls | grep '.png'; then img="$(ls | grep '.png')"
    #elif ls | grep '.jpg'; then img="$(ls | grep '.jpg')"
    #fi
        
    #if [ -f "$DT_r/$img" ]; then
    
        #img="$DT_r/$img"
}

mkhtml () {

    if [ "$tp" = vid ]; then
    
        if [ $ex = m4v || $ex = mp4 ]; then
        t = mp4
        elif [ $ex = avi ]; then
        t = avi; fi
        
printf "<link rel=\"stylesheet\" href=\"/usr/share/idiomind/default/vwrstyle.css\">
<video width=650 height=380 controls>
<source src=\"$fname.$ex\" type=\"video/mp4\">
Your browser does not support the video tag.
</video><br><br>
<div class=\"title\"><h3>$title</h3></div>
<br>
<div class=\"summary\">$summary<br><br></div>
" > "$DMC/$fname.html"

    elif [ "$tp" = aud ]; then
printf "<link rel=\"stylesheet\" href=\"/usr/share/idiomind/default/vwrstyle.css\">
<br><div class=\"title\"><h2>$title</h2></div><br>
<div class=\"summary\"><audio controls><br>
<source src=\"$fname.$ex\" type=\"audio/mpeg\">
Your browser does not support the audio tag.
</audio><br>
<br>
$summary<br><br></div>
" > "$DMC/$fname.html"

    elif [ "$tp" = txt ]; then
printf "<link rel=\"stylesheet\" href=\"/usr/share/idiomind/default/vwrstyle.css\">
<body>
<br><div class=\"title\"><h2>$title</h2></div><br>
<div class=\"summary\"><div class=\"image\">
<img src=\"$fname.jpg\" alt=\"Image\" style=\"width:650px\"></div>
<br>
$summary<br><br></div>
</body>
" > "$DMC/$fname.html"

    fi
}


get_images () {

    if [ "$tp" = aud ]; then
        
        cd "$DT_r"; p=TRUE; rm -f *.jpeg *.jpg
        
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
        
        cd "$DT_r"; p=TRUE; rm -f *.jpeg *.jpg
        
        exec 3<&0; mplayer -ss 60 -nosound -noconsolecontrols \
        -vo jpeg -frames 3 "media.$ex" <&3 &&

        if ls | grep '.jpeg'; then img="$(ls | grep '.jpeg' | head -n1)"
        else img="$(ls | grep '.jpg' | head -n1)"; fi
        
        if [ ! -f "$DT_r/$img" ]; then
            
            cp -f "$DSP/images/video.png" "$DMC/$fname.png"
            p=""
        fi
        
    elif [ "$tp" = txt ]; then
    
        cd "$DT_r"; p=TRUE
    
        img="media.$ex"
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
        
        if [ -n "$FEED" ]; then

            source "$DCP/$n.rss"
            if [ "$ntype" = 1 ]; then

                podcast_items="$(xsltproc - "$FEED" <<< "$tmplitem" 2> /dev/null)"
                podcast_items="$(echo "$podcast_items" | tr '\n' ' ' \
                | tr -s '[:space:]' | sed 's/EOL/\n/g' | head -n "$nps")"
                podcast_items="$(echo "$podcast_items" | sed '/^$/d')"
                
                while read -r item; do

                    fields="$(echo "$item" | sed -r 's|-\!-|\n|g')"
                    enclosure=$(echo "$fields" | sed -n "$nmedia"p)
                    
                    if [ -z "$enclosure" ]; then continue; fi
                    
                    title=$(echo "$fields" | sed -n "$ntitle"p | sed 's/\://g' \
                    | sed 's/\&/&amp;/g' | sed 's/^\s*./\U&\E/g' \
                    | sed 's/<[^>]*>//g' | sed 's/^ *//; s/ *$//; /^$/d')
                    summary=$(echo "$fields" | sed -n "$nsumm"p \
                    | iconv -c -f utf8 -t ascii)
                    fname="$(nmfile "${title}")"
                    
                    if [ "$(echo "$title" | wc -c)" -ge 180 ] || [ -z "$title" ]; then
                            msg " $(gettext "Something wrong on feeds configuration")\n $(gettext "Error")4  $(gettext "URL")$n" info;
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
                        mkhtml

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
                
            elif [ "$ntype" = 2 ]; then
            
                    feed_items="$(xsltproc - "$FEED" <<< "$tmplitem2" 2> /dev/null)"
                    feed_items="$(echo "$feed_items" | tr '\n' ' ' \
                    | tr -s '[:space:]' | sed 's/EOL/\n/g' | head -n "$nps")"
                    feed_items="$(echo "$feed_items" | sed '/^$/d')"
                    
                    while read -r item; do

                        fields="$(echo "$item" | sed -r 's|-\!-|\n|g')"
                        echo "$fields" > /home/robin/Desktop/file
                        enclosure=$(echo "$fields" | sed -n "$nimage"p)
                        title=$(echo "$fields" | sed -n "$ntitle"p \
                        | iconv -c -f utf8 -t ascii | sed 's/\://g' \
                        | sed 's/\&/&amp;/g' | sed 's/^\s*./\U&\E/g' \
                        | sed 's/<[^>]*>//g' | sed 's/^ *//; s/ *$//; /^$/d')
                        summary=$(echo "$fields" | sed -n "$nsumm"p)
                        [ -z "$summary" ] && summary=$(echo "$fields" | sed -n $((nsumm+1))p)
                        summary=$(echo "$summary" \
                        | iconv -c -f utf8 -t ascii \
                        | sed 's/\&quot;/\"/g' | sed "s/\&#039;/\'/g" \
                        | sed '/</ {:k s/<[^>]*>//g; /</ {N; bk}}' \
                        | sed 's/<!\[CDATA\[\|\]\]>//g' \
                        | sed 's/ *<[^>]\+> */ /g' \
                        | sed 's/[<>£§]//g' | sed 's/&amp;/\&/g' \
                        | sed 's/\(\. [A-Z][^ ]\)/\.\n\1/g' | sed 's/\. //g' \
                        | sed 's/\(\? [A-Z][^ ]\)/\?\n\1/g' | sed 's/\? //g' \
                        | sed 's/\(\! [A-Z][^ ]\)/\!\n\1/g' | sed 's/\! //g' \
                        | sed 's/\(\… [A-Z][^ ]\)/\…\n\1/g' | sed 's/\… //g')
                        fname="$(nmfile "${title}")"

                        if [ "$(echo "$title" | wc -c)" -ge 200 ]; then
                                msg " $(gettext "Something wrong on feeds configuration")\n $(gettext "Error")4  $(gettext "URL")$n" info;
                                continue; fi
                                
                        if ! grep -Fxo "$title" < "$DCP/1.cfg"; then
                        
                            if [ -n "$enclosure" ]; then
                                enclosure_url=$(curl -s -I -L -w %"{url_effective}" \
                                --url "$enclosure" | tail -n 1)
                            else
                                enclosure_url=$(curl -s -I -L -w %"{url_effective}" \
                                --url "$(get_images_main)" | tail -n 1)
                            fi
                            
                            mediatype "$enclosure_url"
                            rm -f 
                            cd "$DT_r"; rm -f *.jpg *.png *.jpeg
                            wget -q -c -T 30 -O "media.$ex" "$enclosure_url"
                            
                            /usr/bin/convert "media.$ex" "$DMC/$fname.jpg"
                            
                            get_images
                            
                            mkhtml

                            if [ -s "$DCP/1.cfg" ]; then
                            sed -i -e "1i$title\\" "$DCP/1.cfg"
                            else
                            echo "$title" > "$DCP/1.cfg"; fi
                            if grep '^$' "$DCP/1.cfg"; then
                            sed -i '/^$/d' "$DCP/1.cfg"; fi
                            echo "$title" >> "$DCP/.11.cfg"
                            echo "$title" >> "$DT_r/log"
                        fi

                    done <<< "$feed_items"
            fi
        fi
        
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
            [ -f "$DMC/$fname.jpg" ] && rm "$DMC/$fname.jpg"
            [ -f "$DMC/$fname.jpeg" ] && rm "$DMC/$fname.jpeg"
            [ -f "$DMC/$fname.html" ] && rm "$DMC/$fname.html"
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
        [ -f "$DMC/$fname.jpg" ] || \
        [ -f "$DMC/$fname.jpeg" ] || [ -f "$DMC/$fname.png" ] || \
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

conditions "$1"

if [ "$1" != A ]; then
    echo "$tpc" > "$DC_s/4.cfg"
    echo fd >> "$DC_s/4.cfg"
    echo "11" > "$DCP/8.cfg"
    (sleep 2 && notify-send -i idiomind "$(gettext "Checking for new episodes")" "$(gettext "Updating") $nps $(gettext "feeds...")" -t 6000) &
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
    "$(gettext "Feed update")" "$(gettext "Has") $nd $(gettext "Update(s)")" -t 8000
    exit 0
else
    if [[ ! -n "$1" && "$1" != A ]]; then
        notify-send -i idiomind "$(gettext "Feed update")" "$(gettext "No change since the last update")" -t 8000
    fi
    exit 0
fi

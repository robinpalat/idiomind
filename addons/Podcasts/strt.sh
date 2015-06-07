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

[[ -z "$DM" ]] && source /usr/share/idiomind/ifs/c.conf
source "$DS/ifs/mods/cmns.sh"
include "$DS/ifs/mods/add"
DSP="$DS/addons/Podcasts"
DMC="$DM_tl/Podcasts/cache"
DCP="$DM_tl/Podcasts/.conf"
dfimg="$DSP/images/audio.png"
date=$(date +%d)
downloads=2

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

sets=('channel' 'link' 'logo' 'ntype' \
'nmedia' 'ntitle' 'nsumm' 'nimage' 'url')

conditions() {
    
    [[ ! -f "$DCP/1.lst" ]] && touch "$DCP/1.lst"

    if [[ -f "$DT/.uptp" ]] && [[ $1 != 0 ]]; then
        msg_2 "$(gettext "Wait until it finishes a previous process")\n" info OK gtk-stop
        ret=$(echo $?)
        [[ $ret -eq 1 ]] && "$DS/stop.sh" 6
        exit 1
    
    elif [[ -f "$DT/.uptp" ]] && [[ $1 = 0 ]]; then
        exit 1
    fi
    
    if [[ ! -d "$DM_tl/Podcasts/cache" ]]; then
    mkdir -p "DM_tl/Podcasts/.conf"
    mkdir -p "DM_tl/Podcasts/cache"; fi

    nps="$(sed '/^$/d' "$DCP/feeds.lst" | wc -l)"
    if [[ "$nps" -le 0 ]]; then
    [[ "$1" != 0 ]] && msg "$(gettext "Missing URL. Please check the settings in the preferences dialog.")\n" info
    [[ -f "$DT_r" ]] && rm -fr "$DT_r" "$DT/.uptp"
    exit 1; fi
        
    if [[ $1 != 0 ]]; then internet; else curl -v www.google.com 2>&1 \
    | grep -m1 "HTTP/1.1" >/dev/null 2>&1 || exit 1; fi
}

mediatype () {

    if echo "$1" | grep -q ".mp3"; then ex=mp3; tp=aud
    elif echo "$1" | grep -q ".mp4"; then ex=mp4; tp=vid
    elif echo "$1" | grep -q ".ogg"; then ex=ogg; tp=aud
    elif echo "$1" | grep -q ".avi"; then ex=avi; tp=vid
    elif echo "$1" | grep -q ".m4v"; then ex=m4v; tp=vid
    elif echo "$1" | grep -q ".mov"; then ex=mov; tp=vid
    elif echo "$1" | grep -o ".pdf"; then ex=pdf; tp=txt
    else
        printf "Could not add some podcasts.\n$FEED" >> "$DM_tl/Podcasts/.conf/feed.err"
        return; fi
}

mkhtml () {

video="<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />
<link rel=\"stylesheet\" href=\"/usr/share/idiomind/default/vwr.css\">
<video width=640 height=380 controls>
<source src=\"$fname.$ex\" type=\"video/mp4\">
Your browser does not support the video tag.</video><br><br>
<div class=\"title\"><h3>$title</h3></div><br>
<div class=\"summary\">$summary<br><br></div>"
audio="<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />
<link rel=\"stylesheet\" href=\"/usr/share/idiomind/default/vwr.css\">
<br><div class=\"title\"><h2>$title</h2></div><br>
<div class=\"summary\"><audio controls><br>
<source src=\"$fname.$ex\" type=\"audio/mpeg\">
Your browser does not support the audio tag.</audio><br><br>
$summary<br><br></div>"
text="<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />
<link rel=\"stylesheet\" href=\"/usr/share/idiomind/default/vwr.css\">
<body><br><div class=\"title\"><h2>$title</h2></div><br>
<div class=\"summary\"><div class=\"image\">
<img src=\"$fname.jpg\" alt=\"Image\" style=\"width:650px\"></div><br>
$summary<br><br></div>
</body>"

    if [[ "$tp" = vid ]]; then
        if [[ "$ex" = m4v ]] || [[ $ex = mp4 ]]; then t=mp4
        elif [[ "$ex" = avi ]]; then t=avi; fi
        echo -e "$video" > "$DMC/$fname.html"

    elif [[ "$tp" = aud ]]; then
        echo -e "$audio" > "$DMC/$fname.html"

    elif [[ "$tp" = txt ]]; then
        echo -e "text" > "$DMC/$fname.html"
    fi
}

get_images () {

    if [[ "$tp" = aud ]]; then
        
        cd "$DT_r"; p=TRUE; rm -f ./*.jpeg ./*.jpg
        
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
        p=""; fi

    elif [[ "$tp" = vid ]]; then
        
        cd "$DT_r"; p=TRUE; rm -f ./*.jpeg ./*.jpg
        mplayer -ss 60 -nosound -noconsolecontrols \
        -vo jpeg -frames 3 "media.$ex" >/dev/null

        if ls | grep '.jpeg'; then img="$(ls | grep '.jpeg' | head -n1)"
        else img="$(ls | grep '.jpg' | head -n1)"; fi
        
        if [ ! -f "$DT_r/$img" ]; then
        cp -f "$DSP/images/video.png" "$DMC/$fname.png"
        p=""; fi
        
    elif [[ "$tp" = txt ]]; then
    
        cd "$DT_r"; p=TRUE
    
        img="media.$ex"
    fi
    
    if [[ "$p" = TRUE ]] && [[ -f "$DT_r/$img" ]]; then
    layer="$DSP/images/layer.png"
    convert "$DT_r/$img" -interlace Plane -thumbnail 62x54^ \
    -gravity center -extent 62x54 -quality 100% tmp.png
    convert tmp.png -bordercolor white \
    -border 2 \( +clone -background black \
    -shadow 70x3+2+2 \) +swap -background transparent \
    -layers merge +repage tmp.png
    composite -compose Dst_Over tmp.png "$layer" "$DMC/$fname.png"
    rm -f *.jpeg *.jpg *.png
    fi
}

fetch_podcasts() {

    n=1
    while read FEED; do
        
        if [[ ! -z "$FEED" ]]; then

            if [[ -f "$DCP/$n.rss" ]]; then
                d=0
                while [[ $d -lt 8 ]]; do
                    itn=$((d+1)); get=${sets[$d]}
                    val=$(sed -n "$itn"p < "$DCP/$n.rss" \
                    | grep -o "$get"=\"[^\"]* | grep -o '[^"]*$')
                    declare ${sets[$d]}="$val"
                    ((d=d+1))
                done
              
            else
                continue
            fi

            if [[ "$ntype" = 1 ]]; then

                podcast_items="$(xsltproc - "$FEED" <<<"$tmplitem" 2> /dev/null)"
                podcast_items="$(echo "${podcast_items}" | tr '\n' ' ' \
                | tr -s '[:space:]' | sed 's/EOL/\n/g' | head -n "$downloads")"
                podcast_items="$(echo "${podcast_items}" | sed '/^$/d')"
                
                while read -r item; do

                    fields="$(sed -r 's|-\!-|\n|g' <<<"${item}")"
                    enclosure=$(sed -n "$nmedia"p <<<"${fields}")
                    title=$(echo "${fields}" | sed -n "$ntitle"p | sed 's/\://g' \
                    | sed 's/\&/&amp;/g' | sed 's/^\s*./\U&\E/g' \
                    | sed 's/<[^>]*>//g' | sed 's/^ *//; s/ *$//; /^$/d')
                    summary=$(echo "${fields}" | sed -n "$nsumm"p)
                    #| iconv -c -f utf8 -t ascii
                    fname="$(nmfile "${title}")"
                    
                    if [[ ${#title} -ge 300 ]] \
                    || [[ -z "$title" ]]; then
                    continue; fi
                         
                    if ! grep -Fxo "${title}" < <(cat "$DCP/1.lst" "$DCP/2.lst" "$DCP/remove"); then
                    
                        enclosure_url=$(curl -s -I -L -w %"{url_effective}" \
                        --url "$enclosure" | tail -n 1)
                        mediatype "$enclosure_url"
                        
                        if [[ ! -f "$DMC/$fname.$ex" ]]; then
                        cd "$DT_r"; wget -q -c -T 51 -O "media.$ex" "$enclosure_url"
                        else cd "$DT_r"; mv -f "$DMC/$fname.$ex" "media.$ex"; fi
                        
                        exit=$?
                        if [[ $exit = 0 ]]; then
                        get_images
                        mv -f "media.$ex" "$DMC/$fname.$ex"
                        mkhtml

                        if [[ -s "$DCP/1.lst" ]]; then
                        sed -i -e "1i${title}\\" "$DCP/1.lst"
                        else echo "${title}" > "$DCP/1.lst"; fi
                        if grep '^$' "$DCP/1.lst"; then
                        sed -i '/^$/d' "$DCP/1.lst"; fi
                        echo "${title}" >> "$DCP/.11.cfg"
                        echo "${title}" >> "$DT_r/log"
                        echo -e "channel=\"${channel}\"" > "$DMC/$fname.item"
                        echo -e "link=\"${link}\"" >> "$DMC/$fname.item"
                        echo -e "title=\"${title}\"" >> "$DMC/$fname.item"
                        fi
                    fi
                done <<<"${podcast_items}"
            fi
            
        else
            [[ -f "$DCP/$n.rss" ]] && rm "$DCP/$n.rss"
        fi
        
        let n++
    done < "$DCP/feeds.lst"
}

removes() {
    
    check_index1 "$DCP/1.lst"
    if grep '^$' "$DCP/1.lst"; then
    sed -i '/^$/d' "$DCP/1.lst"; fi
    echo "$(tail -n+51 < "$DCP/1.lst")" >> "$DCP/remove"
    echo "$(head -n 50 < "$DCP/1.lst")" > "$DCP/kept"

    while read item; do
        if ! grep -Fxo "$item" "$DCP/2.lst"; then
        fname=$(nmfile "$item")
        find "$DMC" -type f -name "$fname.*" -exec rm {} +
        fi
    done < "$DCP/remove"
    
    while read item; do
    
       fname="$(nmfile "${item}")"
       echo "$fname" >> "$DT/nmfile"
        [[ ! -f "$DMC/$fname.png" ]] && cp "$dfimg" "$DMC/$fname.png"
        if [[ -f "$DMC/$fname.mp3" ]] || [[ -f "$DMC/$fname.ogg" ]] \
        || [[ -f "$DMC/$fname.mp4" ]] || [[ -f "$DMC/$fname.m4v" ]] \
        || [[ -f "$DMC/$fname.jpg" ]] || [[ -f "$DMC/$fname.png" ]] \
        || [[ -f "$DMC/$fname.pdf" ]] \
        && ([ -f "$DMC/$fname.html" ] && [ -f "$DMC/$fname.item" ]); then
            continue
        else
        grep -vxF "$item" "$DCP/2.lst" > "$DT/rm.temp"
        sed '/^$/d' "$DT/rm.temp" > "$DCP/2.lst"
        grep -vxF "$item" "$DCP/1.lst" > "$DT/rm.temp"
        sed '/^$/d' "$DT/rm.temp" > "$DCP/1.lst"
        rm -f "$DT/rm.temp"
        find "$DMC" -name "$fname".* -exec rm {} \;
        fi
    done < "$DCP/kept"
    
    while read r_item; do
    
       r_file=`basename "$r_item" |sed "s/\(.*\).\{4\}/\1/" |tr -d '.'`
       if ! grep -Fox "${r_file}" < "$DT/nmfile"; then
       [[ -f "$DMC/$r_item" ]] && rm "$DMC/$r_item"; fi
    done < <(cd "$DMC"; find . -type f)

    mv -f "$DCP/kept" "$DCP/1.lst"
    check_index1 "$DCP/1.lst" "$DCP/2.lst"
    if grep '^$' "$DCP/1.lst"; then
    sed -i '/^$/d' "$DCP/1.lst"; fi
    if grep '^$' "$DCP/2.lst"; then
    sed -i '/^$/d' "$DCP/2.lst"; fi
    echo "$(head -n 1000 < "$DCP/remove")" > "$DCP/remove_"
    mv -f "$DCP/remove_" "$DCP/remove"
    cp -f "$DCP/1.lst" "$DCP/.11.cfg"
    rm "$DT/nmfile"
}

conditions $1

if [[ $1 != 0 ]]; then
echo "Podcasts" > "$DC_a/4.cfg"
echo 2 > "$DC_s/5.cfg"
echo 11 > "$DCP/8.cfg"
notify-send -i idiomind "$(gettext "Podcasts")" \
"$(gettext "Checking for new episodes...")" -t 6000 &
fi

if [[ -f "$DCP/2.lst" ]]; then kept_episodes=`wc -l < "$DCP/2.lst"`
else kept_episodes=0; fi
> "$DT/.uptp"; rm "$DM_tl/Podcasts"/*.updt
echo -e " <b>$(gettext "Updating")</b>
 $(gettext "Latest downloads:") 0" > "$DM_tl/Podcasts/$date.updt"
DT_r="$(mktemp -d "$DT/XXXX")"
fetch_podcasts

if [[ -f "$DT_r/log" ]]; then new_episodes=`wc -l < "$DT_r/log"`
else new_episodes=0; fi
rm "$DM_tl/Podcasts"/*.updt
echo -e " $(gettext "Last update:") $(date "+%r %a %d %B")
 $(gettext "Latest downloads:") $new_episodes" > "$DM_tl/Podcasts/$date.updt"
rm -fr "$DT_r" "$DT/.uptp"

if [[ $new_episodes -gt 0 ]]; then
    [[ $new_episodes = 1 ]] && ne=$(gettext "new episode")
    [[ $new_episodes -gt 1 ]] && ne=$(gettext "new episodes")

    removes
    notify-send -i idiomind \
    "$(gettext "Update finished")" \
    "$new_episodes $ne" -t 8000
    
else
    if [[ $1 != 0 ]]; then
    notify-send -i idiomind \
    "$(gettext "Update finished")" \
    "$(gettext "Has not changed since last update")" -t 8000
    fi
fi

cfg="$DM_tl/Podcasts/.conf/0.lst"; if [[ -f "$cfg" ]]; then
sync="$(sed -n 2p "$cfg" | grep -o 'sync="[^"]*' | grep -o '[^"]*$')"
if [[ "$sync" = TRUE ]]; then 
    if [[ $1 != 0 ]]; then
    "$DSP/tls.sh" sync
    else
    "$DSP/tls.sh" sync 0
    fi
fi
fi
exit

#!/bin/bash
# -*- ENCODING: UTF-8 -*-


#narrow="/media/Archivos/Desing/RECURSOS/Stop-icon.png"
#wider="/media/Archivos/Desing/Star-icon.png"
#convert                          \
#-background '#FFF9E3'          \
#xc:none -resize 200x1\!       \
#right+LOGO.png -append      \
#left+image.png                \
#-gravity south                 \
#+append                        \
#-crop '400x +0+1'              \
#+repage                        \
#result.png


#convert                          \
   #-background '#FFF9E3'          \
    #xc:none -resize 200x1\!       \
    #right+LOGO.png -append      \
    #left+images.png                \
   #-gravity south                 \
   #+append                        \
   #-crop '400x +0+1'              \
   #+repage                        \
    #result.png



#montage                 \
  #-background '#FFF9E3' \
  #-geometry 200\!x\>    \
  #-gravity west         \
   #right+LOGO.png     \
   #left+images.png       \
   #result.png







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
  xmlns:itunes='http://www.itunes.com/dtds/feed-1.0.dtd'
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
uid=$(sed -n 1p $DC_s/4.cfg)
[ ! -f "$DM_tl/Feeds/.conf/8.cfg" ] \
&& echo "11" > "$DM_tl/Feeds/.conf/8.cfg"
echo "$tpc" > "$DC_s/8.cfg"
echo fd >> "$DC_s/8.cfg"
exit 1'
DSF="$DS/addons/Feeds"
DMC="$DM_tl/Feeds/cache"
DCF="$DM_tl/Feeds/.conf"
DT_r=$(mktemp -d $DT/XXXX)
rssf="$DCF/4.cfg"
cp -f "$rssf" "$DT_r/rss_list"
W=$(sed -n 3p $DC_s/18.cfg)
H=$(sed -n 4p $DC_s/18.cfg)


function conditions() {
    
    [ ! -f "$DCF/1.cfg" ] && > "$DCF/1.cfg"
    [ ! -f "$DCF/2.cfg" ] && > "$DCF/2.cfg"
    internet
    
    if ([ -f "$DT/.uptf" ] && [ -z "$1" ]); then
        msg_2 "$(gettext "Wait till it finishes a previous process")\n" info OK gtk-stop
        ret=$(echo $?)
        [ $ret -eq 1 ] && "$DS/stop.sh" feed
        [ $ret -eq 0 ] && exit 1
        
    elif [[ -f "$DT/.uptf" && "$1" = A ]]; then
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
        echo "11" > "$DM_tl/Feeds/.conf/8.cfg"
        cd "$DM_tl/Feeds/.conf/"
        touch 0.cfg 3.cfg 4.cfg .updt.lst
        > 1.cfg
        "$DS/mngr.sh" mkmn
    fi
    
    n=1; DCF="$DM_tl/Feeds/.conf"
    while [ $n -le "$(wc -l < "$rssf")" ]; do
        if ([ -n "$(grep -v   " - - -" < "$DCF/$n.xml" | uniq -dc)" ] \
        || [ $(wc -l < "$DCF/$n.xml") != 7 ] \
        || [ ! -f "$DCF/$n.xml" ]); then
                echo "$n" > $DT/dupl.cnf
                msg "$(gettext "Se encontró un error en la configuración de un feed\n ")" dialog-warning
                [ -f "$DT/.uptf" ] && rm -fr "$DT_r" "$DT/.uptf"
            exit 1
        fi
        let n++
    done
    
    nps="$(wc -l < "$rssf")"
    if [ "$nps" -le 0 ]; then
        msg "$(gettext "Missing URL. Please check the settings in the preferences dialog.")\n" info
        [ -f "$DT/.uptf" ] && rm -fr "$DT_r" "$DT/.uptf"
        exit 1; fi
}

mediatype () {

    if echo "$1" | grep -o ".jpg"; then ex="jpg"
    elif echo "$1" | grep -o ".jpeg"; then ex="jpeg"
    elif echo "$1" | grep -o ".png"; then ex="png"
    fi
    #else
        #msg "$(gettext "Se encontró un error en la configuración de un feed\n ")" dialog-warning;
        #[ -f "$DT/.uptf" ] && rm -fr "$DT_r" "$DT/.uptf"
        #exit 1; fi
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


get_images () {
    
    cd "$DT_r"

    #if [ ! -f "media.$ex" ]; then
    
        #u="$(echo "$summary" | grep -o 'img src="[^"]*' | grep -o '[^"]*$' | sed -n 1p)"
        #wget "$u"
        
        #wget -q -c -T 30 -O "media.$ex" "$enclosure_url"
            
        #if ls | grep '.jpeg'; then img="$(ls | grep '.jpeg')"
        #elif ls | grep '.png'; then img="$(ls | grep '.png')"
        #elif ls | grep '.jpg'; then img="$(ls | grep '.jpg')"
        #fi
            
        #if [ -f "$DT_r/$img" ]; then
        
            #img="$DT_r/$img"

        #fi

    #else
    img="media.$ex"
    #fi
    
    vsize="$(identify "media.$ex" | cut -d ' ' -f 3 | cut -d 'x' -f 1)"
    
    if [ "$vsize" -ge 300 ]; then
        
        w=1
        while read -r word; do
            declare "word$w"="$word"
            ((w=w+1))
        done <<< "$(echo "$title" | tr ' ' '\n')"
        
        if [ -f "$DT_r/$img" ]; then

            convert "$DT_r/$img" -interlace Plane -thumbnail 570x380^ \
            -gravity center -extent 570x380 \
            -fill white -box '#00770080' -gravity South-East -pointsize 28 -annotate +0+210 "   $word1  " \
            -fill white -box '#77290080' -gravity South-East -pointsize 28 -annotate +0+130 "  $word2  " \
            -fill white -box '#00227780' -gravity South-East -pointsize 28 -annotate +0+60 "  $word3  " \
            -fill white -box '#0008' -gravity South -pointsize 15 -annotate +0+0 " $title " \
            -bordercolor white -border 15 -quality 100% "$DMC/$fname.png"
            rm -f *.jpeg *.jpg
        fi
    else
            convert "$DT_r/$img" -interlace Plane -thumbnail 570x380^ \
            -gravity center -extent 570x380 \
            -fill white -box '#00770080' -gravity South-East -pointsize 28 -annotate +0+210 "   $word1  " \
            -fill white -box '#77290080' -gravity South-East -pointsize 28 -annotate +0+130 "  $word2  " \
            -fill white -box '#00227780' -gravity South-East -pointsize 28 -annotate +0+60 "  $word3  " \
            -fill white -box '#0008' -gravity South -pointsize 15 -annotate +0+0 " $title " \
            -bordercolor white -border 15 -quality 100% "$DMC/$fname.png"
            rm -f *.jpeg *.jpg
    fi

}




fetch() {

    n=1
    while read FEED; do
        
        if [ -z "$FEED" ]; then
            break; msg "$(gettext "Se encontró un error en la configuración de un feed\n ")" dialog-warning &
            [ -f "$DT/.uptf" ] && rm -fr "$DT_r" "$DT/.uptf"
            exit 1; fi
        
        channel_info="$(xsltproc - "$FEED" <<< "$tmplchannel" 2> /dev/null)"
        channel_info="$(echo "$channel_info" | tr '\n' ' ' \
        | tr -s '[:space:]' | sed 's/EOL/\n/g' | head -n 1)"
        field="$(echo "$channel_info" | sed -r 's|-\!-|\n|g')"
        channel="$(echo "$field" | sed -n 1p \
        | iconv -c -f utf8 -t ascii \
        | sed 's/\://g' | sed 's/\&/&amp;/g')"
        link=$(echo "$field" | sed -n 2p)
        feed_items="$(xsltproc - "$FEED" <<< "$tmplitem" 2> /dev/null)"
        feed_items="$(echo "$feed_items" | tr '\n' ' ' \
        | tr -s '[:space:]' | sed 's/EOL/\n/g' | head -n "$nps")"
        feed_items="$(echo "$feed_items" | sed '/^$/d')"
        n_enc=$(grep -Fxon "$(gettext "Image")" < "$DCF/$n.xml" \
        | sed -n 's/^\([0-9]*\)[:].*/\1/p')
        n_tit=$(grep -Fxon "$(gettext "Title")" < "$DCF/$n.xml" \
        | sed -n 's/^\([0-9]*\)[:].*/\1/p')
        n_sum=$(grep -Fxon "$(gettext "Summary")" < "$DCF/$n.xml" \
        | sed -n 's/^\([0-9]*\)[:].*/\1/p')
        
        while read -r item; do

            fields="$(echo "$item" | sed -r 's|-\!-|\n|g')"
            enclosure=$(echo "$fields" | sed -n "$n_enc"p)
            title=$(echo "$fields" | sed -n "$n_tit"p \
            | iconv -c -f utf8 -t ascii | sed 's/\://g' \
            | sed 's/\&/&amp;/g' | sed 's/^\s*./\U&\E/g' \
            | sed 's/<[^>]*>//g' | sed 's/^ *//; s/ *$//; /^$/d')
            sumlink=$(echo "$fields" | sed -n "$n_sum"p)
            summary=$(echo "$fields" | sed -n "$n_sum"p \
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
            
            #lynx -stdin -dump < file.html
            
        
            
            if [ "$(echo "$title" | wc -c)" -ge 200 ]; then
                    msg "$(gettext "Se encontró un error (04) en la configuración de un feed") ($n)\n $title" info;
                    continue; fi
                    
            #if ([ "$(echo "$title" | wc -c)" -ge 180 ] \
            #|| [ -z "$title" ]); then
                    #msg "$(gettext "Se encontró un error (04) en la configuración de un feed") ($n)\n $title" info;
                    #continue; fi

            if ! grep -Fxo "$title" < "$DCF/1.cfg"; then
            
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
                
                
                if [ -z "$channel" ]; then
                    channel="$(eyeD3 --no-color "media.$ex" \
                    | grep -o -P '(?<=title:).*(?=artist:)' \
                    | sed -e 's/^[ \t]*//g' | tr -s '\ \t' \
                    | sed -e "s/[[:space:]]\+/ /g" | sed 's/\&/&amp;/g' \
                    | sed 's/^ *//; s/ *$//; /^$/d' | tr -s ':')"
                fi
                

                get_images
                
                DCF="$DM_tl/Feeds/.conf"
                printf "\n$summary" > "$DMC/$fname.txt"
                echo -e "channel=\"$channel\"" > "$DMC/$fname.i"
                echo -e "link=\"$link\"" >> "$DMC/$fname.i"
                echo -e "title=\"$title\"" >> "$DMC/$fname.i"
                if [ -s "$DCF/1.cfg" ]; then
                sed -i -e "1i$title\\" "$DCF/1.cfg"
                else
                echo "$title" > "$DCF/1.cfg"; fi
                if grep '^$' "$DCF/1.cfg"; then
                sed -i '/^$/d' "$DCF/1.cfg"; fi
                echo "$title" >> "$DCF/.11.cfg"
                echo "$title" >> "$DT_r/log"
            fi

        done <<< "$feed_items"

        let n++
    
    done < "$DT_r/rss_list"
}

remove_items() {
    
    n=50
    while [[ $n -le "$(wc -l < "$DCF/1.cfg")" ]]; do
        item="$(sed -n "$n"p "$DCF/1.cfg")"
        if ! grep -Fxo "$title" < "$DCF/2.cfg"; then
            fname="$(nmfile "${item}")"
            [ -f "$DMC/$fname.png" ] && rm "$DMC/$fname.png"
            [ -f "$DMC/$fname.txt" ] && rm "$DMC/$fname.txt"
            [ -f "$DMC/$fname.i" ] && rm "$DMC/$fname.i"
        fi
        grep -vxF "$item" "$DCF/1.cfg" > "$DT/item.tmp"
        sed '/^$/d' "$DT/item.tmp" > "$DCF/1.cfg"
        let n++
    done
}

check_index() {
    
    check_index1 "$DCF/1.cfg"
    if grep '^$' "$DCF/1.cfg"; then
    sed -i '/^$/d' "$DCF/1.cfg"; fi
    cp -f "$DCF/1.cfg" "$DCF/.11.cfg"
    
    df_img="$DSF/images/item.png"
    while read item; do
        fname="$(nmfile "${item}")"
        if ([ -f "$DMC/$fname.txt" ] || [ -f "$DMC/$fname.i" ]); then
            echo ok
        else
            echo "$item" >> "$DT/cchk"; fi
        if [ ! -f "$DMC/$fname.png" ]; then
            cp "$df_img" "$DMC/$fname.png"
        fi
    done < "$DCF/1.cfg"
    
    if [ -f "$DT/cchk" ]; then
        while read item; do
            grep -vxF "$item" "$DCF/.11.cfg" > "$DCF/.11.cfg.tmp"
            sed '/^$/d' "$DCF/.11.cfg.tmp" > "$DCF/.11.cfg"
            grep -vxF "$item" "$DCF/1.cfg" > "$DCF/1.cfg.tmp"
            sed '/^$/d' "$DCF/1.cfg.tmp" > "$DCF/1.cfg"
        done < "$DT/cchk"
        [ -f "$DCF/*.tmp" ] && rm "$DCF/*.tmp"
    fi
}

conditions

if [ "$1" != A ]; then
    echo "$tpc" > "$DC_s/8.cfg"
    echo fd >> "$DC_s/8.cfg"
    echo "11" > "$DCF/8.cfg"
    (sleep 2 && notify-send -i idiomind "$(gettext "Updating feeds")" "$(gettext "Updating") $nps $(gettext "feeds...")" -t 6000) &
fi

echo "updating" > "$DT/.uptf"
nps=5
fetch

[ -f "$DT_r/log" ] && nd="$(wc -l < "$DT_r/log")" || nd=0
rm -fr "$DT_r" "$DT/.uptf"

if [ "$nd" -gt 0 ]; then
    remove_items
    check_index
    echo "$(date "+%a %d %B")" > "$DM_tl/Feeds/.dt"
    notify-send -i idiomind \
    "$(gettext "Update finished")" "$(gettext "Downloaded") $nd $(gettext "episode(s)")" -t 8000
    exit
else
    if [[ ! -n "$1" && "$1" != A ]]; then
        notify-send -i idiomind \
        "$(gettext "No new episodes")" "$(gettext "Downloaded") $nd $(gettext "episode(s)")" -t 8000
    fi
    
    exit
fi

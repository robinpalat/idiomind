#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source "$DS/ifs/mods/cmns.sh"
include "$DS/ifs/mods/add"


function conditions() {
    
    internet
    
    if ([ -f "$DT/.uptp" ] && [ -z "$1" ]); then
        yad --image=info --width=420 --height=150 \
        --window-icon=idiomind --title=Info --center \
        --borders=5 --on-top --skip-taskbar \
        --button="$(gettext "Cancel")":2 --button=Ok:1 \
        --text="$(gettext "Wait till it finishes a previous process")"
        ret=$?
            [ $ret -eq 2 ] && "$DS/stop.sh" feed
        
    elif ( [ -f "$DT/.uptp" ] && [ "$1" = A ] ); then
        exit 1
    fi

    if [ ! -d "$DM_tl/Podcasts/content" ]; then
        mkdir -p "DM_tl/Podcasts/.conf"
        mkdir -p "DM_tl/Podcasts/content"
    fi
    
    if ([ ! -f "$DM_tl/Podcasts/tpc.sh" ] || \
    [ "$(wc -l < "$DM_tl/Podcasts/tpc.sh")" -ge 15 ]); then
        echo '#!/bin/bash
    source /usr/share/idiomind/ifs/c.conf
    uid=$(sed -n 1p $DC_s/cfg.4)
    [ ! -f "$DM_tl/Podcasts/.conf/cfg.8" ] \
    && echo "14" > "$DM_tl/Podcasts/.conf/cfg.8"
    sleep 1
    echo "$tpc" > $DC_s/cfg.8
    echo pd >> $DC_s/cfg.8
    #notify-send -i idiomind "Podcast Mode" " $FEED" -t 3000
    exit 1' > "$DM_tl/Podcasts/tpc."
        chmod +x "$DM_tl/Podcasts/tpc.sh"
        echo "14" > "$DM_tl/Podcasts/.conf/cfg.8"
        cd "$DM_tl/Podcasts/.conf/"
        touch cfg.0 cfg.1 cfg.3 cfg.4 .updt.lst
        "$DS/mngr.sh" mkmn
    fi
    
    n=1; DCP="$DM_tl/Podcasts/.conf"
    while [ $n -le "$(wc -l < "$rssf")" ]; do
        if ([ -n "$(grep -v   " - - -" < "$DCP/$n.xml" | uniq -dc)" ] \
        || [ $(wc -l < "$DCP/$n.xml") != 7 ] \
        || [ ! -f "$DCP/$n.xml" ]); then
            echo "$n" > $DT/dupl.cnf
            msg "$(gettext "Se encontro un error en la configuracion de un feed\n ")" dialog-warning &
            exit 1
        fi
        let n++
    done
    
    nps="$(wc -l < "$rssf")"
    [ "$nps" -le 0 ] && msg "$(gettext " Missing URL\n Please check the settings\n in the preferences dialog.")" info && exit 1
}


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
      <xsl:value-of select='media:contentt[@type=\"audio/mpeg\"]/@url'/><xsl:text>-!-</xsl:text>
      <xsl:value-of select='title'/><xsl:text>-!-</xsl:text>
      <xsl:value-of select='media:contentt[@type=\"audio/mpeg\"]/@duration'/><xsl:text>-!-</xsl:text>
      <xsl:value-of select='itunes:summary'/><xsl:text>-!-</xsl:text>
      <xsl:value-of select='description'/><xsl:text>EOL</xsl:text>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>"
DSP="$DS/addons/Podcasts"
DMC="$DM_tl/Podcasts/content"
DCP="$DM_tl/Podcasts/.conf"
DT_r=$(mktemp -d $DT/XXXX)
rssf="$DCP/cfg.4"
[ ! -f "$DCP/cfg.1" ] && touch "$DCP/cfg.1"
cp -f "$rssf" "$DT_r/rss_list"

mediatype () {

    if echo "$1" | grep -o ".mp3"; then ex="mp3"; tp="aud"
    elif echo "$1" | grep -o ".mp4"; then ex="mp4"; tp="vid"
    elif echo "$1" | grep -o ".ogg"; then ex="ogg"; tp="aud"
    elif echo "$1" | grep -o ".avi"; then ex="avi"; tp="vid"
    elif echo "$1" | grep -o ".m4v"; then ex="m4v"; tp="vid"
    else
        msg "$(gettext "Se encontro un error en la configuracion de un feed\n ")" dialog-warning & exit 1
    fi
}

fetch_podcasts() {

    n=1
    while [ $n -le 8 ]; do
        
        FEED="$(sed -n "$n"p "$DT_r/rss_list")"
        [ -z "$FEED" ] && break
        
        channel_info="$(xsltproc - "$FEED" <<< "$tmplchannel" 2> /dev/null)"
        channel_items="$(echo "$channel_info" | tr '\n' ' ' \
        | tr -s '[:space:]' | sed 's/EOL/\n/g' | head -n 1)"
        field="$(echo "$channel_items" | sed -r 's|-\!-|\n|g' \
        | sed 's/\]\[/\n/g' | iconv -c -f utf8 -t ascii \
        | sed 's/\://g' | sed 's/\&/&amp;/g')"
        channel=$(echo "$field" | sed -n 1p)
        link=$(echo "$field" | sed -n 2p)
        
        podcast_items="$(xsltproc - "$FEED" <<< "$tmplitem" 2> /dev/null)"
        podcast_items="$(echo "$podcast_items" | tr '\n' ' ' \
        | tr -s '[:space:]' | sed 's/EOL/\n/g' | head -n "$nps")"
        podcast_items="$(echo "$podcast_items" | sed '/^$/d')"
        n_enc=$(grep -Fxon "$(gettext "Enclosure audio/video")" < "$DCP/$n.xml" \
        | sed -n 's/^\([0-9]*\)[:].*/\1/p')
        n_tit=$(grep -Fxon "$(gettext "Episode title")" < "$DCP/$n.xml" \
        | sed -n 's/^\([0-9]*\)[:].*/\1/p')
        n_sum=$(grep -Fxon "$(gettext "Summary/Description")" < "$DCP/$n.xml" \
        | sed -n 's/^\([0-9]*\)[:].*/\1/p')
        
        while read -r item; do

            fields="$(echo "$item" | sed -r 's|-\!-|\n|g')"
            enclosure=$(echo "$fields" | sed -n "$n_enc"p)
            
            if [ -z "$enclosure" ]; then
                continue
            fi
            
            title=$(echo "$fields" | sed -n "$n_tit"p \
            | iconv -c -f utf8 -t ascii | sed 's/\://g' | sed 's/\&/&amp;/g')
            summary=$(echo "$fields" | sed -n "$n_sum"p)
            
            if [ "$(echo "$title" | wc -c)" -ge 150 ]; then
                msg "$(gettext "Se encontro un error en la configuracion de un feed\n ")" dialog-warning & exit 1
            fi

            if ! grep -Fxo "$title" < "$DCP/cfg.1"; then
            
                enclosure_url=$(curl -s -I -L -w %"{url_effective}" \
                --url "$enclosure" | tail -n 1)
                mediatype "$enclosure_url"
            
                cd "$DT_r"; wget -q -c -T 30 -O "media.$ex" "$enclosure_url"
                
                if [ -z "$channel" ]; then
                    channel="$(eyeD3 --no-color "media.$ex" \
                    | grep -o -P '(?<=title:).*(?=artist:)' \
                    | sed -e 's/^[ \t]*//g' | tr -s '\ \t' \
                    | sed -e "s/[[:space:]]\+/ /g" \
                    | sed 's/^ *//; s/ *$//; /^$/d' | tr -s ':')"
                fi
                fname="$(nmfile "${title}")"

                cd "$DT_r"; p=TRUE; rm -f *.jpeg *.jpg

                if [ "$tp" = aud ]; then

                    eyeD3 --write-images="$DT_r" "media.$ex"

                    if ls | grep '.jpeg'; then img="$(ls | grep '.jpeg')"
                    else img="$(ls | grep '.jpg')"; fi

                    if [ ! -f "$DT_r/$img" ]; then
                    
                        wget -q -O- "$FEED" | grep -o '<itunes:image href="[^"]*' \
                        | grep -o '[^"]*$' | xargs wget -c
                        
                        if ls | grep '.jpeg'; then img="$(ls | grep '.jpeg')"
                        else img="$(ls | grep '.jpg')"; fi
                    fi
                        
                        if [ ! -f "$DT_r/$img" ]; then
                        
                            cp -f "$DSP/images/audio.png" "$DMC/$fname.png"
                            p=""
                        fi
                fi

                if [ "$tp" = vid ]; then
                    
                    mplayer -ss 60 -nosound -vo jpeg -frames 1 "media.$ex"
                    
                    if ls | grep '.jpeg'; then img="$(ls | grep '.jpeg')"
                    else img="$(ls | grep '.jpg')"; fi
                    
                    if [ ! -f "$DT_r/$img" ]; then
                        
                        cp -f "$DSP/images/video.png" "$DMC/$fname.png"
                        p=""
                    fi
                fi
                
                if ([ "$p" = TRUE ] && [ -f "$DT_r/$img" ]); then
                
                    convert "$DT_r/$img" -interlace Plane -thumbnail 52x44^ \
                    -gravity center -extent 52x44 -quality 100% tmp.jpg
                    convert tmp.jpg -bordercolor white \
                    -border 2 \( +clone -background black \
                    -shadow 60x3+2+2 \) +swap -background transparent \
                    -layers merge +repage "$DMC/$fname.png"
                    rm -f *.jpeg *.jpg
                fi
                
                mv -f "media.$ex" "$DMC/$fname.$ex"
                printf "\n$summary" > "$DMC/$fname.txt"
                echo -e "channel=\"$channel\"" > "$DMC/$fname.i"
                echo -e "link=\"$link\"" >> "$DMC/$fname.i"
                echo -e "title=\"$title\"" >> "$DMC/$fname.i"
                sed -i -e "1i$title\\" "$DCP/cfg.1"
                if grep '^$' "$DCP/cfg.1"; then
                sed -i '/^$/d' "$DCP/cfg.1"; fi
                echo "$title" >> "$DCP/.cfg.11"
                echo "$title" >> "$DT_r/log"
            fi

        done <<< "$podcast_items"

        let n++
    
    done < "$DT_r/rss_list"
}


remove_items() {
    
    n=50
    while [[ $n -le "$(wc -l < "$DCP/cfg.1")" ]]; do
        item="$(sed -n "$n"p "$DCP/cfg.1")"
        if ! grep -Fxo "$title" < "$DCP/cfg.2"; then
            fname="$(nmfile "${item}")"
            [ -f "$DMC/$fname.mp4" ] && rm "$DMC/$fname.mp4"
            [ -f "$DMC/$fname.ogg" ] && rm "$DMC/$fname.ogg"
            [ -f "$DMC/$fname.avi" ] && rm "$DMC/$fname.avi"
            [ -f "$DMC/$fname.m4v" ] && rm "$DMC/$fname.m4v"
            [ -f "$DMC/$fname.flv" ] && rm "$DMC/$fname.flv"
            [ -f "$DMC/$fname.txt" ] && rm "$DMC/$fname.txt"
            [ -f "$DMC/$fname.i" ] && rm "$DMC/$fname.i"
        fi
        grep -vxF "$item" "$DCP/cfg.1" > "$DT/item.tmp"
        sed '/^$/d' "$DT/item.tmp" > "$DCP/cfg.1"
        let n++
    done
}


check_index() {
    
    check_index1 "$DCP/cfg.1"
    if grep '^$' "$DCP/cfg.1"; then
    sed -i '/^$/d' "$DCP/cfg.1"; fi
    cp -f "$DCP/cfg.1" "$DCP/.cfg.11"
    
    df_img="$DSP/images/item.png"
    while read item; do
        fname="$(nmfile "${item}")"
        if ([ -f "$DMC/$fname.mp3" ] || \
        [ -f "$DMC/$fname.mp4" ] || \
        [ -f "$DMC/$fname.ogg" ] || \
        [ -f "$DMC/$fname.avi" ] || \
        [ -f "$DMC/$fname.m4v" ] || \
        [ -f "$DMC/$fname.flv" ]); then
            echo ok
        else
            echo "$item" >> "$DT/cchk"; fi
        if [ ! -f "$DMC/$fname.png" ]; then
            cp "$df_img" "$DMC/$fname.png"
        fi
    done < "$DCP/cfg.1"
    
    if [ -f "$DT/cchk" ]; then
        while read item; do
            grep -vxF "$item" "$DCP/.cfg.11" > "$DCP/.cfg.11.tmp"
            sed '/^$/d' "$DCP/.cfg.11.tmp" > "$DCP/.cfg.11"
            grep -vxF "$item" "$DCP/cfg.1" > "$DCP/cfg.1.tmp"
            sed '/^$/d' "$DCP/cfg.1.tmp" > "$DCP/cfg.1"
        done < "$DT/cchk"
        [ -f "$DCP/*.tmp" ] && rm "$DCP/*.tmp"
    fi
}

conditions

if [ "$1" != A ]; then
    echo "$tpc" > "$DC_s/cfg.8"
    echo pd >> "$DC_s/cfg.8"
    echo "14" > "$DCP/cfg.8"
    (sleep 2 && notify-send -i idiomind "$(gettext "Checking for new downloads")" "$(gettext "Updating") $nps $(gettext "feeds...")" -t 6000) &
fi

echo "updating" > "$DT/.uptp"
nps=4
fetch_podcasts

[ -f "$DT_r/log" ] && dwls="$(wc -l < "$DT_r/log")" || dwls=0
rm -fr "$DT_r" "$DT/.uptp"

if [ "$dwls" -gt 0 ]; then
    remove_items
    check_index
    echo "$(date "+%a %d %B")" > "$DM_tl/Podcasts/.dt"
    notify-send -i idiomind \
    "$(gettext "Update finished")" "$(gettext "Downloaded") $dwls $(gettext "episode(s)")" -t 8000
    exit
else
    notify-send -i idiomind \
    "$(gettext "No new episodes")" "$(gettext "Downloaded") $dwls $(gettext "episode(s)")" -t 8000
    exit
fi

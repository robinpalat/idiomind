#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/mods/cmns.sh
include $DS/ifs/mods/add
DSF="$DS/addons/Podcasts"
DCF="$DC/addons/Podcasts"
DT_r=$(mktemp -d $DT/XXXX)

[ -f $DT/.uptp ] && STT=$(cat $DT/.uptp) || STT=""
[ ! -f $DC/addons/dict/.dicts ] && touch $DC/addons/dict/.dicts

if [[ -z "$(cat $DC_a/dict/.dicts)" ]]; then
    source $DS/ifs/trans/$lgs/topics_lists.conf
    $DS_a/Dics/cnfg.sh "" f "$(gettext "Dictionary list has not been set.")"
    if  [[ -z "$(cat $DC_a/dict/.dicts)" ]]; then
        exit 1
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
      <xsl:value-of select='title'/><xsl:text>][</xsl:text>
      <xsl:value-of select='link'/><xsl:text>][</xsl:text>
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
      <xsl:value-of select='enclosure/@url'/><xsl:text>][</xsl:text>
      <xsl:value-of select='media:contentt[@type=\"audio/mpeg\"]/@url'/><xsl:text>][</xsl:text>
      <xsl:value-of select='title'/><xsl:text>][</xsl:text>
      <xsl:value-of select='media:contentt[@type=\"audio/mpeg\"]/@duration'/><xsl:text>][</xsl:text>
      <xsl:value-of select='itunes:summary'/><xsl:text>][</xsl:text>
      <xsl:value-of select='description'/><xsl:text>EOL</xsl:text>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>"

if ( [ -f $DT/.uptp ] && [ -z "$1" ] ); then

    yad --image=info --width=420 --height=150 \
    --window-icon=idiomind \
    --title=Info --center --borders=5 \
    --on-top --skip-taskbar --button="$(gettext "Cancel")":2 \
    --button=Ok:1 --text="$(gettext "Wait till it finishes a previous process")"
    ret=$?
        if [ $ret -eq 1 ]; then
            exit 1
        elif [ $ret -eq 2 ]; then
            $DS/stop.sh feed
        fi
    
elif ( [ -f $DT/.uptp ] && [ "$1" = A ] ); then
    exit 1
fi

RSSFILE="$DCF/$lgtl/link"
icon=$DS/images/cnn.png
date=$(date "+%a %d %B")
c=$(echo $(($RANDOM%1000)))
DATESTRING="%Y%m%d"
CWD=$(pwd)
TEMPRSSFILE="$DT_r/mp.conf.temp"

if [ ! -d $DM_tl/Podcasts ]; then

    mkdir $DM_tl/Podcasts
    mkdir $DM_tl/Podcasts/.conf
    mkdir $DM_tl/Podcasts/content
    mkdir $DM_tl/Podcasts/kept
    mkdir "$DC_a/Podcasts"
fi
    
if ([ ! -f $DM_tl/Podcasts/tpc.sh ] || \
[ "$(cat $DM_tl/Podcasts/tpc.sh | wc -l)" -ge 15 ]); then

    echo '#!/bin/bash
source /usr/share/idiomind/ifs/c.conf
uid=$(sed -n 1p $DC_s/cfg.4)
[ ! -f $DM_tl/Podcasts/.conf/cfg.8 ] \
&& echo "14" > $DM_tl/Podcasts/.conf/cfg.8
sleep 1
echo "$tpc" > $DC_s/cfg.8
echo pd >> $DC_s/cfg.8
#notify-send -i idiomind "Podcast Mode" " $FEED" -t 3000
exit 1' > $DM_tl/Podcasts/tpc.sh

    chmod +x $DM_tl/Podcasts/tpc.sh
    echo "14" > $DM_tl/Podcasts/.conf/cfg.8
    cd $DM_tl/Podcasts/.conf/
    touch cfg.0 cfg.1 cfg.3 cfg.4 .updt.lst
    $DS/mngr.sh mkmn
fi

dir_content="$DM_tl/Podcasts/content"
dir_conf="$DM_tl/Podcasts/.conf"
dir_content="$DM_tl/Podcasts/content"
touch $TEMPRSSFILE
cp "$RSSFILE" "$TEMPRSSFILE"

mediatype () {

    if echo $1 | grep -o ".mp3"; then ex="mp3"; tp="aud"; fi
    if echo $1 | grep -o ".mp4"; then ex="mp4"; tp="vid"; fi
    if echo $1 | grep -o ".ogg"; then ex="ogg"; tp="aud"; fi
    if echo $1 | grep -o ".avi"; then ex="avi"; tp="vid"; fi
    if echo $1 | grep -o ".m4v"; then ex="m4v"; tp="vid"; fi
}


fetch_podcasts() {

    c=1
    while read FEED; do
        
        [ -z "$FEED" ] && break
        
        channel_info="$(xsltproc - "$FEED" <<< "$tmplchannel" 2> /dev/null)"
        channel_items="$(echo "$channel_info" | tr '\n' ' ' \
        | tr -s [:space:] | sed 's/EOL/\n/g' | head -n 1)"
        field="$(echo "$channel_items" | tr -s '][' '\n' | sed 's/\]\[/\n/g')"
        channel=$(echo "$field" | sed -n 1p)
        link=$(echo "$field" | sed -n 2p)

        podcast_items="$(xsltproc - "$FEED" <<< "$tmplitem" 2> /dev/null)"
        podcast_items="$(echo "$podcast_items" | tr '\n' ' ' \
        | tr -s [:space:] | sed 's/EOL/\n/g' | head -n $nps)"
        n_enc=$(cat "$DCF/$lgtl/$c.xml" | grep -Fxon "Enclosure" \
        | sed -n 's/^\([0-9]*\)[:].*/\1/p')
        n_tit=$(cat "$DCF/$lgtl/$c.xml" | grep -Fxon "Title" \
        | sed -n 's/^\([0-9]*\)[:].*/\1/p')
        n_sum=$(cat "$DCF/$lgtl/$c.xml" | grep -Fxon "Summary" \
        | sed -n 's/^\([0-9]*\)[:].*/\1/p')
        
        while read -r ITEM; do

            fields="$(echo "$ITEM" | sed 's/\]\[/\n/g')"
            enclosure=$(echo "$fields" | sed -n "$n_enc"p)
            title=$(echo "$fields" | sed -n "$n_tit"p \
            | iconv -c -f utf8 -t ascii | sed 's/\://g' | sed 's/\&//g')
            summary=$(echo "$fields" | sed -n "$n_sum"p)
            
            if ! cat $dir_conf/cfg.1 | grep -Fxo "$title"; then
            
                enclosure_url=$(curl -s -I -L -w %{url_effective} \
                --url $enclosure | tail -n 1)
                mediatype $enclosure_url
            
                cd $DT_r; wget -q -c -T 30 -O "media.$ex" "$enclosure_url"
                
                if [ -z "$channel" ]; then
                    channel="$(eyeD3 --no-color "media.$ex" \
                    | grep -o -P '(?<=title:).*(?=artist:)' \
                    | sed -e 's/^[ \t]*//g' | tr -s '\ \t' \
                    | sed -e "s/[[:space:]]\+/ /g" \
                    | sed 's/^ *//; s/ *$//; /^$/d' | tr -s ':')"
                fi
                fname="$(nmfile "${title^}")"
                
                
                #-------------------------------------------------
                #images
                cd $DT_r
                if [ $tp = aud ]; then

                    rm -f *.jpeg *.jpg
                    eyeD3 --write-images=/$DT_r "media.$ex"
                    
                    if ls | grep '.jpeg'; then /usr/bin/convert -scale 48x40! *.jpeg img.png; fi
                    if ls | grep '.jpg'; then /usr/bin/convert -scale 48x40! *.jpg img.png; fi
                    
                    if [ -f img.png ]; then
                        mv -f img.png "$dir_content/$fname.png"
                    
                    elif [ ! -f img.png ]; then
                    
                        wget -q -O- "$FEED" | grep -o '<itunes:image href="[^"]*' \
                        | grep -o '[^"]*$' | xargs wget -c
                        
                        if ls | grep '.jpeg'; then /usr/bin/convert -scale 48x40! *.jpeg img.png; fi
                        if ls | grep '.jpg'; then /usr/bin/convert -scale 48x40! *.jpg img.png; fi
                        mv -f img.png "$dir_content/$fname.png"
                        
                    else
                        cp -f /usr/share/idiomind/addons/Podcasts/images/audio.png "$dir_content/$fname.png"
                    fi

                elif [ $tp = vid ]; then
                    
                    mplayer -ss 60 -nosound -vo jpeg -frames 1 "media.$ex"
                    
                    if ls | grep '.jpeg'; then /usr/bin/convert -scale 48x40! *.jpeg img.png; fi
                    if ls | grep '.jpg'; then /usr/bin/convert -scale 48x40! *.jpg img.png; fi
                    
                    if [ -f img.png ]; then
                    
                        mv -f img.png "$dir_content/$fname.png"
                        
                    else
                        cp -f /usr/share/idiomind/addons/Podcasts/images/video.png "$dir_content/$fname.png"
                    fi
                fi
                rm -f *.jpeg *.jpg
                        


                #-------------------------------------------------
                mv -f "media.$ex" "$dir_content/$fname.$ex"
                printf "\n$summary" > "$dir_content/$fname.txt"
                echo "channel=\"$channel\"" > "$dir_content/$fname"
                echo "link=\"$link\"" >> "$dir_content/$fname"
                echo "title=\"$title\"" >> "$dir_content/$fname"
                echo "$title" >> "$dir_conf/cfg.1"
                echo "$title" >> "$dir_conf/.cfg.11"
                echo "source" >> $DT_r/log
            fi

        done <<< "$podcast_items"

    ((c=c+1))
    
    done < $TEMPRSSFILE
}

nps="$(cat "$RSSFILE" | wc -l)"
[ $nps -le 0 ] && msg "$(gettext " Missing URL\n Please check the settings\n in the preferences dialog.")" info && exit 1

echo "updating" > $DT/.uptp
if [ "$1" != A ]; then
echo "$tpc" > $DC_s/cfg.8
echo pd >> $DC_s/cfg.8
echo "14" > $dir_conf/cfg.8
(sleep 2 && notify-send -i idiomind "$(gettext "Checking for new downloads")" "$(gettext "Updating") $nps $(gettext "feeds...")" -t 6000) &
fi

nps=3
fetch_podcasts

[ -f $DT_r/log ] && dd="$(cat $DT_r/log | wc -l)" || dd=0
rm -fr $DT_r $DT/.uptp

if [ "$dd" -gt 0 ]; then
    n=20
    while [ $n -le $(cat $dir_conf/cfg.1 | tail -n+21 | wc -l) ]; do
        rm="$(sed -n "$n"p $dir_conf/cfg.1)"
        fname="$(nmfile "${rm^}")"
        rm "$dir_content/$fname.mp3"
        rm "$dir_content/$fname.txt"
        grep -vxF "$rm" "$dir_content/cfg.1" > \
        $DT/rm.tmp && sed '/^$/d' $DT/rm.tmp > \
        "$dir_content/cfg.1"
        let n++
    done

    check_index1 "$dir_conf/cfg.1" "$dir_conf/.cfg.11"
    sed -i '/^$/d' "$dir_conf/cfg.1"

    echo "$(date "+%a %d %B")" > $DM_tl/Podcasts/.dt
    notify-send -i idiomind \
    "$(gettext "Update finished")" "$(gettext "Downloaded") $dd $(gettext "episode(s)")" -t 6000
    exit
else
    notify-send -i idiomind \
    "$(gettext "No new episodes")" "$(gettext "Downloaded") $dd $(gettext "episode(s)")" -t 6000
    exit
fi

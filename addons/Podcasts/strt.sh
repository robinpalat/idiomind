#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
source $DS/ifs/mods/cmns.sh
include $DS/ifs/mods/add
DSF="$DS/addons/Podcasts"
DCF="$DC/addons/Podcasts"
DT_r=$(mktemp -d $DT/XXXXXX)

[ -f $DT/.uptp ] && STT=$(cat $DT/.uptp) || STT=""
[ ! -f $DC/addons/dict/.dicts ] && touch $DC/addons/dict/.dicts

if [[ -z "$(cat $DC_a/dict/.dicts)" ]]; then
    source $DS/ifs/trans/$lgs/topics_lists.conf
    $DS_a/Dics/cnfg.sh "" f "$(gettext "Dictionary list has not been set.")"
    if  [[ -z "$(cat $DC_a/dict/.dicts)" ]]; then
        exit 1
    fi
fi

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
    exit 1
    
elif ( [ -f $DT/.uptp ] && [ "$1" = A ] ); then
    exit 1
fi

sleep 1

RSSFILE="$DCF/$lgtl/link"
rsrc=$(cat "$DCF/$lgtl/.rss")
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
    mkdir $DM_tl/Podcasts/kept/.audio
    mkdir $DM_tl/Podcasts/kept/words
    mkdir "$DC_a/Podcasts"
    mkdir "$DC_a/Podcasts/$lgtl/rss"
    cp -f "$DSF/examples/$lgtl" "$DCF/rss/$lgtl"
fi
    
if ([ ! -f $DM_tl/Podcasts/tpc.sh ] || \
[ "$(cat $DM_tl/Podcasts/tpc.sh | wc -l)" -ge 15 ]); then

    echo '#!/bin/bash
source /usr/share/idiomind/ifs/c.conf
uid=$(sed -n 1p $DC_s/cfg.4)
FEED=$(cat "$DC/addons/Podcasts/$lgtl/.rss")
[ ! -f $DM_tl/Podcasts/.conf/cfg.8 ] && echo "11" > $DM_tl/Podcasts/.conf/cfg.8
[ ! -f $DM_tl/Podcasts/.conf/cfg.0 ] && touch $DM_tl/Podcasts/.conf/cfg.0
[ ! -f $DM_tl/Podcasts/.conf/cfg.1 ] && touch $DM_tl/Podcasts/.conf/cfg.1
[ ! -f $DM_tl/Podcasts/.conf/cfg.3 ] && touch $DM_tl/Podcasts/.conf/cfg.3
[ ! -f $DM_tl/Podcasts/.conf/cfg.4 ] && touch $DM_tl/Podcasts/.conf/cfg.4
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


fetch_podcasts() {

    c=1
    while read FEED; do
        
        [ -z "$FEED" ] && break
        PODCAST_ITEMS="$(xsltproc - "$FEED" <<< "$XSLT_STYLESHEET" 2> /dev/null)"
        PODCAST_ITEMS="$(echo "$PODCAST_ITEMS" | tr '\n' ' ' \
        | tr -s [:space:] | sed 's/EOL/\n/g' | head -n $n)"
        n_enc=$(cat "$DCF/$lgtl/$c.xml" | grep -Fxon "Enclosure" \
        | sed -n 's/^\([0-9]*\)[:].*/\1/p')
        n_tit=$(cat "$DCF/$lgtl/$c.xml" | grep -Fxon "Title" \
        | sed -n 's/^\([0-9]*\)[:].*/\1/p')
        n_sum=$(cat "$DCF/$lgtl/$c.xml" | grep -Fxon "Summary" \
        | sed -n 's/^\([0-9]*\)[:].*/\1/p')
        
        while read -r ITEM; do

            fields="$(echo "$ITEM" | tr -s '||' '\n')"
            enclosure=$(echo "$fields" | sed -n "$n_enc"p)
            title=$(echo "$fields" | sed -n "$n_tit"p | sed 's/\://g')
            summary=$(echo "$fields" | sed -n "$n_sum"p)
            
            if ! cat "$dir_conf/cfg.1" | grep -Fxo "$title"; then
            
                cd $DT_r; wget -q -c -T 30 -O "title.mp3" "$enclosure"
                source="$(eyeD3 --no-color "title.mp3" | grep -o -P '(?<=title:).*(?=artist:)' | sed -e 's/^[ \t]*//g' | tr -s '\ \t' | sed -e "s/[[:space:]]\+/ /g" | sed 's/^ *//; s/ *$//; /^$/d' | tr -s ':')"
                fname="$(nmfile "${title^}")"
                mv "title.mp3" "$dir_content/$fname.mp3"
                printf "\n$summary" > "$dir_content/$fname.txt"
                echo "$title" >> "$dir_conf/cfg.1"
                echo "source" >> $DT_r/log
            fi

        done <<< "$PODCAST_ITEMS"

    ((c=c+1))
    
    done < $TEMPRSSFILE
}

echo "updating" > $DT/.uptp
if [ "$1" != A ]; then
echo "$tpc" > $DC_s/cfg.8
echo pd >> $DC_s/cfg.8
echo "14" > $dir_conf/cfg.8
notify-send -i idiomind "$(gettext "Updating podcasts")" "$(gettext " ")" -t 3000 &
fi

n="$(cat "$RSSFILE" | wc -l)"
[ $n -le 0 ] && msg "$(gettext " Missing URLs\n Please check the settings\n in the preferences dialog.")" info && exit 1
n=$((10/$n))
fetch_podcasts
[ $DT_r/log ] && dd="$(cat $DT_r/log | wc -l)" || dd=0
rm -fr $DT_r $DT/.uptp $DT/.rss

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
    
check_index1 "$dir_conf/cfg.1"
echo "$(date "+%a %d %B")" > $DM_tl/Podcasts/.dt
[ "$1" != A ] && notify-send -i idiomind \
"$(gettext "Updated")" "$(gettext "Downloaded") $dd $(gettext "episode(s)")" -t 4000

exit

#!/bin/bash
# -*- ENCODING: UTF-8 -*-

#if [ -e "$DM_tl/.share/2.cfg" ]; then
    #sleep 20
    #echo -e "\n--- updating rss..."
    #if curl -v www.google.com 2>&1 | grep -m1 "HTTP/1.1" >/dev/null 2>&1; then
        #( while read -r item; do
            #if [ -e "$DM_tl/${item}/.conf/feeds" -a ! -e "$DM_tl/${item}/.conf/lk" ]; then
                #"$DS/add.sh" fetch_content "${item}"
            #fi
        #done < "$DM_tl/.share/2.cfg" ) &
    #fi
    #echo -e "--- rss updated\n"
#fi


if curl -v www.google.com 2>&1 | grep -m1 "HTTP/1.1" >/dev/null 2>&1; then
    DCP="$DM_tl/Feeds/.conf"
    if [ -f "$DCP/feeds.cfg" ]; then
        echo -e "\n--- updating feeds..."
        if [ "$(grep -o 'update="[^"]*' "$DCP/feeds.cfg" |grep -o '[^"]*$')" = TRUE ]; then
        ( sleep 1; "$DS_a/Feeds/feeds.sh" update 0 ) & fi
        echo -e "--- feeds updated\n"
    fi
fi

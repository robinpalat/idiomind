#!/bin/bash
# -*- ENCODING: UTF-8 -*-

( while read -r item; do
    if [ -e "$DM_tl/${item}/.conf/feeds" -a ! -e "$DM_tl/${item}/.conf/lk" ]; then
        "$DS/add.sh" fetch_content "${item}"
    fi
done < "$DM_tl/.2.cfg" ) &

#!/bin/bash
# -*- ENCODING: UTF-8 -*-

( while read -r item; do
    if [ -d "$DM_tl/${item}/.conf" -a ! -e "$DM_tl/${item}/.conf/lk" ]; then
        "$DS/add.sh" fetch_content "${item}"
    fi
done < "$DM_tl/.feeds" ) &

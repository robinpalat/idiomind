#!/bin/bash
# -*- ENCODING: UTF-8 -*-

if curl -v www.google.com 2>&1 | grep -m1 "HTTP/1.1" >/dev/null 2>&1; then
    ( while read -r item; do
        if [ -e "$DM_tl/${item}/.conf/feeds" -a ! -e "$DM_tl/${item}/.conf/lk" ]; then
            "$DS/add.sh" fetch_content "${item}"
        fi
    done < "$DM_tl/.2.cfg" ) &
fi

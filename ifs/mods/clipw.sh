#!/bin/bash
# -*- ENCODING: UTF-8 -*-

clip_watch() {
    
    echo $$ > /tmp/.clipw
    while [ 1 ]; do
        [ ! -f /tmp/.clipw ] && break
        xclip -i /dev/null
        t1="$(xclip -selection primary -o)"
        sleep 1
        t2="$(xclip -selection primary -o)"
        if [ "${t1}" != "${t2}" ] && [ -n "${t2}" ]; then
        "/usr/share/idiomind/add.sh" new_items " " 2 "${2}"
        fi
    done
    exit
}
clip_watch

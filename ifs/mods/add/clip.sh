#!/bin/bash
# -*- ENCODING: UTF-8 -*-

#[ -z "$DM" ] && source /usr/share/idiomind/ifs/c.conf

clip_watch() {
    
    echo $$ > "$DT/.clip"
    while [ 1 ]; do
    
        xclip -i /dev/null
        txt1="$(xclip -selection primary -o)"
        sleep 1
        txt2="$(xclip -selection primary -o)"
        if [ "$txt1" != "$txt2" ]; then
        dir=$(mktemp -d "$DT/XXXXXX")
        "$DS/add.sh" new_items "$dir" 2 "${2}"
        fi
    done
}


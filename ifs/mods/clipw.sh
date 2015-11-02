#!/bin/bash
# -*- ENCODING: UTF-8 -*-

id=$(xinput --list |grep -i -m 1 'mouse' |grep -o 'id=[0-9]\+' |grep -o '[0-9]\+')
echo $$ > /tmp/.clipw

_watch() {
    while [ 1 ]; do
        [ ! -f /tmp/.clipw ] && break
        xclip -i /dev/null
        sleep 0.5
        if [ -n "$(xclip -selection primary -o)" ]; then
            stt1=$(xinput --query-state $id |grep 'button\[' |sort)
            while true; do
                stt2=$(xinput --query-state $id |grep 'button\[' |sort)
                if grep 'up' <<<$(comm -13 <(echo "$stt1") <(echo "$stt2")); then break; fi
                sleep 0.2
                if grep 'down' <<<$(comm -13 <(echo "$stt1") <(echo "$stt2")); then break; fi
                done
            "/usr/share/idiomind/add.sh" new_items "" 2 "$(xclip -selection primary -o)"
        fi
    done
    exit 0
}
_watch

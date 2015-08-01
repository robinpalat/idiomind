#!/bin/bash

_fetch_img() {

    if [ ! -e "${DM_tls}/images/${trgt,,}-0.jpg" ]; then
    url="https://commons.wikimedia.org/wiki/$trgt"
    urimg="$(wget -q "$url" -O - |grep -o -P '//upload.*?jpg' |sed -e 's/\(thumb\/\)//g' |sed -e 's/^/http:/g' |head -n1)"
    wget -T 51 -q -U Mozilla -O "$DT/$trgt.jpg" "$urimg"
    
    if [ -e "$DT/$trgt.jpg" ]; then
        name_img="${DM_tls}/images/${trgt,,}-0.jpg"
        /usr/bin/convert "$DT/$trgt.jpg" -interlace Plane -thumbnail 405x275^ \
        -gravity center -extent 400x270 -quality 90% "${name_img}"
        rm -f "$DT/$trgt.jpg"
    fi
    fi
}

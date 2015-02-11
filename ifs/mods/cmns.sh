#!/bin/bash
# -*- ENCODING: UTF-8 -*-


function internet() {

	curl -v www.google.com 2>&1 \
	| grep -m1 "HTTP/1.1" >/dev/null 2>&1 || { 
	yad --window-icon=idiomind --on-top \
	--image=info --name=idiomind \
	--text=" $connection_err \\n " \
	--image-on-top --center --sticky \
	--width=360 --height=120 --borders=3 \
	--skip-taskbar --title=Idiomind \
	--button="  Ok  ":0 >&2; exit 1;}
}


function msg() {
	
        yad --window-icon=idiomind --name=idiomind \
        --image=$2 --on-top --text=" $1 " \
        --image-on-top --center --sticky --button=" Ok ":0 \
        --width=360 --height=120 --borders=5 \
        --skip-taskbar --title=Idiomind
}


function msg_2() { # decide
    
        yad --name=idiomind --on-top --text="$1" --image="$2" \
        --image-on-top --width=360 --height=120 --borders=3 \
        --skip-taskbar --window-icon=idiomind --sticky --center \
        --title=Idiomind --button="$4":1 --button="$3":0
}


function nmfile() {
	
	echo "$(echo -n "$1" | md5sum | rev | cut -c 4- | rev)"
}


function include() {
	
for f in $1/*; do source "$f"; done

}

#!/bin/bash

source /usr/share/idiomind/default/c.conf

arg="$1"
l1="$(gettext "To review (new):") "
l2="$(gettext "need review (new):") "
l3="$(gettext "Need to repass:") "
l4="$(gettext "Need to repass:") "
l5="$(gettext "To practice:") "
l6="$(gettext "Back to practice:") "
tpc="${arg#*: }"
act="${arg%%:*}"

chngtpc(){
	mode="$(< "$DM_tl/${1}/.conf/8.cfg")"
	"$DS/ifs/tpc.sh" "${1}" ${mode} ${2} &
}

modmenu() {
	grep -vxF "${1}" "$DT/tasks" > "$DT/tasks.tmp"
    sed '/^$/d' "$DT/tasks.tmp" > "$DT/tasks"
}

if [ "${act}" = "$l1" ]; then
	modmenu "$arg"; chngtpc "$tpc"
elif [ "${act}: " = "$l2" ]; then
	modmenu "$arg"; chngtpc "$tpc"
elif [ "${act}: " = "$l3" ]; then
	modmenu "$arg"; chngtpc "$tpc"
elif [ "${act}: " = "$l4" ]; then
	modmenu "$arg"; chngtpc "$tpc"
elif [ "${act}: " = "$l5" ]; then
	modmenu "$arg"; chngtpc "$tpc" 1 &
	"$DS/practice/strt.sh" &
elif [ "${act}: " = "$l6" ]; then
	modmenu "$arg"; chngtpc "$tpc" 1 &
	"$DS/practice/strt.sh" &
fi


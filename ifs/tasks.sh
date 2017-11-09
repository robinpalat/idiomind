#!/bin/bash

source /usr/share/idiomind/default/c.conf

arg="$1"
l1="$(gettext "To Repass (new):") "
l2="$(gettext "Priority to Repass (new):") "
l3="$(gettext "To Repass:") "
l4="$(gettext "Priority to Repass:") "
l5="$(gettext "Practice:") "
l6="$(gettext "Back to Practice:") "
tpc="${arg#*: }"
act="${arg%%:*}"

chngtpc(){
	mode="$(< "$DM_tl/${1}/.conf/8.cfg")"
	"$DS/ifs/tpc.sh" "${1}" ${mode} ${2}
}

modmenu() {
	grep -vxF "${1}" "$DT/tasks" > "$DT/tasks.tmp"
    sed '/^$/d' "$DT/tasks.tmp" > "$DT/tasks"
    cleanups "$DT/tasks.tmp"
    c1=$(cat "$DT/tasks" |wc -l)
    [[ ${c1} = 0 ]] && > "$DT/tasks"
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
	modmenu "$arg"; chngtpc "$tpc" 1
	"$DS/practice/strt.sh" &
elif [ "${act}: " = "$l6" ]; then
	modmenu "$arg"; chngtpc "$tpc" 1
	"$DS/practice/strt.sh" &
fi


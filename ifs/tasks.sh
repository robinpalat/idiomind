#!/bin/bash

source /usr/share/idiomind/default/c.conf

arg="$1"
l1="$(gettext "To Repass (new):") "
l2="$(gettext "Priority to Repass (new):") "
l3="$(gettext "To Repass:") "
l4="$(gettext "Priority to Repass:") "
l5="$(gettext "Practice:") "
l6="$(gettext "Back to Practice:") "
tpt="${arg#*: }"
act="${arg%%:*}"

chngtpt(){
	mode="$(< "$DM_tl/${1}/.conf/8.cfg")"
	"$DS/ifs/tpt.sh" "${1}" ${mode} ${2}
}

modmenu() {
	grep -vxF "${1}" "$DT/tasks" > "$DT/tasks.tmp"
    sed '/^$/d' "$DT/tasks.tmp" > "$DT/tasks"
    cleanups "$DT/tasks.tmp"
    c1=$(cat "$DT/tasks" |wc -l)
    [[ ${c1} = 0 ]] && > "$DT/tasks"
}

if [ "${act}" = "$l1" ]; then
	modmenu "$arg"; chngtpt "$tpt"
elif [ "${act}: " = "$l2" ]; then
	modmenu "$arg"; chngtpt "$tpt"
elif [ "${act}: " = "$l3" ]; then
	modmenu "$arg"; chngtpt "$tpt"
elif [ "${act}: " = "$l4" ]; then
	modmenu "$arg"; chngtpt "$tpt"
elif [ "${act}: " = "$l5" ]; then
	modmenu "$arg"; chngtpt "$tpt" 1
	"$DS/practice/strt.sh" &
elif [ "${act}: " = "$l6" ]; then
	modmenu "$arg"; chngtpt "$tpt" 1
	"$DS/practice/strt.sh" &
else
	a="$(echo "$tpt" |grep -oP '(?<=\[).*(?=\])')"
	if [ -f "$DS/addons/$a/cnfg.sh" ]; then
		"$DS/addons/$a/cnfg.sh" tasks "$tpt" &
		modmenu "$arg"
	fi
fi


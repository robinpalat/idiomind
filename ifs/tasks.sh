#!/bin/bash

source /usr/share/idiomind/default/c.conf
arg="$1"
l1="$(gettext "To Review (new):") "
l2="$(gettext "To Review (overdue) (new):") "
l3="$(gettext "To Review:") "
l4="$(gettext "To Review (overdue):") "
l5="$(gettext "Practice:") "
l6="$(gettext "Back to Practice:") "
l7="$(gettext "Finalize Review (overdue):") "
tpt="${arg#*: }"
act="${arg%%:*}"

chngtpt(){
	mode="$(< "$DM_tl/${1}/.conf/8.cfg")"
	"$DS/ifs/tpc.sh" "${1}" ${mode} ${2}
}

modmenu() {
	grep -vxF "${1}" "$DT/tasks" > "$DT/tasks.tmp"
    sed '/^$/d' "$DT/tasks.tmp" > "$DT/tasks"
    [ -f "$DT/tasks.tmp" ] && rm "$DT/tasks.tmp"
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
elif [ "${act}: " = "$l7" ]; then
	modmenu "$arg"; chngtpt "$tpt"
elif [ "${act}: " = "$l5" ]; then
	modmenu "$arg"; chngtpt "$tpt" 1
	"$DS/practice/strt.sh" &
elif [ "${act}: " = "$l6" ]; then
	modmenu "$arg"; chngtpt "$tpt" 1
	"$DS/practice/strt.sh" &
else
	while read -r addon; do
		if [ -e "$DC_a/$addon.tasks" ]; then
			if grep -o "$arg" "$DC_a/$addon.tasks"; then
				"$DS/addons/$addon/cnfg.sh" tasks "$tpt" &
				modmenu "$arg"
				break
			fi
		fi
	done < "$DS_a/menu_list"
fi


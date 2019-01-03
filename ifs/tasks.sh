#!/bin/bash

arg="$1"
tpt="$(sed -e 's/^ *//' -e 's/ *$//' <<< ${arg#*:})"
act="$(sed -e 's/^ *//' -e 's/ *$//' <<< ${arg%%:*})"

l1="$(gettext "To Review [New]:") "
l2="$(gettext "To Review [New] [Overdue]:") "
l3="$(gettext "To Review:") "
l4="$(gettext "To Review [Overdue]:") "
l5="$(gettext "To Practice:") "
l6="$(gettext "Back to Practice:") "
l7="$(gettext "Finalize Review [Overdue]:") "
l8="$(gettext "Resume Practice:") "

chngtpt(){
    mode="$(< "$DM_tl/${1}/.conf/stts")"
    "$DS/ifs/tpc.sh" "${1}" ${mode} ${2}
}

modmenu() {
    grep -vxF "${1}" "$DT/tasks" > "$DT/tasks.tmp"
    sed '/^$/d' "$DT/tasks.tmp" > "$DT/tasks"
    [ -f "$DT/tasks.tmp" ] && rm "$DT/tasks.tmp"
    c1=$(cat "$DT/tasks" |wc -l); if [[ ${c1} = 0 ]]; then
    rm -f "$DT/tasks"; echo "$tpc" > "$DC_s/tpc"; fi
}

if [ "${act}: " = "$l1" ]; then
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
    modmenu "$arg"
    "$DS/practice/strt.sh" "$tpt" &
elif [ "${act}: " = "$l6" ]; then
    modmenu "$arg"
    "$DS/practice/strt.sh" "$tpt" &
elif [ "${act}: " = "$l8" ]; then
    modmenu "$arg"
    "$DS/practice/strt.sh" "$tpt" &

else
    while read -r addon; do
        if [ -f "$DC_a/$addon.$tlng" ]; then
            if grep -o "$arg" "$DC_a/$addon.$tlng"; then
                "$DS/addons/$addon/cnfg.sh" tasks "$tpt" &
                modmenu "$arg"
                break
            fi
        fi
    done < "$DS_a/menu_list"
fi

exit 0

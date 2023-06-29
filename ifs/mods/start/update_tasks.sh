#!/bin/bash
# -*- ENCODING: UTF-8 -*-

# 0 Play and Practice (tpc)| tpc.sh
# 1 To review (new) | main.sh
# 2 Need review (new) | main.sh
# 3 To review | main.sh
# 4 Need review | main.sh
# 5 To practice | update_lists.sh
# 6 Back to practice | update_lists.sh
# 8 Resume Practice | strt.sh

source /usr/share/idiomind/default/c.conf
source "$DS/ifs/cmns.sh"
echo -e "\n--- updating tasks..."
l1="[!] $(gettext "To Review:") "
l2="[!] $(gettext "To Review:") "
l3="[!] $(gettext "To Review:") "
l4="[!] $(gettext "To Review:") "
l5="$(gettext "To Practice:") "
l6="$(gettext "Back to Practice:") "
l4="[!] $(gettext "To Review:") "
l8="$(gettext "Resume Practice:") "
f="$DT/tasks.tmp"; cleanups "$f" "$DT/tasks"

#current topic
if [ -n "${tpc}" ]; then
	if [[ -z "$(sqlite3 ${shrdb} "select list from T10 where list is '${tpc}';")" ]]; then
		export -f tpc_db
		if [ "$(tpc_db 5 learning | wc -l)" -gt 0 ];then
			echo -e "$(gettext "Play"): $tpc" >> "$f"
			echo -e "$(gettext "To Practice:") $tpc" >> "$f"
		fi
	fi
fi

## topics 
while read -r tpc_in_list; do
    [ -n "${tpc_in_list}" ] && echo -e "$l1$tpc_in_list" >> "$f"
done < <(cdb "${shrdb}" 5 T1 |tac)

## practice
while read -r tpc_in_list; do
    if [ -n "${tpc_in_list}" ] && [ "${tpc_in_list}" != "${tpc}" ]; then
    echo -e "$l8$tpc_in_list" >> "$f"; fi
done < <(cdb "${shrdb}" 5 T8 |tac)
while read -r tpc_in_list; do
    if [ -n "${tpc_in_list}" ] && [ "${tpc_in_list}" != "${tpc}" ]; then
    echo -e "$l6$tpc_in_list" >> "$f"; fi
done < <(cdb "${shrdb}" 5 T6 |tac)
while read -r tpc_in_list; do
    if [ -n "${tpc_in_list}" ] && [ "${tpc_in_list}" != "${tpc}" ]; then
    echo -e "$l5$tpc_in_list" >> "$f"; fi
done < <(cdb "${shrdb}" 5 T5 |tac)

## topics 
while read -r tpc_in_list; do
    if [ -n "${tpc_in_list}" ]; then
    echo -e "$l2$tpc_in_list" >> "$f"; fi
done < <(cdb "${shrdb}" 5 T2 |tac)
while read -r tpc_in_list; do
    if [ -n "${tpc_in_list}" ] && [ "${tpc_in_list}" != "${tpc}" ]; then
     echo -e "$l3$tpc_in_list" >> "$f"; fi
done < <(cdb "${shrdb}" 5 T3 |tac)
while read -r tpc_in_list; do
    if [ -n "${tpc_in_list}" ] && [ "${tpc_in_list}" != "${tpc}" ]; then
    echo -e "$l4$tpc_in_list" >> "$f"; fi
done < <(cdb "${shrdb}" 5 T4 |tac)

while read -r tpc_in_list; do
    if [ -n "${tpc_in_list}" ] && [ "${tpc_in_list}" != "${tpc}" ]; then
    echo -e "$l7$tpc_in_list" >> "$f"; fi
done < <(cdb "${shrdb}" 5 T7 |tac)


## addons
while read -r addon; do
    if [ -e "$DC_a/$addon${tlng}_tsk" ]; then
        tac "$DC_a/$addon${tlng}_tsk" >> "$f"
    fi
done < "$DS_a/menu_list"

if [ -f $DT/tasks_init ]; then  
echo "$(gettext "Getting started with Idiomind")" > "$f"
cleanups $DT/tasks_init
fi

[ -f "$f" ] && mv -f "$f" "$DT/tasks"

echo -e "\ttasks ok\n"

exit 0

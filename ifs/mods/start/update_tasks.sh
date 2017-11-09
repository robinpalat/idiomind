#!/bin/bash
# -*- ENCODING: UTF-8 -*-

# 1 To review (new) | main.sh
# 2 need review (new) | main.sh
# 3 To review | main.sh
# 4 need review | main.sh
# 5 to practice | update_lists.sh
# 6 back to practice | update_lists.sh

[ -z "$DM" ] && source /usr/share/idiomind/default/c.conf
source "$DS/ifs/cmns.sh"
echo -e "\n------------- updating tasks..."
l1="$(gettext "To Repass (new):") "
l2="$(gettext "Priority to Repass (new):") "
l3="$(gettext "To Repass:") "
l4="$(gettext "Priority to Repass:") "
l5="$(gettext "Practice:") "
l6="$(gettext "Back to Practice:") "
f="$DT/tasks"; cleanups "$f"

while read -r addon; do
	if [ -e "$DC_a/$addon.tasks" ]; then
		cat "$DC_a/$addon.tasks" >> "$f"
	fi
done < "$DS_a/menu_list"

if [ -e "$DM_tls/5.cfg" ]; then
	while read -r line; do
		tpc="$(cut -d '|' -f1 <<< "${line}")"
		cdg="$(cut -d '|' -f2 <<< "${line}")"
		if [ $cdg = 5 ]; then
			echo "$l5$tpc" >> "$f"
		elif [ $cdg = 6 ]; then
			echo "$l6$tpc" >> "$f"
		fi
	done < "$DM_tls/5.cfg"
fi

if [ -e "$DM_tls/4.cfg" ]; then
	while read -r line; do
		tpc="$(cut -d '|' -f1 <<< "${line}")"
		cdg="$(cut -d '|' -f2 <<< "${line}")"
		if [ $cdg = 2 ]; then
			echo "$l2$tpc" >> "$f"
		elif [ $cdg = 4 ]; then
			echo "$l4$tpc" >> "$f"
		fi
	done < "$DM_tls/4.cfg"
fi

if [ -e "$DM_tls/3.cfg" ]; then
	while read -r line; do
		tpc="$(cut -d '|' -f1 <<< "${line}")"
		cdg="$(cut -d '|' -f2 <<< "${line}")"
		if [ $cdg = 1 ]; then
			echo "$l1$tpc" >> "$f"
		elif [ $cdg = 3 ]; then
			echo "$l3$tpc" >> "$f"
		fi
	done < "$DM_tls/3.cfg"
fi

echo -e "------------- tasks updated\n"
exit

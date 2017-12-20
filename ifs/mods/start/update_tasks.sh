#!/bin/bash
# -*- ENCODING: UTF-8 -*-

# 1 To review (new) | main.sh
# 2 need review (new) | main.sh
# 3 To review | main.sh
# 4 need review | main.sh
# 5 to practice | update_lists.sh
# 6 back to practice | update_lists.sh

source /usr/share/idiomind/default/c.conf
source "$DS/ifs/cmns.sh"
echo -e "\n--- updating tasks..."
l1="$(gettext "To Review [new]:") "
l2="$(gettext "To Review [new] [overdue]:") "
l3="$(gettext "To Review:") "
l4="$(gettext "To Review [overdue]:") "
l5="$(gettext "Practice:") "
l6="$(gettext "Back to Practice:") "
l7="$(gettext "Finalize Review [overdue]:") "
f="$DT/tasks"; cleanups "$f"

## topics 
while read -r tpc; do
    echo "$l1$tpc" >> "$f"
done < <(cdb "${shrdb}" 5 T1 |tac)
while read -r tpc; do
    echo "$l2$tpc" >> "$f"
done < <(cdb "${shrdb}" 5 T2 |tac)
while read -r tpc; do
    echo "$l3$tpc" >> "$f"
done < <(cdb "${shrdb}" 5 T3 |tac)
while read -r tpc; do
    echo "$l4$tpc" >> "$f"
done < <(cdb "${shrdb}" 5 T4 |tac)
while read -r tpc; do
    echo "$l5$tpc" >> "$f"
done < <(cdb "${shrdb}" 5 T5 |tac)
while read -r tpc; do
    echo "$l6$tpc" >> "$f"
done < <(cdb "${shrdb}" 5 T6 |tac)
while read -r tpc; do
    echo "$l7$tpc" >> "$f"
done < <(cdb "${shrdb}" 5 T7 |tac)

## addons 
while read -r addon; do
    if [ -e "$DC_a/$addon.tasks" ]; then
        tac "$DC_a/$addon.tasks" >> "$f"
    fi
done < "$DS_a/menu_list"

echo -e "--- tasks updated\n"
exit

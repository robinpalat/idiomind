#!/bin/bash
# -*- ENCODING: UTF-8 -*-

# 1 To review (new) | main.sh
# 2 Need review (new) | main.sh
# 3 To review | main.sh
# 4 Need review | main.sh
# 5 To practice | update_lists.sh
# 6 Back to practice | update_lists.sh
# 8 Resume Practice | strt.sh

source /usr/share/idiomind/default/c.conf
source "$DS/ifs/cmns.sh"
echo -e "\n--- tasks..."
l1="$(gettext "To Review [new]:") "
l2="$(gettext "To Review [new] [overdue]:") "
l3="$(gettext "To Review:") "
l4="$(gettext "To Review [overdue]:") "
l5="$(gettext "To Practice:") "
l6="$(gettext "Back to Practice:") "
l7="$(gettext "Finalize Review [overdue]:") "
l8="$(gettext "Resume Practice:") "
f="$DT/tasks.tmp"; cleanups "$f" "$DT/tasks"

## topics 
while read -r tpc; do
    echo -e "$l1$tpc" >> "$f"
done < <(cdb "${shrdb}" 5 T1 |tac)

## practice
while read -r tpc; do
    echo -e "$l8$tpc" >> "$f"
done < <(cdb "${shrdb}" 5 T8 |tac)
while read -r tpc; do
    echo -e "$l6$tpc" >> "$f"
done < <(cdb "${shrdb}" 5 T6 |tac)
while read -r tpc; do
    echo -e "$l5$tpc" >> "$f"
done < <(cdb "${shrdb}" 5 T5 |tac)

## topics 
while read -r tpc; do
    echo -e "$l2$tpc" >> "$f"
done < <(cdb "${shrdb}" 5 T2 |tac)
while read -r tpc; do
    echo -e "$l3$tpc" >> "$f"
done < <(cdb "${shrdb}" 5 T3 |tac)
while read -r tpc; do
    echo -e "$l4$tpc" >> "$f"
done < <(cdb "${shrdb}" 5 T4 |tac)

while read -r tpc; do
    echo -e "$l7$tpc" >> "$f"
done < <(cdb "${shrdb}" 5 T7 |tac)


## addons
while read -r addon; do
    if [ -e "$DC_a/$addon.$tlng" ]; then
        tac "$DC_a/$addon.$tlng" >> "$f"
    fi
done < "$DS_a/menu_list"

mv -f "$f" "$DT/tasks"

echo -e "--- tasks updated\n"

exit 0

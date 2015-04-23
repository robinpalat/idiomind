#!/bin/bash
# -*- ENCODING: UTF-8 -*-

[ -z "$DM" ] && source /usr/share/idiomind/ifs/c.conf
sizes() {
for i in "$DS/addons/"* ; do
dir=`basename "$i"`
if [ -d "$DM_tl/$dir" ]; then
du="$(du -b -h "$DM_tl/$dir" | tail -1 | awk '{print ($1)}')"
echo -e "$dir: $du\n"
fi
done
}
others=`sizes`
du=`du -b -h "$DM" | tail -1 | awk '{print ($1)}'`
if [ ! -f "$DC_a/user_data.cfg" ]; then
echo -e "backup=\"FALSE\"
path=\"$HOME\"
size=\"0\"
others=\" \"" > "$DC_a/user_data.cfg"
fi
sed -i "3s/size=.*/size=\"$du\"/" "$DC_a/user_data.cfg"
sed -i "4s/others=.*/others=\"$others\"/" "$DC_a/user_data.cfg"

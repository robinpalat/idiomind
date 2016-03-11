#!/bin/bash
# -*- ENCODING: UTF-8 -*-

du=$(du -b -h "$DM" |tail -1 |awk '{print ($1)}')
if [ ! -e "$DC_a/user_data.cfg" ]; then
    echo -e "backup=\"FALSE\"
    path=\"$HOME\"
    size=\"0\"
    others=\" \"" > "$DC_a/user_data.cfg"
fi
sed -i "3s/size=.*/size=\"$du\"/" "$DC_a/user_data.cfg"

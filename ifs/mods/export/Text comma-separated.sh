#!/bin/bash

source /usr/share/idiomind/default/c.conf
source "$DS/ifs/cmns.sh"
mkdir -p "$DT/export"
file="$DT/export/file.csv"

while read -r _item; do
    [ ! -d "$DT/export" ] && break
    unset trgt srce; get_item "${_item}"
    if [ -n "${trgt}" -a -n "${srce}" ]; then
        echo -e "\"$trgt\",\"$srce\"" >> "$DT/export/txt"
    fi
done < "${DC_tlt}/0.cfg"

if [ -e "$DT/export/txt" ]; then
    cat "$DT/export/txt" > "$file"
fi

[ -e "$file" ] && mv -f "$file" "${1}.csv"
cleanups "$DT/export"





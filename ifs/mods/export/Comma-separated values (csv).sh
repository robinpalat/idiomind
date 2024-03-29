#!/bin/bash

source /usr/share/idiomind/default/c.conf
source "$DS/ifs/cmns.sh"
mkdir -p "$DT/export"
file="$DT/export/file.csv"

while read -r _item; do
    [ ! -d "$DT/export" ] && break
    unset trgt srce; get_item "${_item}"
    trgt="$(tr -s '"' '*' <<< "${trgt}")"
    srce="$(tr -s '"' '*' <<< "${srce}")"
    if [ -n "${trgt}" -a -n "${srce}" ]; then
        echo -e "\"$trgt\",\"$srce\"" >> "$DT/export/txt"
    fi
done < "${DC_tlt}/data"

sed -i 's/\*/\\"/g' "$DT/export/txt"
if [ -f "$DT/export/txt" ]; then
    cat "$DT/export/txt" > "$file"
fi

[ -f "$file" ] && mv -f "$file" "${1}.csv"
cleanups "$DT/export"





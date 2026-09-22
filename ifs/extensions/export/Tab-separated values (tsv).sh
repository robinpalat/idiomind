#!/bin/bash

source /usr/share/idiomind/default/c.conf
source "$DS/ifs/cmns.sh"
mkdir -p "$DT/export"
file="$DT/export/file.tsv"

while read -r _item; do
    [ ! -d "$DT/export" ] && break
    unset trgt srce; get_item "${_item}"
    if [ -n "${trgt}" -a -n "${srce}" ]; then
        printf "%5s\t%s\n" "${trgt}" "${srce}" >> "$DT/export/txt"
    fi
done < "${DC_tlt}/data"

if [ -e "$DT/export/txt" ]; then
    cat "$DT/export/txt" > "$file"
fi

[ -e "$file" ] && mv -f "$file" "${1}.tsv"
cleanups "$DT/export"

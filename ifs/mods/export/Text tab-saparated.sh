#!/bin/bash

source /usr/share/idiomind/default/c.conf
source "$DS/ifs/mods/cmns.sh"

mkdir -p "$DT/export"
file="$DT/export/file.csv"
while read -r _item; do
    if [ ! -d "$DT/export" ]; then break & exit 1; fi
    unset trgt srce expl
    get_item "${_item}"
    
    if [ -n "$trgt" -a -n "$srce" ]; then
        printf "%5s\t%s\n" "$trgt" "$srce" >> "$DT/export/txt"
    fi

done < <(tac "${DC_tlt}/0.cfg")
if [ -e "$DT/export/txt" ]; then
    cat "$DT/export/txt" > "$file"
else
    msg "$(gettext "Words not found in the topic.")\n" error "$(gettext "Information")"
fi
mv -f "$file" "${1}.txt"
cleanups "$DT/export"

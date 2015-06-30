#!/bin/bash
# -*- ENCODING: UTF-8 -*-
exit 1
[ -z "$DM" ] && source /usr/share/idiomind/ifs/c.conf
source "$DS/ifs/mods/cmns.sh"

update() {
    
    oname=$(grep -o oname=\"[^\"]* "$DM_tl/${1}/.conf/id.cfg" |grep -o '[^"]*$')
    langs=$(grep -o langs=\"[^\"]* "$DM_tl/${1}/.conf/id.cfg" |grep -o '[^"]*$')
    langt=$(grep -o langt=\"[^\"]* "$DM_tl/${1}/.conf/id.cfg" |grep -o '[^"]*$')
    ctgry=$(grep -o ctgry=\"[^\"]* "$DM_tl/${1}/.conf/id.cfg" |grep -o '[^"]*$')
    ilink=$(grep -o ilink=\"[^\"]* "$DM_tl/${1}/.conf/id.cfg" |grep -o '[^"]*$')
    set_2=$(grep -o set_2=\"[^\"]* "$DM_tl/${1}/.conf/id.cfg" |grep -o '[^"]*$')
    mdsum=$(grep -o mdsum=\"[^\"]* "$DM_tl/${1}/.conf/id.cfg" |grep -o '[^"]*$')
    lgs=$(lnglss $langs)
    test="http://55.2fh.co/$lgs/${langt,,}/$ctgry/$ilink.$oname.idmnd"
    smod=`grep -o 'md5sum="[^"]*' <<<"$(curl "$test")" |grep -o '[^"]*$'`

    if [ -n "$smod" -a "$smod" != "$mdsum" ]; then
    while read -r item; do
    items="$(sed 's/},/}\n/g' <<<"${item}")"
    id="$(grep -oP '(?<=id=\[).*(?=\])' <<<"${items}")"
    if [ -n "$id" ]; then
    if ! grep -o "${id}" "$DM_tl/${1}/.conf/0.cfg"; then
    echo "${item}" >> "$DM_tl/${1}/.conf/updt.lst"; fi; fi
    done < <(curl "${test}")
    fi
    

    if [ ${set_2} = 1 ]; then
    
    echo
    
    elif [ ${set_2} = 2 ]; then
    
    cat "$DM_tl/${1}/.conf/updt.lst" >> "$DM_tl/${1}/.conf/0.cfg"
    
    fi

} >/dev/null 2>&1


while read tpc_u; do

    set_2=$(grep -o set_2=\"[^\"]* "$DM_tl/${tpc_u}/.conf/id.cfg" |grep -o '[^"]*$')
    if [[ ${set_2} != 0 ]]; then update "${tpc_u}"; fi

done < "$DM_tl/.3.cfg"


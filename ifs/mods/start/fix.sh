#!/bin/bash

# ----------------------------
if [ -e "$DC_a/dict/.dict" ]; then

    if [[ `sed -n 2p "$DC_a/dict/.dict"` != $v_dicts ]]; then
    for re in "$DS_a/Dics/dicts"/*; do
    if [ ! -f "$DC_a/dict/enables/$(basename "${re}")" -a \
    ! -f "$DC_a/dict/disables/$(basename "${re}")" ]; then
    >  "$DC_a/dict/disables/$(basename "${re}")"; fi
    done
    echo -e "$lgtl\n$v_dicts" > "$DC_a/dict/.dict"; fi
fi

# ----------------------------
if grep -o 'rplay' "$DC_s/1.cfg"; then rm "$DC_s/1.cfg"; fi

# ----------------------------
if [ ! -d "${DM_tls}/images" ]; then mkdir -p "${DM_tls}/images"; fi

# ----------------------------
DCP="$DM_tl/Podcasts/.conf"
if [ -d "$DM_tl/Podcasts/.conf" ]; then

    if [[ "$(< "$DCP/8.cfg")" != 11 ]]; then
    echo 11 > "$DCP/8.cfg"; fi
    
    if [ -e "$DCP/podcasts.cfg" ]; then
    if ! grep -o 'svepi' "$DCP/podcasts.cfg" >/dev/null 2>&1; then
    rm "$DCP/podcasts.cfg"; fi
    fi
fi

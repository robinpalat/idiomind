#!/bin/bash


"$DS_a/Resources/cnfg.sh" updt_scripts

if [ ! -d "$DM_tls" ]; then
    mkdir -p "$DM_tls/audio"
    mkdir -p "$DM_tls/images"
    mkdir -p "$DM_tls/data"
fi

if [ ! -d "$DC" ]; then
    mkdir -p "$DC/addons"
fi

if [ -f "$DC_s/1.cfg" ]; then
    source "$DS/ifs/cmns.sh"
    for n in {1..10}; do cleanups "$DC_s/${n}.cfg"; done
    for n in {1..10}; do cleanups "$DM_tls/${n}.cfg"; done
fi

if [ ! -f "${cfg_db}" ]; then
    "$DS/ifs/tls.sh" create_cfg
fi


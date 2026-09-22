#!/bin/bash
# -*- ENCODING: UTF-8 -*-
# Export the current topic to the native Idiomind interchange format (.idmnd).
# $1 = destination path WITHOUT extension
# $2 = topic name
# $3 = include multimedia (1/empty)

source /usr/share/idiomind/default/c.conf
source "$DS/ifs/cmns.sh"
[ -z "$3" ] && media=0 || media="$3"

tpc="${2}"
dest="${1}"

mkdir -p "$DT/export"
DT_e="$DT/export"
pkd="$DT_e/${tpc}.pkd"
mkdir -p "$pkd"
idmnd="$pkd/topic.idmnd"

get_item() {
    export item="$(sed 's/}/}\n/g' <<< "${1}")"
    export type="$(grep -oP '(?<=type{).*(?=})' <<< "${item}")" \
    trgt="$(grep -oP '(?<=trgt{).*(?=})' <<< "${item}")" \
    srce="$(grep -oP '(?<=srce{).*(?=})' <<< "${item}")" \
    exmp="$(grep -oP '(?<=exmp{).*(?=})' <<< "${item}")" \
    defn="$(grep -oP '(?<=defn{).*(?=})' <<< "${item}")" \
    note="$(grep -oP '(?<=note{).*(?=})' <<< "${item}")" \
    wrds="$(grep -oP '(?<=wrds{).*(?=})' <<< "${item}")" \
    grmr="$(grep -oP '(?<=grmr{).*(?=})' <<< "${item}")" \
    mark="$(grep -oP '(?<=mark{).*(?=})' <<< "${item}")" \
    link="$(grep -oP '(?<=link{).*(?=})' <<< "${item}")" \
    tags="$(grep -oP '(?<=tags{).*(?=})' <<< "${item}")" \
    refr="$(grep -oP '(?<=refr{).*(?=})' <<< "${item}")" \
    cdid="$(grep -oP '(?<=cdid{).*(?=})' <<< "${item}")"
}

export autr="$(tpc_db 1 id autr)"
export ctgy="$(tpc_db 1 id ctgy)"
export levl="$(tpc_db 1 id levl)"
export dtec="$(tpc_db 1 id dtec)"
export dtei="$(tpc_db 1 id dtei)"
export dteu="$(date +%F)"
export nwrd="$(tpc_db 1 id nwrd)"
export nsnt="$(tpc_db 1 id nsnt)"
export slng="$(tpc_db 1 id slng)"
export tlng="$(tpc_db 1 id tlng)"
export naud="$(tpc_db 1 id naud)"
export nimg="$(tpc_db 1 id nimg)"
export nsze="$(tpc_db 1 id nsze)"
export cntt="$(tpc_db 1 id cntt)"
export stts="$(tpc_db 1 id stts)"
export autr; [ -z "$autr" ] && autr=""
export nsze; [ -z "$nsze" ] && nsze=0
[ -z "$stts" ] && stts=0

# Calculate counters from data file if database values are empty
if [ -z "$nwrd" ] || [ -z "$nsnt" ]; then
    _data_file="${DC_tlt}/data"
    if [ -f "$_data_file" ]; then
        _nwrd=$(grep -c 'type{1}' "$_data_file" 2>/dev/null)
        _nsnt=$(grep -c 'type{2}' "$_data_file" 2>/dev/null)
        [ -z "$nwrd" ] && [ "$_nwrd" -gt 0 ] 2>/dev/null && nwrd="$_nwrd"
        [ -z "$nsnt" ] && [ "$_nsnt" -gt 0 ] 2>/dev/null && nsnt="$_nsnt"
    fi
fi
# Count images and audio from items in data file
if [ -z "$nimg" ] || [ "$nimg" = "0" ] || [ -z "$naud" ] || [ "$naud" = "0" ]; then
    _data_file="${DC_tlt}/data"
    if [ -f "$_data_file" ]; then
        _nimg=0
        _naud=0
        while read -r _item; do
            get_item "${_item}"
            if [ -n "$trgt" ] && [ "$type" = 1 ]; then
                # Check topic images
                if [ -f "$DM_tlt/images/${trgt,,}.jpg" ]; then
                    _nimg=$(( _nimg + 1 ))
                elif [ -f "$DM_tls/images/${trgt,,}-1.jpg" ]; then
                    _nimg=$(( _nimg + 1 ))
                fi
                # Check topic audio
                if [ -n "$cdid" ] && [ -f "$DM_tlt/${cdid}.mp3" ]; then
                    _naud=$(( _naud + 1 ))
                elif [ -f "$DM_tls/audio/${trgt,,}.mp3" ]; then
                    _naud=$(( _naud + 1 ))
                fi
            fi
        done < <(sed 's|"|\\"|g' < "$_data_file")
        [ -z "$nimg" ] && [ "$_nimg" -gt 0 ] 2>/dev/null && nimg="$_nimg"
        [ -z "$naud" ] && [ "$_naud" -gt 0 ] 2>/dev/null && naud="$_naud"
    fi
fi

export nwrd; [ -z "$nwrd" ] && nwrd=0
export nsnt; [ -z "$nsnt" ] && nsnt=0
export naud; [ -z "$naud" ] && naud=0
export nimg; [ -z "$nimg" ] && nimg=0
# Validate levl (Skill Level): must be 0, 1, or 2
if ! [[ "$levl" =~ ^[0-9]$ ]] || [ "$levl" -gt 2 ] 2>/dev/null; then
    levl=0
fi
# ctgy lowercase for export
ctgy="${ctgy,,}"

export note="$(sed '/^$/d' "$DC_tlt/note.md" 2>/dev/null \
|sed ':a;N;$!ba;s/\n/<br><br>/g;s/\&/&amp;/g' \
|sed 's|\"|\\"|g;s|\/|\\/|g')"
export info="$note"

rand=$(md5sum "$DC_tlt/data" |cut -d' ' -f1)
export ilnk="$(tpc_db 1 id ilnk)"
if [ -z "$ilnk" ]; then
    pre=$(sed "s/ /_/g;s/'//g" <<< "${tpc:0:15}" |iconv -c -f utf8 -t ascii)
    export ilnk="${pre,,}${rand:0:20}"
fi

### convert items to json format
echo -e "{\"items\":{" > "${idmnd}"
while read -r _item; do
    get_item "${_item}"; unset ipath
    if [ -n "$trgt" ] && [ "$type" = 1 ]; then
        ipath=""
        if [ -f "$DM_tlt/images/${trgt,,}.jpg" ]; then
            ipath="$DM_tlt/images/${trgt,,}.jpg"; export imag=2
        elif [ -f "$DM_tls/images/${trgt,,}-1.jpg" ]; then
            ipath="$DM_tls/images/${trgt,,}-1.jpg"; export imag=1
        fi
        export imgr="${trgt,}"
    else
        export imag=0
        imgr=""
    fi
    eval item="$(sed -n 1p "$DS/default/vars")"
    [ -n "${trgt}" ] && echo -en "${item}" >> "${idmnd}"
    unset imgr
done < <(sed 's|"|\\"|g' < "${DC_tlt}/data")

### package multimedia inside the portable package
if [ "$media" = 1 ]; then
    mkdir -p "$pkd/images/topic" \
        "$pkd/images/shared" \
        "$pkd/audio/topic" \
        "$pkd/audio/shared"

    ### images referenced by items
    while read -r _item; do
        get_item "${_item}"

        if [ -n "$trgt" ] && [ "$type" = 1 ]; then

            # Topic image
            # Installed source:
            #   $DM_tlt/images/<word>.jpg
            #
            # IDMND package:
            #   images/topic/<word>.jpg
            if [ -f "$DM_tlt/images/${trgt,,}.jpg" ]; then
                cp -f \
                    "$DM_tlt/images/${trgt,,}.jpg" \
                    "$pkd/images/topic/${trgt,,}.jpg"

            # Shared image
            # Installed shared repository:
            #   $DM_tls/images/<word>-1.jpg
            #
            # IDMND package:
            #   images/shared/<word>.jpg
            elif [ -f "$DM_tls/images/${trgt,,}-1.jpg" ]; then
                cp -f \
                    "$DM_tls/images/${trgt,,}-1.jpg" \
                    "$pkd/images/shared/${trgt,,}.jpg"
            fi
        fi
    done < "$DC_tlt/data"

    ### per-item topic audio
    while read -r _item; do
        get_item "${_item}"

        if [ -n "$trgt" ]; then

            # Topic audio
            # IDMND package:
            #   audio/topic/<cdid>.mp3
            if [ -n "$cdid" ] && [ -f "$DM_tlt/${cdid}.mp3" ]; then
                cp -f \
                    "$DM_tlt/${cdid}.mp3" \
                    "$pkd/audio/topic/${cdid}.mp3"

            # Shared audio
            # IDMND package:
            #   audio/shared/<word>.mp3
            elif [ -f "$DM_tls/audio/${trgt,,}.mp3" ]; then
                cp -f \
                    "$DM_tls/audio/${trgt,,}.mp3" \
                    "$pkd/audio/shared/${trgt,,}.mp3"
            fi
        fi
    done < "$DC_tlt/data"
fi

### calculate resource size (images + audio)
_nsz=""
if [ -d "$pkd/images" ] || [ -d "$pkd/audio" ]; then
    _nsz=$(du -csh "$pkd"/images/* "$pkd"/audio/* 2>/dev/null \
        | tail -n1 | awk '{print $1}')
fi
[ -n "$_nsz" ] && nsze="$_nsz"

### set head info
sed -i 's/,$//' "${idmnd}"
echo "}," >> "${idmnd}"
cd "$DT_e"
eval head="$(sed -n 3p "$DS/default/vars")"
echo -e "${head}}" >> "${idmnd}"

### create the portable single-file package (a ZIP with .idmnd extension)
rm -f "$dest".idmnd
cd "$pkd"
zip -qr "$dest.idmnd" .

cleanups "$pkd" "$DT_e"
exit 0

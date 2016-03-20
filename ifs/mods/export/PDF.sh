#!/bin/bash

source /usr/share/idiomind/default/c.conf
source "$DS/ifs/cmns.sh"

_head(){
    cat <<!EOF
<head><meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="stylesheet" href="/usr/share/idiomind/default/pdf.css">
</head><body><h2>$tpc</h2><hr><br>
!EOF
}

_note(){
    cat <<!EOF
<div align="left" border="0" class="block0">$note<br><br></div><br>
!EOF
}

sentence_normal() {
    cat <<!EOF
<table style="vertical-align:top" width="100%" align="left" cellpadding="0" cellspacing="0">
<td><s1>${trgt}</s1><br><s2>${srce}</s2><hr class="dashed"></td></table>
!EOF
}

word_image_normal(){
    cat <<!EOF
<table width="100%" align="center" cellpadding="10" cellspacing="10">
<tr align="center"><td style="width: 33%;vertical-align:top">${img1}<w0 align="left">${trgt1}</w0><br><w2>${srce1}</w2><br><br></td>
<td style="width: 33%;vertical-align:top">${img2}<w0 align="left">${trgt2}</w0><br><w2>${srce2}</w2><br><br></td>
<td style="width: 33%;vertical-align:top">${img}<w0 align="left">${trgt}</w0><br><w2>${srce}</w2><br><br></td></tr></table>
!EOF
}

word_example_normal(){
    [ -n "$img" ] && fw="$file.words0" || fw="$file.words1"
    if [ -n "${exmp}" ]; then
    exmp="$(sed "s|${trgt,}|<mark>${trgt,}<\/mark>|g" <<<"${exmp}")<br>"
    exmp="$(sed "s|${trgt^}|<mark>${trgt^}<\/mark>|g" <<<"${exmp}")<br>"
    fi
    [ -n "${defn}" ] && defn="${defn}<br>"
    [ -n "${note}" ] && note="${note}<br>"
    field="<w1>${trgt}</w1><br><texmp>${srce}</texmp>"
    field2="<texmp>${exmp}</texmp><defn>${defn}</defn><note>${note}</note>"
    echo -e "<table class=\"block1\" width=\"100%\" align=\"center\" cellpadding=\"0\" cellspacing=\"15\"><tr>" >> "$fw"
    [ -n "$img" ] && echo -e "<td style=\"vertical-align:top;align:left\">$img</td>" >> "$fw"
    echo -e "<td style=\"width: 20%;vertical-align:top; align:left\">$field</td>
    <td style=\"width: 70%;vertical-align:top;align:left\">$field2</td></tr></table>" >> "$fw"
}

mkhtml() {
    mkdir -p "$DT/export"
    imagesdir="${DM_tls}/images"
    file="$DT/export/temp.html"
    
    if [ $f -eq 2 ]; then
        while read -r word; do
            item="$(grep -F -m 1 "trgt={${word}}" "${DC_tlt}/0.cfg" |sed 's/},/}\n/g')"
            grep -oP '(?<=srce={).*(?=})' <<<"${item}" >> "$DT/export/b.srces"
        done < "${DC_tlt}/3.cfg"
    fi
    _head > "$file"
    note="$(sed ':a;N;$!ba;s/\n/<br>/g' < "${DC_tlt}/info" |sed 's/\&/&amp;/g')"
    [ -n "${note}" ] && _note >> "$file"
    
    tr=1; n=1
    while read -r _item; do
        if [ ! -d "$DT/export" ]; then break & exit 1; fi
        unset img trgt srce type
        if [ $f -eq 0 ]; then [[ ${tr} -gt 3 ]] && tr=1; fi
        if [ $f -eq 2 ]; then [[ ${tr} -gt 2 ]] && tr=1; fi
        get_item "${_item}"
        
        if [ -n "${trgt}" -a -n "${srce}" -a -n "${type}" ]; then
        
            fimg="${DM_tlt}/images/${trgt,,}.jpg"
            [ ! -e "$fimg" ] && fimg="$imagesdir/${trgt,,}-0.jpg"
            if [ -e "$fimg" ]; then
                img_small="<img class=\"simg\" src=\"$fimg\" width=100px></img><br>"
                img_large="<img class=\"simg\" src=\"$fimg\" width=150px></img><br>"
            else
                img_small=""; img_large=""
            fi
            
            if [ ${type} = 1 -a $f = 0 ]; then
                if [[ -n "${exmp}${defn}${note}" ]]; then
                    img="$img_small"
                    word_example_normal
                    let tr--

                elif [[ -z "${exmp}${defn}${note}" ]]; then
                    if [ ${tr} = 1 ]; then
                        trgt1="${trgt}"; srce1="${srce}"; img1="${img_large}"
                    elif [ ${tr} = 2 ]; then
                        trgt2="${trgt}"; srce2="${srce}"; img2="${img_large}"
                    elif [ ${tr} = 3 ]; then
                        img="${img_large}"
                        word_image_normal >> "$file.words2"
                    fi
                fi
            elif [ ${type} = 2 -a $f = 0 ]; then
                sentence_normal >> "$file.sente"
                let tr--
            
            elif [ ${type} = 1 -a $f = 2 ]; then
                [[ ${n} -gt 12 ]] && n=1
                ras="$(sort -Ru "$DT/export/b.srces" |egrep -v "${srce}" |head -n5)"
                while read -r m; do
                    declare item$n="${m}"
                    let n++
                done < <(echo -e "${ras}\n${srce}" |sort -Ru |sed '/^$/d')
                
                if [ ${tr} = 1 ]; then
                    trgt1="${trgt}"
                    
                elif [ ${tr} = 2 ]; then
                    word_examen >> "$file.words2"
                fi
            elif [ ${type} = 2 -a $f = 2 ]; then
                let tr--
            fi
        elif [ ${tr} = 2 ]; then
            echo -e "</td></table>" >> "$file.words2"
        fi
        let tr++
    done < "${DC_tlt}/0.cfg"
    
    echo -e "$(< "$file.words2")" >> "$file"
    echo -e "<br><br>" >> "$file"
    echo -e "$(< "$file.words0")" >> "$file"
    echo -e "$(< "$file.words1")" >> "$file"
    echo -e "<br><br>" >> "$file"
    echo -e "$(< "$file.sente")" >> "$file"
    echo -e "</body></html>" >> "$file"
}

[ -z "${f}" ] && f=0
export f; mkhtml
wkhtmltopdf -s A4 -O Portrait "$file" "$DT/export/tmp.pdf"
mv -f "$DT/export/tmp.pdf" "${1}.pdf"
chmod 664 "${1}.pdf"
cleanups "$DT/export"

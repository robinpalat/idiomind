#!/bin/bash

_head(){
    cat <<!EOF
<head><meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="stylesheet" href="/usr/share/idiomind/default/pdf.css">
</head><body><h3>$tpc</h3><hr><br>
!EOF
}

_checkbox="<img src=\"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABYAAAAWCAYAAADEtGw7AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH3woDEzoH0hTl5gAAABl0RVh0Q29tbWVudABDcmVhdGVkIHdpdGggR0lNUFeBDhcAAAA2SURBVDjL7dVBEQAwDAJB6FQh0RmNiYdO+XEC9nuUNDB0AaC7+ROtqjkwFThw4MCBA79F10wX13oIF8HVFq4AAAAASUVORK5CYII=\"/>"

_note(){
    note="$(sed ':a;N;$!ba;s/\n/<br>/g' < "${DC_tlt}/info" |sed 's/\&/&amp;/g')"
    cat <<!EOF
<div width="60%" align="left" border="0" class="ifont"><br>$note<p>&nbsp;</div><br>
!EOF
}

word_examen() {
    cat <<!EOF
<table width="100%" cellpadding="0" cellspacing="10"><tr>
<td width="50%"><tw1>${trgt1}</tw1></td><td width="50%"><tw1>${trgt}</tw1></td></tr><tr><td><table><tr>
<td><exmp>$_checkbox ${item1}</exmp></td><td><exmp>$_checkbox ${item2}</exmp></td>
<td><exmp>$_checkbox ${item3}</exmp></td></tr><tr>
<td><exmp>$_checkbox ${item4}</exmp></td><td><exmp>$_checkbox ${item5}</exmp></td>
<td><exmp>$_checkbox ${item6}</exmp></td></tr></table></td><td><table><tr>
<td><exmp>$_checkbox ${item7}</exmp></td><td><exmp>$_checkbox ${item8}</exmp></td>
<td><exmp>$_checkbox ${item9}</exmp></td></tr><tr>
<td><exmp>$_checkbox ${item10}</exmp></td><td><exmp>$_checkbox ${item11}</exmp></td>
<td><exmp>$_checkbox ${item12}</exmp></td></tr></table></td></tr></table>
!EOF
}

sentence_normal() {
    cat <<!EOF
<table width="90%" align="left" cellpadding="0" cellspacing="15">
<tr><td style="width: 50%; vertical-align:top; align:$algn"><s1>${trgt}</s1></td>
<td style="width:  50%; vertical-align:top; align:$algn"><s2>${srce}</s2></td></tr></table>
!EOF
}

word_image_normal(){
    cat <<!EOF
<table width="100%" align="center" cellpadding="10" cellspacing="10">
<tr><td style="width: 33%; vertical-align:top; align:$algn">${img1}<w1>${trgt1}</w1><br><w2>${srce1}</w2><br><br></td>
<td style="width: 33%; vertical-align:top; align:$algn">${img2}<w1>${trgt2}</w1><br><w2>${srce2}</w2><br><br></td>
<td style="width: 33%; vertical-align:top; align:$algn">${img}<w1>${trgt}</w1><br><w2>${srce}</w2><br><br></td></tr></table>
!EOF
}

word_example_examen(){
    hint="$(echo "${trgt,,}" |sed "s|[a-z]|"\ \ _"|g")"
    [ -n "${exmp}" ] && exmp="$(sed "s|${trgt,}|<b> ${hint} <\/b>|g" <<<"${exmp}")<br><br>"
    echo -e "<table width=\"80%\" align=\"left\" cellpadding=\"0\" cellspacing=\"5\"><tr>" >> "$file.words1"
    [ -n "$img" ] && echo -e "<td style=\"vertical-align:top; align:left\">$img</td>" >> "$file.words1"
    echo -e "<td width=\"70%\"><texmp>${exmp}</texmp></td></table>" >> "$file.words1"
}

word_example_normal(){
    [ -n "$img" ] && fw="$file.words0" || fw="$file.words1"
    [ -n "${exmp}" ] && exmp="$(sed "s|${trgt,}|<mark>${trgt,}<\/mark>|g" <<<"${exmp}")<br><br>"
    [ -n "${defn}" ] && defn="${defn}<br><br>"
    [ -n "${note}" ] && note="${note}<br><br>"
    field="<w1>${trgt}</w1><br><w2>${srce}</w2>"
    field2="<texmp>${exmp}</texmp><defn>${defn}</defn><note>${note}</note>"
    echo -e "<table width=\"100%\" align=\"center\" cellpadding=\"0\" cellspacing=\"15\"><tr>" >> "$fw"
    [ -n "$img" ] && echo -e "<td style=\"vertical-align:top; align:left\">$img<br><br></td>" >> "$fw"
    echo -e "<td style=\"width: 20%; vertical-align:top; align:left\">$field<br><br></td>
    <td style=\"width: 70%; vertical-align:middle\">$field2<br><br></td></tr></table>" >> "$fw"
}

mkhtml() {
    mkdir -p "$DT/mkhtml"
    imagesdir="${DM_tls}/images"
    file="$DT/mkhtml/temp.html"
    
    if [ $ret -eq 2 ]; then
        while read -r word; do
            item="$(grep -F -m 1 "trgt={${word}}" "${DC_tlt}/0.cfg" |sed 's/},/}\n/g')"
            grep -oP '(?<=srce={).*(?=})' <<<"${item}" >> "$DT/mkhtml/b.srces"
        done < "${DC_tlt}/3.cfg"
    fi
    _head > "$file"
    [ -n "${note}" ] && _note >> "$file"
    
    tr=1; n=1
    while read -r _item; do
        unset img trgt srce type
        [ $ret -eq 0 ] && [[ ${tr} -gt 3 ]] && tr=1
        [ $ret -eq 2 ] && [[ ${tr} -gt 2 ]] && tr=1
        get_item "${_item}"
        
        if [ -n "${trgt}" -a -n "${srce}" -a -n "${type}" ]; then
            fimg="$imagesdir/${trgt,,}-0.jpg"
            if [ -f "$fimg" ]; then
                img_small="<img src=\"$fimg\" border=0 width=100px></img><br>"
                img_large="<img src=\"$fimg\" border=0 width=150px></img><br>"
            else
                img_small=""; img_large=""
            fi
            
            if [ ${type} = 1 -a $ret = 0 ]; then
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
            elif [ ${type} = 2 -a $ret = 0 ]; then
                sentence_normal >> "$file.sente"
                let tr--

            elif [ ${type} = 1 -a $ret = 2 ]; then
                [[ ${n} -gt 12 ]] && n=1
                ras="$(sort -Ru "$DT/mkhtml/b.srces" |egrep -v "$srce" |head -n5)"
                while read -r m; do
                    declare item$n="${m}"
                    let n++
                done < <(echo -e "$ras\n$srce" |sort -Ru |sed '/^$/d')
                
                if [ ${tr} = 1 ]; then
                    trgt1="${trgt}"
                    
                elif [ ${tr} = 2 ]; then
                    word_examen >> "$file.words2"
                fi
            elif [ ${type} = 2 -a $ret = 2 ]; then
                let tr--
            fi
            if [ -n "${exmp}" -a $ret = 2 ]; then
                img="$img_small"
                word_example_examen
            fi
        elif [ ${tr} = 2 ]; then
            echo -e "</td></table>" >> "$file.words2"
        fi
        let tr++
    done < <(tac "${DC_tlt}/0.cfg")
    
    echo -e "$(< "$file.words2")" >> "$file"
    echo -e "<br><br><br>" >> "$file"
    echo -e "$(< "$file.words0")" >> "$file"
    echo -e "$(< "$file.words1")" >> "$file"
    echo -e "<br><br><br>" >> "$file"
    echo -e "$(< "$file.sente")" >> "$file"
    echo -e "</body></html>" >> "$file"
}

cd "$HOME"
fileout=$(yad --file \
--save --title="$(gettext "Save as PDF")" \
--name=Idiomind --class=Idiomind \
--filename="$HOME/$tpc.pdf" \
--window-icon="$DS/images/icon.png" --center --on-top \
--width=600 --height=500 --borders=5 \
--button="$(gettext "Cancel")":1 \
--button="$(gettext "Test Mode")":2 \
--button="$(gettext "Save")":0)
ret=$?

if [ $ret -eq 0 -o $ret -eq 2 ]; then
    source "$DS/ifs/mods/cmns.sh"
    mkhtml
    wkhtmltopdf -s A4 -O Portrait "$file" "$DT/mkhtml/tmp.pdf"
    mv -f "$DT/mkhtml/tmp.pdf" "${fileout}"
    cleanups "$DT/mkhtml"
    exit 0
fi


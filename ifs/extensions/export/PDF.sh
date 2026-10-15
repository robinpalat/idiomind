#!/bin/bash

source /usr/share/idiomind/default/c.conf
source "$DS/ifs/cmns.sh"

export s0="<img src=\"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAB5QAAAeUBKFD6vwAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAABTSURBVFiF7c6hDYBADEDRf+QE6yAIm7EEYSkcwbDNySKYgJRg+M9Utf0gSZKkvysA+3E2iD55a5nGYX661CWfphlggAEG1HvEClEzh4KyvRH0uQvFHQppbRgchwAAAABJRU5ErkJggg==\"/>"

_head(){
    cat <<!EOF
<head><meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<style>
body {
    width: 85%;
    height: 85%;
    margin-top: 50;
    margin-bottom: 10;
    margin-right: auto;
    margin-left: auto;
    font-family: Helvetica, Verdana, Geneva;
}

w0 {
    color: #5B5F62;
    font-size: 20px;
    font-weight: bold;
    line-height: 1.25;
}

w1 {
    display: block;
    color: #5D6164;
    font-size: 20px;
    font-weight: bold;
    line-height: 1.2;
    margin: 0 0 7px 0;
}

w2 {
    display: block;
    color: #52524E;
    font-size: 15px;
    font-style: normal;
    line-height: 1.35;
    margin-top: 4px;
}

s1 {
    color: #424242;
    font-size: 18px;
    font-weight: normal;
}

s2 {
    color: #7A7A7A;
    font-size: 17px;
    font-weight: normal;
    margin: 20px;
    line-height: 2.25;
}

s0 {
    background-color: #7089AA;
    margin: 10px;
    line-height: 2.25;
}

tw1 {
    margin-top: 0;
    padding-right: 0px;
    color: #5787B8;
    font-size: 15px;
    font-weight: bold;
    font-family: sans-serif, Verdana, Geneva;
}

h2 {
    margin-top: 10;
    padding-right: 0px;
    color: #616161;
    font-size: 20px;
    font-weight: bold;
}

mark {
    background-color: #F5F4F3;
    color: #5D6164;
    font-weight: bold;
}

exmp {
    color: #5E5A54;
    font-size: 16px;
    font-weight: italic;
    font-family: sans-serif, Verdana, Geneva;
    margin: 1px;
}

texmp {
    color: #5E5A54;
    font-size: 13.5px;
    font-weight: normal;
    line-height: 1.45;
}

defn {
    color:#5E5A54;
    font-size:13.5px;
    font-weight:normal;
    line-height:1.45;
}

note {
    color:#696968;
    font-size:13px;
    font-weight:normal;
    font-style:italic;
    line-height:1.45;
}

.simg {
    display: block;
    border-radius: 10px;
    -moz-border-radius: 10px;
    -webkit-border-radius: 10px;
    margin: 0 auto 7px auto;
}

.block0 {
    padding: 0px;
    color: #4C4C4C;
    font-size: 18px;
    line-height: 1.45;
}

.block1 {
    position: relative;
    padding: 10px 12px;
    margin: 15px 0 0.8em;
    color: #333;
    background: #F5F4F3;
    -webkit-border-radius: 15px;
    -moz-border-radius: 15px;
    border-radius: 15px;
}

.block1 {
    position: relative;
    padding: 5px 7px;
    margin: 10px 0 0.6em;
    color: #333;
    background: #F5F4F3;
    -webkit-border-radius: 12px;
    -moz-border-radius: 12px;
    border-radius: 12px;
}

.block2 {
    position: left;
    padding: 5px;
    background: #9A9A9A;
}

.block3 {
    position: left;
    padding: 5px;
    background: #DFDBD7;
}

.dashed {
    border: none;
    border-top: 1px solid #fff;
    color: #fff;
    background-color: #fff;
    height: 1px;
    width: 100%;
    line-height: 0.1em;
}

@page {
    size: A4 portrait;
    margin: 18mm 16mm 18mm 16mm;
}

.word-example {
    display: block;
    margin: 0;
    color: #5E5A54;
    font-size: 13.5px;
    font-weight: normal;
    font-style: italic;
    line-height: 1.45;
}

.word-definition {
    display: block;
    margin-top: 5px;
    color:#5E5A54;
    font-size:12px;
    font-weight:normal;
    line-height:1.45;
}

.word-note {
    display: block;
    margin-top: 5px;
    color:#696968;
    font-size:12px;
    font-weight:normal;
    font-style:italic;
    line-height:1.45;
}

.word-translation {
    display: block;
    margin: 0;
    color: #5E5A54;
    font-size: 15px;
    font-weight: normal;
    line-height: 1.35;
}
</style>
</head><body><h1>$tpc</h1><hr><br>
!EOF
}

_note(){
    cat <<!EOF
<div align="left" border="0" class="block0">$note<br><br></div>
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
<table width="100%" align="center" cellpadding="10" cellspacing="6">
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
    field="<w1>${trgt}</w1><span class="word-translation">${srce}</span>"
    field2="<span class="word-example">${exmp}</span><span class="word-definition">${defn}</span><span class="word-note">${note}</span>"
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
            item="$(grep -F -m 1 "trgt{${word}}" "${DC_tlt}/data" |sed 's/}/}\n/g')"
            grep -oP '(?<=srce{).*(?=})' <<< "${item}" >> "$DT/export/b.srces"
        done < "${DC_tlt}/3.cfg"
    fi
    _head > "$file"
    note="$(sed '/^$/d' "${DC_tlt}/note" |sed ':a;N;$!ba;s/\n/<br>/g;s/\&/&amp;/g')"
    [ -n "${note}" ] && _note >> "$file" || echo "<br>" >> "$file"
    
    itr=1; n=1
    while read -r _item; do
        if [ ! -d "$DT/export" ]; then break & exit 1; fi
        unset img trgt srce type
        if [ $f -eq 0 ]; then [[ ${itr} -gt 3 ]] && itr=1; fi
        if [ $f -eq 2 ]; then [[ ${itr} -gt 2 ]] && itr=1; fi
        get_item "${_item}"
        
        if [ -n "${trgt}" -a -n "${srce}" -a -n "${type}" ]; then
        
            fimg="${DM_tlt}/images/${trgt,,}.jpg"
            [ ! -f "$fimg" ] && fimg="$imagesdir/${trgt,,}-1.jpg"

            img_small=""; img_large=""
            if [ -f "$fimg" ]; then
                fimg="$(sed -s 's/\?/%3F/;s/\:/%3A/;s/\;/%3B/g' <<< "$fimg")"
                img_small="<img class=\"simg\" src=\"$fimg\" width=100px></img><br>"
                img_large="<img class=\"simg\" src=\"$fimg\" width=150px></img><br>"
            fi
            
            if [ ${type} = 1 -a $f = 0 ]; then
                if [[ -n "${exmp}${defn}${note}" ]]; then
                    img="$img_small"
                    word_example_normal
                    let itr--

                elif [[ -z "${exmp}${defn}${note}" ]]; then
                    if [ ${itr} = 1 ]; then
                        trgt1="${trgt}"; srce1="${srce}"; img1="${img_large}"
                    elif [ ${itr} = 2 ]; then
                        trgt2="${trgt}"; srce2="${srce}"; img2="${img_large}"
                    elif [ ${itr} = 3 ]; then
                        img="${img_large}"
                        word_image_normal >> "$file.words2"
                    fi
                fi
            elif [ ${type} = 2 -a $f = 0 ]; then
                sentence_normal >> "$file.sente"
                let itr--
            
            elif [ ${type} = 1 -a $f = 2 ]; then
                [[ ${n} -gt 12 ]] && n=1
                ras="$(sort -Ru "$DT/export/b.srces" |egrep -v "${srce}" |head -n5)"
                while read -r m; do
                    declare item$n="${m}"
                    let n++
                done < <(echo -e "${ras}\n${srce}" |sort -Ru |sed '/^$/d')
                
                if [ ${itr} = 1 ]; then
                    trgt1="${trgt}"
                    
                elif [ ${itr} = 2 ]; then
                    word_examen >> "$file.words2"
                fi
            elif [ ${type} = 2 -a $f = 2 ]; then
                let itr--
            fi
        elif [ ${itr} = 2 ]; then
            echo -e "</td></table>" >> "$file.words2"
        fi
        let itr++
    done < "${DC_tlt}/data"
    
    echo -e "$(< "$file.words2")\n<br>" >> "$file"
    echo -e "$(< "$file.words0")" >> "$file"
    echo -e "$(< "$file.words1")\n<br><br>" >> "$file"
    echo -e "$(< "$file.sente")</body></html>" >> "$file"
}

[ -z "${f}" ] && f=0
export f; mkhtml

weasyprint \
    --presentational-hints \
    "$file" \
    "$DT/export/tmp.pdf"

if [ $f = 2 ]; then
    mv -f "$DT/export/tmp.pdf" "${1} - Test.pdf"
else
    mv -f "$DT/export/tmp.pdf" "${1}.pdf"
fi

cleanups "$DT/export"

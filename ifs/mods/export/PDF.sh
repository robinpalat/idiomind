#!/bin/bash

img_check="<img src=\"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABYAAAAWCAYAAADEtGw7AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH3woDEzoH0hTl5gAAABl0RVh0Q29tbWVudABDcmVhdGVkIHdpdGggR0lNUFeBDhcAAAA2SURBVDjL7dVBEQAwDAJB6FQh0RmNiYdO+XEC9nuUNDB0AaC7+ROtqjkwFThw4MCBA79F10wX13oIF8HVFq4AAAAASUVORK5CYII=\"/>"

mkpdf() {
    source "$DS/ifs/mods/cmns.sh"
    cd "$HOME"; fileout=$(yad --file \
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
        cleanups "$DT/mkhtml"
        mkdir -p "$DT/mkhtml"
        file="$DT/mkhtml/temp.html"
        note="$(sed ':a;N;$!ba;s/\n/<br>/g' < "${DC_tlt}/info" |sed 's/\&/&amp;/g')"
        nts="<div width=\"60%\" align=\"left\" border=\"0\" class=\"ifont\"><br>$note<p>&nbsp;</p></div><br>"
        if [ $ret -eq 2 ]; then
            while read word; do
                    item="$(grep -F -m 1 "trgt={${word}}" "${DC_tlt}/0.cfg" |sed 's/},/}\n/g')"
                    echo "$(grep -oP '(?<=srce={).*(?=})' <<<"${item}")" >> "$DT/mkhtml/b.srces"
            done < "${DC_tlt}/3.cfg"
        fi
        echo -e "<head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />
        <title>$tpc</title>
        <link rel=\"stylesheet\" href=\"/usr/share/idiomind/default/pdf.css\">
        </head>" >> "$file"
        echo -e "<body><p></p><h3>$tpc</h3><hr><p>" >> "$file"
        [ -n "${note}" ] && echo -e "${nts}" >> "$file"
        tr=1; n=1
        while read -r _item; do
            unset img trgt srce type
            [ $ret -eq 0 ] && [ ${tr} -gt 3 ] && tr=1
            [ $ret -eq 2 ] && [ ${tr} -gt 2 ] && tr=1

            get_item "${_item}"

            if [ -n "${trgt}" -a -n "${srce}" -a -n "${type}" ]; then
                if [ -f "${DM_tls}/images/${trgt,,}-0.jpg" ]; then
                    img="<img src=\"${DM_tls}/images/${trgt,,}-0.jpg\" border=0 width=150px></img><br>"
                else
                    img=""
                fi
                if [ ${type} = 1 -a $ret = 0 ]; then
                    if [ -n "${exmp}" -o -n "${defn}" -o -n "${note}" ]; then
                        [ -n "$img" ] && fw="$file.words0" || fw="$file.words1"
                        [ -n "${exmp}" ] && exmp="$(sed "s|${trgt,}|<mark>${trgt,}<\/mark>|g" <<<"${exmp}")<br><br>"
                        [ -n "${defn}" ] && defn="${defn}<br><br>"
                        [ -n "${note}" ] && note="${note}<br><br>"
                        field="<w1>${trgt}</w1><br><w2>${srce}</w2>"
                        field2="<exmp>${exmp}</exmp><defn>${defn}</defn><note>${note}</note>"
                        echo -e "<table width=\"100%\" align=\"center\" cellpadding=\"0\" cellspacing=\"15\"><tr>" >> "$fw"
                        [ -n "$img" ] && echo -e "<td style=\"vertical-align:top; align:left\">$img<br><br></td>" >> "$fw"
                        echo -e "<td style=\"width: 20%; vertical-align:top; align:left\">$field<br><br></td>" >> "$fw"
                        echo -e "<td style=\"width: 70%; vertical-align:bottom; align:$algn\">$field2<br><br></td></tr></table>" >> "$fw"
                        tr=$((tr-1))
                    elif [ -z "${exmp}" -a -z "${defn}" -a -z "${note}" ]; then
                        field="<w1>${trgt}</w1><br><w2>${srce}</w2>"
                        field2="<exmp>${exmp}<br></exmp><defn>${defn}<br></defn><note>${note}<br></note>"
                        if [ ${tr} = 1 ]; then
                            echo -e "<table width=\"100%\" align=\"center\" cellpadding=\"10\" cellspacing=\"10\">" >> "$file.words2"
                            echo -e "<tr><td style=\"width: 33%; vertical-align:top; align:$algn\">${img}$field<br><br></td>" >> "$file.words2"
                        elif [ ${tr} = 2 ]; then
                            echo -e "<td style=\"width: 33%; vertical-align:top; align:$algn\">${img}$field<br><br></td>" >> "$file.words2"
                        elif [ ${tr} = 3 ]; then
                            echo -e "<td style=\"width: 33%; vertical-align:top; align:$algn\">${img}$field<br><br></td></tr></table>" >> "$file.words2"
                        fi
                    fi
                elif [ ${type} = 2 -a $ret = 0 ]; then
                    algn=left
                    echo -e "<table width=\"90%\" align=\"left\" cellpadding=\"0\" cellspacing=\"15\">" >> "$file.sente"
                    echo -e "<tr><td style=\"width: 50%; vertical-align:top; align:$algn\"><s1>${trgt}</s1></td>" >> "$file.sente"
                    echo -e "<td style=\"width:  50%; vertical-align:top; align:$algn\"><s2>${srce}</s2></td></tr></table>" >> "$file.sente"
                    tr=$((tr-1))

                elif [ ${type} = 1 -a $ret = 2 ]; then
                    [[ ${n} -gt 12 ]] && n=1
                    ras=$(sort -Ru "$DT/mkhtml/b.srces" |egrep -v "$srce" |head -n5)
                    for i in $(echo -e "$ras\n$srce" |sort -Ru |sed '/^$/d'); do
                        declare item$n=$i
                        let n++
                    done
                    if [ ${tr} = 1 ]; then
                        export trgt1="${trgt}"
                    elif [ ${tr} = 2 ]; then
                        echo -e "<table width=\"100%\" cellpadding=\"10\" cellspacing=\"10\"><tr>
                        <td width=\"50%\"><tw1>${trgt1}</tw1></td><td width=\"50%\"><tw1>${trgt}</tw1></td></tr><tr><td><table><tr>
                        <td><exmp>$img_check ${item1}</exmp></td><td><exmp>$img_check ${item2}</exmp></td>
                        <td><exmp>$img_check ${item3}</exmp></td></tr><tr>
                        <td><exmp>$img_check ${item4}</exmp></td><td><exmp>$img_check ${item5}</exmp></td>
                        <td><exmp>$img_check ${item6}</exmp></td></tr></table></td><td><table><tr>
                        <td><exmp>$img_check ${item7}</exmp></td><td><exmp>$img_check ${item8}</exmp></td>
                        <td><exmp>$img_check ${item9}</exmp></td></tr><tr>
                        <td><exmp>$img_check ${item10}</exmp></td><td><exmp>$img_check ${item11}</exmp></td>
                        <td><exmp>$img_check ${item12}</exmp></td></tr></table></td></tr></table>" >> "$file.words2"
                        unset trgt1
                    fi
                fi
                if [ -n "${exmp}" -a $ret = 2 ]; then
                    hint="$(echo "${trgt,,}" |sed "s|[a-z]|"\ \ _"|g")"
                    [ -n "${exmp}" ] && exmp="$(sed "s|${trgt,}|<b> ${hint} <\/b>|g" <<<"${exmp}")<br><br>"
                    echo -e "<table width=\"80%\" align=\"left\" cellpadding=\"0\" cellspacing=\"5\"><tr>" >> "$file.words1"
                    [ -n "$img" ] && echo -e "<td style=\"vertical-align:top; align:left\">$img</td>" >> "$file.words1"
                    echo -e "<td width=\"70%\"><texmp>${exmp}</texmp></td></table>" >> "$file.words1"
                fi

            elif [ ${tr} = 3 ]; then
                echo -e "</td></table>" >> "$file.words2"
            fi
            tr=$((tr+1))
        
        done < <(tac "${DC_tlt}/0.cfg")
        
        echo -e "$(< "$file.words2")" >> "$file"
        echo -e "<br><br><br>" >> "$file"
        echo -e "$(< "$file.words0")" >> "$file"
        echo -e "$(< "$file.words1")" >> "$file"
        echo -e "<br><br><br>" >> "$file"
        echo -e "$(< "$file.sente")" >> "$file"
        echo -e "</body></html>" >> "$file"
        wkhtmltopdf -s A4 -O Portrait "$file" "$DT/mkhtml/tmp.pdf"
        mv -f "$DT/mkhtml/tmp.pdf" "${fileout}"
        cleanups "$DT/mkhtml"
    fi
    exit 0
}

mkpdf

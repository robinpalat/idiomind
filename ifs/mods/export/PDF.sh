#!/bin/bash

mkpdf() {
    source "$DS/ifs/mods/cmns.sh"
    cd "$HOME"
    pdf=$(yad --file --save --title="$(gettext "Export to PDF")" \
    --name=Idiomind --class=Idiomind \
    --filename="$HOME/$tpc.pdf" \
    --window-icon="$DS/images/icon.png" --center --on-top \
    --width=600 --height=500 --borders=5 \
    --button="$(gettext "Cancel")":1 \
    --button="$(gettext "OK")":0)
    ret=$?

    if [ $ret -eq 0 ]; then
        [ -d "$DT/mkhtml" ] && rm -fr "$DT/mkhtml"
        mkdir -p "$DT/mkhtml/images"; wdir="$DT/mkhtml"
        cfg0="${DC_tlt}/0.cfg"
        cfg3="${DC_tlt}/3.cfg"
        cfg4="${DC_tlt}/4.cfg"
        cntwords=`wc -l < "$cfg3"`
        nts="$(sed ':a;N;$!ba;s/\n/<br>/g' < "${DC_tlt}/info" \
        | sed 's/\&/&amp;/g')"
        if [ -f "${DM_tlt}/images/img.jpg" ]; then
        convert "${DM_tlt}/images/img.jpg" \
        -alpha set -channel A -evaluate set 50% "$wdir/img.png"; fi
        while read -r word; do
            if [ -f "${DM_tls}/images/${word,,}-0.jpg" ]; then
                convert "${DM_tls}/images/${word,,}-0.jpg" -alpha set -virtual-pixel transparent \
                -channel A -blur 0x10 -level 70%,100% +channel "$wdir/images/$word.png"
                echo "${word}" >> "$wdir/image_list"
            fi
        done < <(tac "${cfg3}")
        while read -r sntcs; do
            item="$(grep -F -m 1 "trgt={${sntcs}}" "${cfg0}" |sed 's/},/}\n/g')"
            trgt="$(grep -oP '(?<=trgt={).*(?=})' <<<"${item}")"
            srce="$(grep -oP '(?<=srce={).*(?=})' <<<"${item}")"
            if [ -n "${trgt}" -a -n "${srce}" ]; then
                echo "${trgt}" >> "$wdir/trgt_sentences"
                echo "${srce}" >> "$wdir/srce_sentences"
            fi
        done < <(tac "${cfg4}")
        
        echo -e "<head>
        <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />
        <title>$tpc</title><head>
        <link rel=\"stylesheet\" href=\"/usr/share/idiomind/default/pdf.css\">
        </head><body><div><p></p></div><div>" >> "$wdir/temp.html"
        
        if [ -f "$wdir/img.png" ]; then
            echo -e "<table width=\"100%\" border=\"0\"><tr>
            <td><img src=\"$wdir/img.png\" alt="" border=0 height=100% width=100%></img>
            </td>
            </tr>
            </table>" >> "$wdir/temp.html"; fi
        echo -e "<p>&nbsp;</p>
        <h3>$tpc</h3>
        <hr>
        <div width=\"80%\" align=\"left\" border=\"0\" class=\"ifont\">
        <br>" >> "$wdir/temp.html"
        printf "$nts" >> "$wdir/temp.html"
        echo -e "<p>&nbsp;</p>
        <div>" >> "$wdir/temp.html"

        cnt=`wc -l < "$wdir/image_list"`
        if [[ ${cnt} -gt 0 ]]; then
            cd "$wdir"
            echo -e "<p>&nbsp;</p><table width=\"100%\" align=\"center\" border=\"0\" class=\"images\">" >> "$wdir/temp.html"
            n=1
            while [[ ${n} -lt $(($(wc -l < "$wdir/image_list")+1)) ]]; do
                    label1=$(sed -n ${n},$((n+1))p "$wdir/image_list" |sed -n 1p)
                    label2=$(sed -n ${n},$((n+1))p "$wdir/image_list" |sed -n 2p)
                    if [ -n "${label1}" ]; then
                        echo -e "<tr>
                        <td align=\"center\"><img src=\"images/$label1.png\" width=\"200\" height=\"140\"></td>" >> "$wdir/temp.html"
                        if [ -n "${label2}" ]; then
                            echo -e "<td align=\"center\"><img src=\"images/$label2.png\" width=\"200\" height=\"140\"></td></tr>" >> "$wdir/temp.html"
                        else
                            echo '</tr>' >> "$wdir/temp.html"
                        fi
                        echo -e "<tr>
                        <td align=\"center\" valign=\"top\"><p>${label1}</p>
                        <p>&nbsp;</p>
                        <p>&nbsp;</p>
                        <p>&nbsp;</p></td>" >> "$wdir/temp.html"
                        if [ -n "${label2}" ]; then
                            echo -e "<td align=\"center\" valign=\"top\"><p>${label2}</p>
                            <p>&nbsp;</p>
                            <p>&nbsp;</p>
                            <p>&nbsp;</p></td>
                            </tr>" >> "$wdir/temp.html"
                        else
                        echo '</tr>' >> "$wdir/temp.html"
                        fi
                    else
                        break
                    fi
                ((n=n+2))
            done
            echo -e "</table>" >> "$wdir/temp.html"
        fi
        cd "$wdir"
        while read -r word; do
            item="$(grep -F -m 1 "trgt={${word}}" "${cfg0}" |sed 's/},/}\n/g')"
            trgt="$(grep -oP '(?<=trgt={).*(?=})' <<<"${item}")"
            srce="$(grep -oP '(?<=srce={).*(?=})' <<<"${item}")"
            exmp="$(grep -oP '(?<=exmp={).*(?=})' <<<"${item}")"
            defn="$(grep -oP '(?<=defn={).*(?=})' <<<"${item}")"
            ntes="$(grep -oP '(?<=note={).*(?=})' <<<"${item}")"
            fname="$(grep -oP '(?<=id=\[).*(?=\])' <<<"${item}")"
            hlgt="${trgt,,}"
            exmp1=$(echo "${exmp}" |sed "s/"$hlgt"/<b>"$hlgt"<\/\b>/g")
            
            if [ -n "${trgt}" -a -n "${srce}" ]; then
                echo -e "<table width=\"55%\" border=\"0\" align=\"left\" cellpadding=\"6\" cellspacing=\"0\">
                <tr>
                <td bgcolor=\"#E6E6E6\" class=\"side\"></td>
                <td bgcolor=\"#FFFFFF\"><w1>${trgt}</w1></td>
                </tr><tr>
                <td bgcolor=\"#FFFFFF\" class=\"side\"></td>
                <td bgcolor=\"#FFFFFF\"><w2>${srce}</w2></td>
                </tr>
                </table>" >> "$wdir/temp.html"
                echo -e "<table width=\"100%\" border=\"0\" align=\"center\" cellpadding=\"10\" class=\"efont\">
                <tr>
                <td width=\"10px\"></td>" >> "$wdir/temp.html"
                if [ -z "${dftn}" -a -z "${exmp1}" ]; then
                    echo -e "<td width=\"466\" valign=\"top\" class=\"nfont\" >${ntes}</td>
                    <td width=\"389\"</td>
                    </tr>
                    </table>" >> "$wdir/temp.html"
                else
                    echo -e "<td width=\"466\">" >> "$wdir/temp.html"
                    if [ -n "${dftn}" ]; then
                        echo -e "<dl>
                        <dd><dfn>${dftn}</dfn></dd>
                        </dl>" >> "$wdir/temp.html"
                    fi
                    if [ -n "${exmp1}" ]; then
                        echo -e "<dl>
                        <dt> </dt>
                        <dd><cite>${exmp1}</cite></dd>
                        </dl>" >> "$wdir/temp.html"
                    fi 
                    echo -e "</td>
                    <td width=\"400\" valign=\"top\" class=\"nfont\">${ntes}</td>
                    </tr>
                    </table>" >> "$wdir/temp.html"
                fi
            fi
        done < <(tac "${cfg3}")
        [ ${cntwords} -gt 0 ] && echo -e "<br><br><br><br>" >> "$wdir/temp.html"

        n=1; trgt=""
        while [[ ${n} -le "$(wc -l < "${cfg4}")" ]]; do
            trgt=$(sed -n ${n}p "$wdir/trgt_sentences")
            while read -r mrk; do
                if grep -Fxo ${mrk^} < "${cfg3}"; then
                trgsm=$(sed "s|$mrk|<mark>$mrk<\/mark>|g" <<<"$trgt")
                trgt="$trgsm"; fi
            done <<<"$(tr ' ' '\n' <<<"${trgt}")"

            if [ -n "${trgt}" ]; then
                srce=$(sed -n ${n}p "$wdir/srce_sentences")
                echo -e "<table width=\"100%\" border=\"0\" align=\"left\">
                <tr>
                <td bgcolor=\"#FFFFFF\"><strgt><li>${trgt}</li></strgt></td>
                </tr><tr>
                <td bgcolor=\"#FFFFFF\"><ssrce>${srce}<br><br></ssrce></td>
                </tr>
                </table>" >> "$wdir/temp.html"
            fi
            let n++
        done
        echo -e "</div></div>
        </body></html>" >> "$wdir/temp.html"
        wkhtmltopdf -s A4 -O Portrait "$wdir/temp.html" "$wdir/tmp.pdf"
        mv -f "$wdir/tmp.pdf" "${pdf}"
        rm -fr "$wdir"
    fi
    exit
}

mkpdf

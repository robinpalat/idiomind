#!/bin/bash
# -*- ENCODING: UTF-8 -*-

#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#  
source /usr/share/idiomind/ifs/c.conf
source "$DS/ifs/mods/cmns.sh"
lgt=$(lnglss $lgtl)
lgs=$(lnglss $lgsl)

if [ "$1" = play ]; then

    play "$2"
    wait
    
elif [ "$1" = listen_sntnc ]; then

    play "$DM_tlt/$2.mp3"
    exit

elif [ "$1" = dclik ]; then

    play "$DM_tls/${2,,}".mp3 & exit

fi

function add_audio() {

    cd $HOME
    AU=$(yad --width=620 --height=500 --file --on-top --name=Idiomind \
    --text=" $(gettext "Browse to and select the audio file that you want to add.")" \
    --class=Idiomind --window-icon="$DS/images/logo.png" --center --file-filter="*.mp3" \
    --button="$(gettext "Cancel")":1 --button="$(gettext "OK")":0 \
    --borders=5 --title="$(gettext "Add Audio")")

    ret=$?
    audio=$(echo "$AU" | cut -d "|" -f1)

    DT="$2"; cd $DT
    if [ $ret -eq 0 ]; then
        if  [ -f "$audio" ]; then
            cp -f "$audio" $DT/audtm.mp3 >/dev/null 2>&1
            #eyeD3 -P itunes-podcast --remove $DT/audtm.mp3
            eyeD3 --remove-all $DT/audtm.mp3 & exit
        fi
    fi
}

function edit_audio() {

    cmd="$(sed -n 16p $DC_s/1.cfg)"
    (cd "$3"; "$cmd" "$2") & exit
}

function text() {

    yad --width=300 --height=250 --form --field="$(< "$2")":lbl \
    --on-top --name=Idiomind --class=Idiomind --scroll --fixed \
    --window-icon="$DS/images/logo.png" --center --borders=5 \
    --button="$(gettext "Close")":0 \
    --title="$(gettext "Info")" >/dev/null 2>&1
}

function add_file() {

    cd $HOME
    FL=$(yad --width=620 --height=500 --file --on-top --name=Idiomind \
    --text=" $(gettext "Browse to and select the file that you want to add.")" \
    --class=Idiomind --window-icon="$DS/images/logo.png" --center --multiple \
    --file-filter="*.mp3 *.ogg *.mp4 *.m4v *.jpg *.jpeg *.png *.txt *.pdf *.gif" \
    --button="$(gettext "Cancel")":1 --button="$(gettext "OK")":0 \
    --borders=5 --title="$(gettext "Add File")")
    rt=$?
    
    if [ $rt -eq 0 ]; then
        while read -r file; do
            if  [ -f "$file" ]; then
                cp -f "$file" "$DM_tlt/attchs"
            fi
        done <<<$(sed s'/|/\n/'g <<<"$FL")
    fi

} >/dev/null

function videourl() {

    url=$(yad --window-icon="$DS/images/logo.png" --form --center --on-top \
    --text="$(gettext "Only youtube videos")" \
    --field="$(gettext "URL")" --title="Video" \
    --width=480 --height=100 --name=Idiomind --class=Idiomind \
    --skip-taskbar --borders=5 --button="$(gettext "Cancel")":1 --button=gtk-ok:0)
    echo "$url" > "$DM_tlt/attchs/video.url"

}

function attatchments() {
    
    mkindex() {

echo "<link rel=\"stylesheet\" \
href=\"/usr/share/idiomind/default/attstyle.css\">\
<body><div class=\"summary\">" \
> "$DC_tlt/att.html"

        while read -r file; do
    
if grep ".mp3" <<<"$file"; then
name="$(sed s'/\.mp3//' <<<"$file")"
echo "<br><br><h2>$name</h2>
<br><audio controls>
<source src=\"../attchs/$file\" type=\"audio/mpeg\">
Your browser does not support the audio tag.
</audio><br><br>" >> "$DC_tlt/att.html"
elif grep ".ogg" <<<"$file"; then
name="$(sed s'/\.ogg//' <<<"$file")"
echo "<br><br><h2>$name</h2>
<br><audio controls>
<source src=\"../attchs/$file\" type=\"audio/mpeg\">
Your browser does not support the audio tag.
</audio><br><br>" >> "$DC_tlt/att.html"
elif grep ".mp4" <<<"$file"; then
name="$(sed s'/\.mp4//' <<<"$file")"
echo "<br><br><h2>$name</h2>
<br><video width=450 height=280 controls>
<source src=\"../attchs/$file\" type=\"video/mp4\">
Your browser does not support the video tag.
</video><br><br>" >> "$DC_tlt/att.html"
elif grep ".m4v" <<<"$file"; then
name="$(sed s'/\.m4v//' <<<"$file")"
echo "<br><br><h2>$name</h2>
<br><video width=450 height=280 controls>
<source src=\"../attchs/$file\" type=\"video/mp4\">
Your browser does not support the video tag.
</video><br><br>" >> "$DC_tlt/att.html"
elif grep ".jpg" <<<"$file"; then
name="$(sed s'/\.jpg//' <<<"$file")"
echo "<br><br><h2>$name</h2>
<img src=\"../attchs/$file\" alt=\"$name\" \
style=\"width:100%;height:100%\"><br><br>" \
>> "$DC_tlt/att.html"
elif grep ".jpeg" <<<"$file"; then
name="$(sed s'/\.jpeg//' <<<"$file")"
echo "<br><br><h2>$name</h2>
<img src=\"../attchs/$file\" alt=\"$name\" \
style=\"width:100%;height:100%\"><br><br>" \
>> "$DC_tlt/att.html"
elif grep ".png" <<<"$file"; then
name="$(sed s'/\.png//' <<<"$file")"
echo "<br><br><h2>$name</h2>
<img src=\"../attchs/$file\" alt=\"$name\" \
style=\"width:100%;height:100%\"><br><br>" \
>> "$DC_tlt/att.html"
elif grep ".txt" <<<"$file"; then
txto=$(cat "$DM_tlt/attchs/$file")
echo "<br><br><div class=\"summary\">$txto \
<br><br></div>" \
>> "$DC_tlt/att.html"
elif grep ".url" <<<"$file"; then
url=$(sed 's/|//' < "$DM_tlt/attchs/$file")
echo "<br><br><div class=\"summary\">
<iframe width=\"420\" height=\"315\" src=\"$url\" \
frameborder=\"0\" allowfullscreen></iframe>
</div><br><br>" >> "$DC_tlt/att.html"
elif grep ".gif" <<<"$file"; then
name="$(sed s'/\.gif//' <<<"$file")"
echo "<br><br><h2>$name</h2>
<img src=\"../attchs/$file\" alt=\"$name\" \
style=\"width:100%;height:100%\"><br><br>" \
>> "$DC_tlt/att.html"
fi
        done <<<"$(ls "$DM_tlt/attchs")"
    
echo "<br><br></div>
</body>" >> "$DC_tlt/att.html"
            
    } >/dev/null 2>&1
    
    [ ! -d "$DM_tlt/attchs" ] && mkdir "$DM_tlt/attchs"
    ch1="$(ls -A "$DM_tlt/attchs")"
    
    if [ "$(ls -A "$DM_tlt/attchs")" ]; then
        [ ! -f "$DC_tlt/att.html" ] && mkindex >/dev/null 2>&1
        yad --html --uri="$DC_tlt/att.html" \
        --window-icon="$DS/images/logo.png" --center \
        --title="$(gettext "Attachments")" --borders=5 \
        --width=650 --height=580 \
        --button="$(gettext "Open Folder")":"xdg-open '$DM_tlt/attchs'" \
        --button="$(gettext "Video URL")":"$DS/ifs/tls.sh 'videourl'" \
        --button="$(gettext "Add File")":"$DS/ifs/tls.sh 'add_file'" \
        --button="$(gettext "Close")":"1" \
        --name=Idiomind --class=Idiomind \
        
        
        if [ "$ch1" != "$(ls -A "$DM_tlt/attchs")" ]; then
            mkindex
        fi
        
    else
        yad --form --window-icon="$DS/images/logo.png" --borders=5 \
        --field="$(gettext "Add File")":FBTN "$DS/ifs/tls.sh 'add_file'" \
        --field="$(gettext "Add Video URL (Youtube)")":FBTN "$DS/ifs/tls.sh 'videourl'" \
        --name=Idiomind --class=Idiomind --center \
        --text="$(gettext "Put files in a folder related to the topic.")" \
        --title="$(gettext "Attachments")" --width=350 --height=200 \
        --button="$(gettext "Cancel")":1 \
        --button="$(gettext "OK")":0
        ret=$?
        if [ "$ch1" != "$(ls -A "$DM_tlt/attchs")" ] && [ $ret = 0 ]; then
            mkindex
        fi
    fi
} >/dev/null 2>&1

function help() {

    web="http://idiomind.sourceforge.net/doc/help.html"
    yad --html --browser --uri="$web" \
    --window-icon="$DS/images/logo.png" \
    --title="$(gettext "Help")" --width=700 --fixed \
    --height=600 --button="$(gettext "OK")":0 \
    --name=Idiomind --class=Idiomind >/dev/null 2>&1
}
    
function definition() {

    web="http://glosbe.com/$lgt/$lgs/${2,,}"
    xdg-open "$web"
}

function web() {

    web=http://idiomind.sourceforge.net
    xdg-open "$web/$lgs/${lgtl,,}" >/dev/null 2>&1
}

function fback() {

    web="http://idiomind.sourceforge.net/doc/msg.html"
    yad --html --browser --uri="$web" \
    --window-icon="$DS/images/logo.png" \
    --title="$(gettext "Message")" --width=500 \
    --height=455 --no-buttons --fixed \
    --name=Idiomind --class=Idiomind >/dev/null 2>&1
}

function check_updates() {

    cd "$DT"; internet
    [ -f release ] && rm -f release
    rversion="$(curl http://idiomind.sourceforge.net/doc/release | sed -n 1p)"
    pkg='https://sourceforge.net/projects/idiomind/files/idiomind.deb/download'
    
    if [ "$rversion" != "$(idiomind -v)" ]; then
    
        msg_2 "<b> $(gettext "A new version of Idiomind available") </b>\n\n" info "$(gettext "Download")" "$(gettext "Cancel")" $(gettext "Updates")
        
        if [ "$ret" -eq 0 ]; then
            xdg-open "$pkg";
        elif [ "$ret" -eq 1 ]; then
            echo `date +%d` > "$DC_s/9.cfg";
        fi
        
    else
        msg " $(gettext "No updates available.") \n" info $(gettext "Updates")
    fi

    exit 0
}

function a_check_updates() {

    [ ! -f "$DC_s/9.cfg" ] && echo `date +%d` > "$DC_s/9.cfg" && exit
    
    d1=$(< $DC_s/9.cfg); d2=$(date +%d)
    if [ $(sed -n 1p $DC_s/9.cfg) = 28 ] && [ $(wc -l < $DC_s/9.cfg) -ge 2 ]; then
    rm -f "$DC_s/9.cfg"; fi

    if [ "$d1" != "$d2" ]; then

        echo "$d2" > "$DC_s/9.cfg"
        cd "$DT"; internet; [ -f release ] && rm -f release
        curl -v www.google.com 2>&1 | \
        grep -m1 "HTTP/1.1" >/dev/null 2>&1 || exit 1
        rversion="$(curl http://idiomind.sourceforge.net/doc/release | sed -n 1p)"
        pkg='https://sourceforge.net/projects/idiomind/files/idiomind.deb/download'
        
        if [ "$rversion" != "$(idiomind -v)" ]; then
            
            msg_2 "<b> $(gettext "A new version of Idiomind available")\n</b>\n $(gettext "Do you want to download it now?")\n" info "$(gettext "Yes")" "$(gettext "No")" "$(gettext "Updates")" "$(gettext "Ignore this update")"
            ret=$(echo $?)
            
            if [ "$ret" -eq 0 ]; then
                xdg-open "$pkg";
            elif [ "$ret" -eq 2 ]; then
                echo `date +%d` >> "$DC_s/9.cfg";
            elif [ "$ret" -eq 1 ]; then
                echo `date +%d` > "$DC_s/9.cfg";
            fi
        fi
    fi
    exit 0
}

function about() {

python << END
import gtk
import os
app_logo = os.path.join('/usr/share/idiomind/images/', 'logo.png')
app_name = 'Idiomind'
app_version = 'v2.2-beta'
app_comments = 'Vocabulary learning tool'
app_copyright = 'Copyright (c) 2013-2015 Robin Palat'
app_website = 'http://idiomind.sourceforge.net/'
app_license = (('This program is free software: you can redistribute it and/or modify\n'+
'it under the terms of the GNU General Public License as published by\n'+
'the Free Software Foundation, either version 3 of the License, or\n'+
'(at your option) any later version.\n'+
'\n'+
'This program is distributed in the hope that it will be useful,\n'+
'but WITHOUT ANY WARRANTY; without even the implied warranty of\n'+
'MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n'+
'GNU General Public License for more details.\n'+
'\n'+
'You should have received a copy of the GNU General Public License\n'+
'along with this program.  If not, see <http://www.gnu.org/licenses/>.'))
app_authors = ['Robin Palat <patapatass@gmail.com>']
app_documenters = ['Robin Palat <patapatass@gmail.com>']

class AboutDialog:

    def __init__(self):

        about = gtk.AboutDialog()
        about.set_logo(gtk.gdk.pixbuf_new_from_file(app_logo))
        about.set_wmclass('Idiomind', 'Idiomind')
        about.set_name(app_name)
        about.set_program_name(app_name)
        about.set_version(app_version)
        about.set_comments(app_comments)
        about.set_copyright(app_copyright)
        about.set_license(app_license)
        about.set_website(app_website)
        about.set_website_label(app_website)
        about.set_authors(app_authors)
        about.set_documenters(app_documenters)
        about.run()
        about.destroy()

if __name__ == "__main__":
    AboutDialog = AboutDialog()
    main()
END
}


function set_image() {

    cd "$DT"
    
    if [ "$3" = word ]; then wrd="$2"
    elif [ "$3" = sentence ]; then
    wrd=$(eyeD3 "$2" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)'); fi

    search="$(sed "s/'//g" <<<"$wrd")"
    fname="$(nmfile "$wrd")"
    echo -e "<html><head>
    <meta http-equiv=\"Refresh\" content=\"0;url=https://www.google.com/search?q="$search"&tbm=isch\">
    </head><body><p>Search images for \"$search\"...</p></body></html>" > search.html
    ICON="$DS/icon/nw.png"
    btnn="--button="$(gettext "Add Image")":3"
    
    if [ "$3" = word ]; then
        
        if [ ! -f "$DT/$fname.*" ]; then
            file="$DM_tlt/words/$fname.mp3"; fi
        
        if [ -f "$DM_tlt/words/images/$fname.jpg" ]; then
            ICON="--image=$DM_tlt/words/images/$fname.jpg"
            btnn="--button="$(gettext "Change")":3"
            btn2="--button="$(gettext "Delete")":2"
        else
            txt="--text=<small>$(gettext "Search image related") <a href='file://$DT/search.html'>$wrd</a></small>"
        fi
        
        yad --form --align=center --center --name=Idiomind --class=Idiomind \
        --width=340 --text-align=center --height=280 \
        --on-top --skip-taskbar --image-on-top "$txt" >/dev/null 2>&1 \
        "$btnn" --window-icon="$DS/images/logo.png" --borders=5 \
        --title=$(gettext "Image") "$ICON" "$btn2" \
        --button=gtk-close:1
        ret=$? >/dev/null 2>&1
            
            if [ $ret -eq 3 ]; then
            
                rm -f *.l
                scrot -s --quality 70 "$fname.temp.jpeg"
                /usr/bin/convert -scale 100x90! "$fname.temp.jpeg" "$wrd"_temp.jpeg
                /usr/bin/convert -scale 360x240! "$fname.temp.jpeg" "$DM_tlt/words/images/$fname.jpg"
                eyeD3 --remove-images "$file" >/dev/null 2>&1
                eyeD3 --add-image "$fname"_temp.jpeg:ILLUSTRATION "$file" >/dev/null 2>&1
                rm -f *.jpeg
                "$DS/ifs/tls.sh" set_image "$wrd" word
                
            elif [ $ret -eq 2 ]; then
            
                eyeD3 --remove-image "$file" >/dev/null 2>&1
                rm -f "$DM_tlt/words/images/$fname.jpg"
                rm -f *.jpeg s.html
                
            else
                rm -f *.jpeg s.html
            fi
            
    elif [ "$3" = sentence ]; then
    
        if [ ! -f "$DT/$wrd.*" ]; then
            file="$DM_tlt/$fname.mp3"; fi
        
        btnn="--button="$(gettext "Add Image")":3"
        eyeD3 --write-images="$DT" "$file" >/dev/null 2>&1
        
        if [ -f "$DT/ILLUSTRATION".jpeg ]; then
            mv -f "$DT/ILLUSTRATION".jpeg "$DT/imgsw".jpeg
            ICON="--image=$DT/imgsw.jpeg"
            btnn="--button="$(gettext "Change")":3"
            btn2="--button="$(gettext "Delete")":2"
        else
            txt="--text=<small>\\n<a href='file://$DT/search.html'>"$(gettext "Search image related to")"</a></small>"
        fi
        
        yad --name=Idiomind --class=Idiomind --text-align=center \
        --form --center --width=470 --height=280 \
        --on-top --skip-taskbar --image-on-top \
        "$txt" "$btnn" --window-icon="$DS/images/logo.png" --borders=5 \
        --title=$(gettext "Image") "$ICON" "$btn2" --button=gtk-close:1
        ret=$? >/dev/null 2>&1
                
            if [ $ret -eq 3 ]; then
            
                rm -f $DT/*.l
                scrot -s --quality 70 "$fname.temp.jpeg"
                /usr/bin/convert -scale 450x270! "$fname.temp.jpeg" "$fname"_temp.jpeg
                eyeD3 --remove-image "$file" >/dev/null 2>&1
                eyeD3 --add-image "$fname"_temp.jpeg:ILLUSTRATION "$file" >/dev/null 2>&1 &&
                rm -f *.jpeg
                printf "aimg.$tpc.aimg\n" >> $DC_s/8.cfg &
                "$DS/ifs/tls.sh" set_image "$wrd" sentence
                
            elif [ $ret -eq 2 ]; then
                eyeD3 --remove-images "$file" >/dev/null 2>&1
                rm -f search.html *.jpeg
            else
                rm -f search.html *.jpeg
            fi
    fi

}

function pdfdoc() {

    cd $HOME
    pdf=$(yad --save --center --borders=5 --name=Idiomind \
    --on-top --filename="$HOME/$tpc.pdf" --class=Idiomind \
    --window-icon="$DS/images/logo.png" --title="Export " \
    --file --width=600 --height=500 --button=gtk-ok:0 )
    ret=$?

    if [ "$ret" -eq 0 ]; then
    
        dte=$(date "+%d %B %Y")
        mkdir "$DT/mkhtml"
        mkdir "$DT/mkhtml/images"
        nts=$(sed 's/\./\.<br>/g' < "$DC_tlt/10.cfg")
        cd "$DT/mkhtml"
        cp -f "$DC_tlt/3.cfg" w.inx.l
        cp -f "$DC_tlt/4.cfg" s.inx.l
        iw=w.inx.l; is=s.inx.l

        n=1
        while [[ $n -le "$(wc -l < $iw | awk '{print ($1)}')" ]]; do
            wnm=$(sed -n "$n"p $iw)
            fname="$(nmfile "$wnm")"
            if [ -f "$DM_tlt/words/images/$fname.jpg" ]; then
                convert "$DM_tlt/words/images/$fname.jpg" -alpha set -virtual-pixel transparent \
                -channel A -blur 0x10 -level 50%,100% +channel "$DT/mkhtml/images/$wnm.png"
            fi
            let n++
        done

        n=1
        while [[ $n -le "$(wc -l < $is | awk '{print ($1)}')" ]]; do
            wnm=$(sed -n "$n"p $is)
            fname="$(nmfile "$wnm")"
            tgs=$(eyeD3 "$DM_tlt/$fname.mp3")
            wt=$(echo "$tgs" | grep -o -P "(?<=ISI1I0I).*(?=ISI1I0I)")
            ws=$(echo "$tgs" | grep -o -P "(?<=ISI2I0I).*(?=ISI2I0I)")
            echo "$wt" >> S.gprt.x
            echo "$ws" >> S.gprs.x
            let n++
        done
        echo '<head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <title>'$tpc'</title>
        <head>
        <link rel="stylesheet" href="/usr/share/idiomind/default/pdfstyle.css">
        </head>
        <body>
        <div><p></p>
        </div>
        <div>
        <h3>'$tpc'</h3>
        <p>&nbsp;</p>
        <hr>
        <table width="80%" align="left" border="0" class="ifont">
        <tr>
        <td>
        <br>' > pdf_doc
        printf "$nts" >> pdf_doc
        echo '<p>&nbsp;</p>
        <p>&nbsp;</p>
        <p>&nbsp;</p>
        </td>
        </tr>
        </table>' >> pdf_doc

        cd "$DM_tlt/words/images"
        cnt=`ls -1 *.jpg 2>/dev/null | wc -l`
        if [ $cnt != 0 ]; then
            cd $DT/mkhtml/images/
            ls *.png | sed 's/\.png//g' > "$DT/mkhtml/nimg"
            cd $DT/mkhtml
            echo '<table width="90%" align="center" border="0" class="wrdimg">' >> pdf_doc
            n=1
            while [ $n -le "$(wc -l < nimg)" ]; do
                    if [ -f nnn ]; then
                    n=$(< nnn)
                    fi
                    nn=$(($n + 1))
                    nnn=$(($n + 2))
                    d1m=$(sed -n "$n","$nn"p < nimg | sed -n 1p)
                    d2m=$(sed -n "$n","$nn"p < nimg | sed -n 2p)
                    if [ -n "$d1m" ]; then
                        echo '<tr>
                        <td align="center"><img src="images/'$d1m'.png" width="240" height="220"></td>' >> pdf_doc
                        if [ -n "$d2m" ]; then
                            echo '<td align="center"><img src="images/'$d2m'.png" width="240" height="220"></td>
                            </tr>' >> pdf_doc
                        else
                            echo '</tr>' >> pdf_doc
                        fi
                        echo '<tr>
                        <td align="center" valign="top"><p>'$d1m'</p>
                        <p>&nbsp;</p>
                        <p>&nbsp;</p>
                        <p>&nbsp;</p></td>' >> pdf_doc
                        if [ -n "$d2m" ]; then
                            echo '<td align="center" valign="top"><p>'$d2m'</p>
                            <p>&nbsp;</p>
                            <p>&nbsp;</p>
                            <p>&nbsp;</p></td>
                            </tr>' >> pdf_doc
                        else
                            echo '</tr>' >> pdf_doc
                        fi
                    else
                        break
                    fi
                    echo $nnn > nnn
                let n++
            done
            echo '</table>
            <p>&nbsp;</p>
            <p>&nbsp;</p>' >> pdf_doc
        fi

        cd "$DT/mkhtml"
        n=1
        while [ $n -le "$(wc -l < $iw)" ]; do
            wnm=$(sed -n "$n"p $iw)
            fname="$(nmfile "$wnm")"
            tgs=$(eyeD3 "$DM_tlt/words/$fname.mp3")
            wt=$(echo "$tgs" | grep -o -P "(?<=IWI1I0I).*(?=IWI1I0I)")
            ws=$(echo "$tgs" | grep -o -P "(?<=IWI2I0I).*(?=IWI2I0I)")
            inf=$(echo "$tgs" | grep -o -P '(?<=IWI3I0I).*(?=IWI3I0I)' | tr '_' '\n')
            hlgt="${wt,,}"
            exm1=$(echo "$inf" | sed -n 1p | sed 's/\\n/ /g')
            dftn=$(echo "$inf" | sed -n 2p | sed 's/\\n/ /g')
            exmp1=$(echo "$exm1" \
            | sed "s/"$hlgt"/<b>"$hlgt"<\/\b>/g")
            echo "$wt" >> W.lizt.x
            echo "$ws" >> W.lizs.x
            if [ -n "$wt" ]; then
                echo '<table width="55%" border="0" align="left" cellpadding="10" cellspacing="5">
                <tr>
                <td bgcolor="#F8D49F" class="side"></td>
                <td bgcolor="#F7EDDF"><w1>'$wt'</w1></td>
                </tr>
                <tr>
                <td bgcolor="#EAE5A0" class="side"></td>
                <td bgcolor="#FAF9F4"><w2>'$ws'</w2></td>
                </tr>
                </table>' >> pdf_doc
                echo '<table width="100%" border="0" align="center" cellpadding="10" class="efont">
                <tr>
                <td width="10px"></td>' >> pdf_doc
                if ([ -z "$dftn" ] && [ -z "$exmp1" ]); then
                echo '<td width="466" valign="top" class="nfont" >'$ntes'</td>
                <td width="389"</td>
                </tr>
                </table>' >> pdf_doc
                else
                    echo '<td width="466">' >> pdf_doc
                    if [ -n "$dftn" ]; then
                        echo '<dl>
                        <dd><dfn>'$dftn'</dfn></dd>
                        </dl>' >> pdf_doc
                    fi
                    if [ -n "$exmp1" ]; then #Example: <dt> </dt>
                        echo '<dl>
                        <dt> </dt>
                        <dd><cite>'$exmp1'</cite></dd>
                        </dl>' >> pdf_doc
                    fi 
                    echo '</td>
                    <td width="389" valign="top" class="nfont">'$ntes'</td>
                    </tr>
                    </table>' >> pdf_doc
                fi
                echo '<p>&nbsp;</p>
                <h1>&nbsp;</h1>' >> pdf_doc
            fi
            let n++
        done

        n=1
        while [ $n -le "$(wc -l < s.inx.l)" ]; do
                st=$(sed -n "$n"p S.gprt.x)
                if [ -n "$st" ]; then
                    ss=$(sed -n "$n"p S.gprs.x)
                    fn=$(sed -n "$n"p s.inx.l)
                    echo '<h1>&nbsp;</h1>
                    <table width="100%" border="0" align="left" cellpadding="10" cellspacing="5">
                    <tr>
                    <td bgcolor="#FAF9F4"><h1>'$st'</h1></td>
                    </tr>' > Sgprt.tmp
                    echo '<tr>
                    <td ><h2>'$ss'</h2></td>
                    </tr>
                    </table>
                    <h1>&nbsp;</h1>' > Sgprs.tmp
                    cat Sgprt.tmp >> pdf_doc
                    cat Sgprs.tmp >> pdf_doc
                fi
            let n++
        done

        echo '<p>&nbsp;</p>
        <p>&nbsp;</p>
        <h3>&nbsp;</h3>
        <p>&nbsp;</p>
        </div>
        </div>
        <span class="container"></span>
        </body>
        </html>' >> pdf_doc
        mv -f pdf_doc pdf_doc.html
        wkhtmltopdf -s A4 -O Portrait pdf_doc.html tmp.pdf
        mv -f tmp.pdf "$pdf"
        rm -fr pdf_doc "$DT/mkhtml" "$DT"/*.x "$DT"/*.l

    else
        exit 0
    fi
}

case "$1" in
    add_audio)
    add_audio "$@" ;;
    edit_audio)
    edit_audio "$@" ;;
    text)
    text "$@" ;;
    attachs)
    attatchments "$@" ;;
    add_file)
    add_file ;;
    videourl)
    videourl "$@" ;;
    help)
    help ;;
    definition)
    definition "$@" ;;
    check_updates)
    check_updates ;;
    a_check_updates)
    a_check_updates ;;
    check_index)
    check_index "$@" ;;
    set_image)
    set_image "$@" ;;
    pdfdoc)
    pdfdoc ;;
    fback)
    fback ;;
    about)
    about ;;
esac

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

source "$DS/ifs/mods/cmns.sh"
lgt=$(lnglss $lgtl)
lgs=$(lnglss $lgsl)

# -------------------------------------------------
if [ "$1" = play ]; then

    play "$2"
    wait

# -------------------------------------------------
elif [ "$1" = add_audio ]; then

    cd $HOME
    AU=$(yad --width=620 --height=400 --file --on-top --name=idiomind \
    --class=idiomind --window-icon=idiomind --center --file-filter="*.mp3" \
    --button=Ok:0 --borders=0 --title="$ttl" --skip-taskbar)

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

# -------------------------------------------------
elif [ "$1" = listen_sntnc ]; then

    play "$DM_tlt/$2.mp3"
    exit

# -------------------------------------------------
elif [ "$1" = dclik ]; then

    play "$DM_tls/${2,,}".mp3 & exit
    
# -------------------------------------------------
elif [ "$1" = edit_audio ]; then

    cmd="$(sed -n 16p $DC_s/1.cfg)"
    (cd "$3"; "$cmd" "$2") & exit

# -------------------------------------------------
elif [ "$1" = help ]; then

    web="http://idiomind.sourceforge.net/doc/help.html"
    yad --html --window-icon=idiomind --browser \
    --title="$(gettext "Help")" --width=700 \
    --height=600 --button="$(gettext "OK")":0 \
    --name=Idiomind --class=Idiomind \
    --uri="$web" >/dev/null 2>&1
    
# -------------------------------------------------
elif [ "$1" = definition ]; then

    web="http://glosbe.com/$lgt/$lgs/${2,,}"
    xdg-open "$web"
    
# -------------------------------------------------
elif [ "$1" = web ]; then

    web=http://idiomind.sourceforge.net
    xdg-open "$web/$lgs/${lgtl,,}" >/dev/null 2>&1

# -------------------------------------------------
elif [ "$1" = fback ]; then

    web="http://idiomind.sourceforge.net/doc/msg.html"
    yad --html --window-icon=idiomind --browser \
    --title="$(gettext "Message")" --width=500 \
    --height=455 --no-buttons --fixed \
    --name=Idiomind --class=Idiomind \
    --uri="$web" >/dev/null 2>&1

# -------------------------------------------------
elif [ "$1" = check_updates ]; then

    cd "$DT"; internet
    [ -f release ] && rm -f release
    wget http://idiomind.sourceforge.net/doc/release
    pkg=https://sourceforge.net/projects/idiomind/files/idiomind.deb/download
    
    if [ "$(sed -n 1p $DT/release)" != "$(idiomind -v)" ]; then
    
        yad --text="<b> $(gettext "A new version of Idiomind available") </b>\n\n" \
        --image=info --title=" " --window-icon=idiomind \
        --on-top --skip-taskbar --sticky --class=Idiomind \
        --center --name=Idiomind --borders=10 --always-print-result \
        --button="$later":2 --button="$(gettext "Download")":0 \
        --width=430 --height=160
        ret=$?
        
        if [ "$ret" -eq 0 ]; then
            xdg-open "$pkg";
        elif [ "$ret" -eq 2 ]; then
            echo `date +%d` > "$DC_s/9.cfg";
        elif [ "$ret" -eq 1 ]; then
            echo `date +%d` > "$DC_s/9.cfg";
        fi
        
    else
        yad --text="<big><b> $(gettext "No updates available")  </b></big>\n\n  $(gettext "You have the latest version of Idiomind.")" \
        --image=info --title=" " --window-icon=idiomind \
        --on-top --skip-taskbar --sticky --width=430 --height=160 \
        --center --name=idiomind --borders=10 \
        --button="$(gettext "OK")":1;
    fi
    
    [ -f "$DT/release" ] && rm -f "$DT/release"
    exit 0
    

# -------------------------------------------------
elif [ "$1" = a_check_updates ]; then

    [ ! -f "$DC_s/9.cfg" ] \
    && echo `date +%d` > "$DC_s/9.cfg" && exit
    d1=$(cat $DC_s/9.cfg); d2=$(date +%d)
    if [ $(sed -n 1p $DC_s/9.cfg) = 28 ] \
    && [ $(wc -l < $DC_s/9.cfg) -ge 2 ]; then
    rm -f "$DC_s/9.cfg"; fi

    if [ "$d1" != "$d2" ]; then

        echo "$d2" > "$DC_s/9.cfg"
        cd "$DT"; internet; [ -f release ] && rm -f release
        curl -v www.google.com 2>&1 | \
        grep -m1 "HTTP/1.1" >/dev/null 2>&1 || exit 1
        wget http://idiomind.sourceforge.net/doc/release
        pkg=https://sourceforge.net/projects/idiomind/files/idiomind.deb/download
        
        if [ "$(sed -n 1p $DT/release)" != "$(idiomind -v)" ]; then
            
            yad --text="<b> $(gettext "A new version of Idiomind available\n")</b>\n $(gettext "You would like to update?")\n" \
            --image=info --title=" " --window-icon=idiomind \
            --on-top --skip-taskbar --sticky --always-print-result \
            --center --name=Idiomind --borders=10 --class=Idiomind \
            --button="$(gettext "No, Thanks")":2 --button="$(gettext "Download")":0 \
            --width=430 --height=160
            ret=$?
            
            if [ "$ret" -eq 0 ]; then
                xdg-open "$pkg";
            elif [ "$ret" -eq 2 ]; then
                echo `date +%d` >> "$DC_s/9.cfg";
            elif [ "$ret" -eq 1 ]; then
                echo `date +%d` > "$DC_s/9.cfg";
            fi
        fi
    fi
    [ -f "$DT/release" ] && rm -f "$DT/release"
    exit 0
    
# -------------------------------------------------
elif [ "$1" = about ]; then

python << END
import gtk
import os
app_logo = os.path.join('/usr/share/idiomind/images/', 'logo.png')
app_name = 'Idiomind'
app_version = 'v2.2-beta'
app_comments = 'Vocabulary learning tool'
app_copyright = 'Copyright (c) 2013-2015 Robin Palat'
app_website = 'https://sourceforge.net/projects/idiomind/'
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

# -------------------------------------------------
elif [ "$1" = check_index ]; then

    source /usr/share/idiomind/ifs/c.conf
    DC_tlt="$DM_tl/$2/.conf"
    DM_tlt="$DM_tl/$2"
    
    function check() {

        n=0
        while [ $n -le 4 ]; do
            [ ! -f "$DC_tlt/$n.cfg" ] && touch "$DC_tlt/$n.cfg"
            check_index1 "$DC_tlt/$n.cfg"        
            eval chk$n=$(wc -l < "$DC_tlt/$n.cfg")
            ((n=n+1))
        done
        eval stts=$(cat "$DC_tlt/8.cfg")
        eval mp3s="$(cd "$DM_tlt/"; find . -maxdepth 2 -name '*.mp3' \
        | sort -k 1n,1 -k 7 | wc -l)"
    }
    
    function fix() {
       rm "$DC_tlt/0.cfg" "$DC_tlt/1.cfg" "$DC_tlt/2.cfg" "$DC_tlt/3.cfg" "$DC_tlt/4.cfg"
       while read name; do
        
            sfname="$(nmfile "$name")"
            wfname="$(nmfile "$name")"

            if [ -f "$DM_tlt/$name.mp3" ]; then
                tgs="$(eyeD3 "$DM_tlt/$name.mp3")"
                trgt="$(echo "$tgs" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')"
                [ -z "$trgt" ] && rm "$DM_tlt/$name.mp3" && continue
                xname="$(echo -n "$trgt" | md5sum | rev | cut -c 4- | rev)"
                [ "$name" != "$xname" ] && \
                mv -f "$DM_tlt/$name.mp3" "$DM_tlt/$xname.mp3"
                echo "$trgt" >> "$DC_tlt/0.cfg.tmp"
                echo "$trgt" >> "$DC_tlt/4.cfg.tmp"
            elif [ -f "$DM_tlt/$sfname.mp3" ]; then
                tgs=$(eyeD3 "$DM_tlt/$sfname.mp3")
                trgt=$(echo "$tgs" | grep -o -P '(?<=ISI1I0I).*(?=ISI1I0I)')
                [ -z "$trgt" ] && rm "$DM_tlt/$sfname.mp3" && continue
                xname="$(echo -n "$trgt" | md5sum | rev | cut -c 4- | rev)"
                [ "$sfname" != "$xname" ] && \
                mv -f "$DM_tlt/$sfname.mp3" "$DM_tlt/$xname.mp3"
                echo "$trgt" >> "$DC_tlt/0.cfg.tmp"
                echo "$trgt" >> "$DC_tlt/4.cfg.tmp"
            elif [ -f "$DM_tlt/words/$name.mp3" ]; then
                tgs="$(eyeD3 "$DM_tlt/words/$name.mp3")"
                trgt="$(echo "$tgs" | grep -o -P '(?<=IWI1I0I).*(?=IWI1I0I)')"
                [ -z "$trgt" ] && rm "$DM_tlt/words/$name.mp3" && continue
                xname="$(echo -n "$trgt" | md5sum | rev | cut -c 4- | rev)"
                [ "$name" != "$xname" ] && \
                mv -f "$DM_tlt/words/$name.mp3" "$DM_tlt/words/$xname.mp3"
                echo "$trgt" >> "$DC_tlt/0.cfg.tmp"
                echo "$trgt" >> "$DC_tlt/3.cfg.tmp"
            elif [ -f "$DM_tlt/words/$wfname.mp3" ]; then
                tgs="$(eyeD3 "$DM_tlt/words/$wfname.mp3")"
                trgt="$(echo "$tgs" | grep -o -P '(?<=IWI1I0I).*(?=IWI1I0I)')"
                [ -z "$trgt" ] && rm "$DM_tlt/words/$wfname.mp3" && continue
                xname="$(echo -n "$trgt" | md5sum | rev | cut -c 4- | rev)"
                [ "$wfname" != "$xname" ] \
                && mv -f "$DM_tlt/words/$wfname.mp3" "$DM_tlt/words/$xname.mp3"
                echo "$trgt" >> "$DC_tlt/0.cfg.tmp"
                echo "$trgt" >> "$DC_tlt/3.cfg.tmp"
            fi
            
        done < "$index"

        mv -f "$DC_tlt/0.cfg.tmp" "$DC_tlt/0.cfg"
        mv -f "$DC_tlt/3.cfg.tmp" "$DC_tlt/3.cfg"
        mv -f "$DC_tlt/4.cfg.tmp" "$DC_tlt/4.cfg"
        cp -f "$DC_tlt/0.cfg" "$DC_tlt/1.cfg"
        cp -f "$DC_tlt/0.cfg" "$DC_tlt/.11.cfg"
        check_index1 "$DC_tlt/0.cfg" "$DC_tlt/1.cfg" \
        "$DC_tlt/2.cfg" "$DC_tlt/3.cfg" "$DC_tlt/4.cfg"
        
        if [ $? -ne 0 ]; then
            [ -f "$DT/ps_lk" ] && rm -f "$DT/ps_lk"
            msg " $(gettext "File not found")\n" error & exit 1
        fi
        
        if [ -z "$stts" ]; then
            echo "1" > "$DC_tlt/8.cfg"
        elif [ "$stts" = "13" ]; then
            if cat "$DM_tl/.3.cfg" | grep -Fxo "$topic"; then
                echo "6" > "$DC_tlt/8.cfg"
            elif cat "$DM_tl/.2.cfg" | grep -Fxo "$topic"; then
                echo "1" > "$DC_tlt/8.cfg"
            else
                echo "1" > "$DC_tlt/8.cfg"
            fi
        fi
    }
        
    function files() {
        
        cd "$DM_tlt/words/"
        for i in *.mp3 ; do [ ! -s ${i} ] && rm ${i} ; done
        if [ -f ".mp3" ]; then rm ".mp3"; fi
        cd "$DM_tlt/"
        for i in *.mp3 ; do [[ ! -s ${i} ]] && rm ${i} ; done
        if [ -f ".mp3" ]; then rm ".mp3"; fi
        cd "$DM_tlt/"; find . -maxdepth 2 -name '*.mp3' \
        | sort -k 1n,1 -k 7 | sed s'|\.\/words\/||'g \
        | sed s'|\.\/||'g | sed s'|\.mp3||'g > "$DT/index"
    }

    check

    if [[ $(($chk3 + $chk4)) != $chk0 || $(($chk1 + $chk2)) != $chk0 \
    || $mp3s != $chk0 || $stts = 13 ]]; then
    
        (sleep 1
        notify-send -i idiomind "$(gettext "Index error")" "$(gettext "fixing...")" -t 3000) &
        > "$DT/ps_lk"
        [ ! -d "$DM_tlt/.conf" ] && mkdir "$DM_tlt/.conf"
        DC_tlt="$DM_tlt/.conf"
        
        files
        
        if ([ -f "$DC_tlt/.11.cfg" ] && \
        [ -n "$(cat "$DC_tlt/.11.cfg")" ]); then
            index="$DC_tlt/.11.cfg"
        else
            index="$DT/index"
        fi
        
        fix
    fi

    check
    
    if [[ $(($chk3 + $chk4)) != $chk0 || $(($chk1 + $chk2)) != $chk0 \
    || $mp3s != $chk0 || $stts = 13 ]]; then

        files
        
        index="$DT/index"; rm "$DC_tlt/.11.cfg"

        fix
    fi
    
    n=0
    while [ $n -le 4 ]; do
        touch "$DC_tlt/$n.cfg"
        ((n=n+1))
    done

    "$DS/mngr.sh" mkmn & exit 1

# -------------------------------------------------
elif [ "$1" = pdfdoc ]; then

    cd $HOME
    pdf=$(yad --save --center --borders=5 --name=Idiomind \
    --on-top --filename="$HOME/$tpc.pdf" --class=Idiomind \
    --window-icon=idiomind --title="Export " \
    --file --width=600 --height=500 --button=gtk-ok:0 )
    ret=$?

    if [ "$ret" -eq 0 ]; then
    
        dte=$(date "+%d %B %Y")
        mkdir $DT/mkhtml
        mkdir $DT/mkhtml/images
        nts=$(cat "$DC_tlt/10.cfg" | sed 's/\./\.<br>/g')
        cd $DT/mkhtml
        cp -f "$DC_tlt/3.cfg" w.inx.l
        cp -f "$DC_tlt/4.cfg" s.inx.l
        iw=w.inx.l; is=s.inx.l

        #images
        n=1
        while [[ $n -le "$(cat $iw | wc -l | awk '{print ($1)}')" ]]; do
            wnm=$(sed -n "$n"p $iw)
            fname="$(nmfile "$wnm")"
            if [ -f "$DM_tlt/words/images/$fname.jpg" ]; then
                convert "$DM_tlt/words/images/$fname.jpg" -alpha set -virtual-pixel transparent \
                -channel A -blur 0x10 -level 50%,100% +channel "$DT/mkhtml/images/$wnm.png"
            fi
            let n++
        done
        #sentences
        n=1
        while [[ $n -le "$(cat  $is | wc -l | awk '{print ($1)}')" ]]; do
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
        <style type="text/css">
        w1 {
            margin-top: 0;
            padding-right: 5px;
            padding-left: 5px;
            color: #5E5A54;
            font-size: 20px;
            font-weight: bold;
            font-family: Verdana, Geneva, sans-serif;
        }
        w2 {
            margin-top: 0;
            padding-right: 5px;
            padding-left: 5px;
            color: #61615B;
            font-size: 18px;
            font-style: normal;
            font-family: Verdana, Geneva, sans-serif;
        }
        h1 {
            margin-top: 0;
            padding-right: 5px;
            padding-left: 5px;
            color: #595754;
            font-size: 20px;
            font-weight: normal;
            font-family: Verdana, Geneva, sans-serif;
        }
        h2 {
            margin-top: 0;
            padding-right: 5px;
            padding-left: 5px;
            color: #61615B;
            font-size: 15px;
            font-weight: normal;
            font-style: normal;
            font-family: Verdana, Geneva, sans-serif;
        }
        
        h3 {
            margin-top: 0;
            padding-right: 5px;
            padding-left: 5px;
            color: #474747;
            font-size: 19px;
            font-weight: bold;
            font-family: Verdana, Geneva, sans-serif;
        }
        }
        mark {
            background-color: #B5DA8F
        }
        .examples {
            width: 80%;
            padding-left: 25px;
            padding-bottom: 10px;
            padding-top: 5px;
            padding-right: 0;
        }
        .ifont {
            color: #3E3E3E;
            font-family: Verdana, Geneva, sans-serif;
            font-size: 12px;
            text-align: left;
        }
        .efont {
            color: #6F6F6F;
            font-family: Verdana, Geneva, sans-serif;
            font-size: 14px;
            text-align: left;
        }
        .nfont {
            color: #6F6F6F;
            font-family: Verdana, Geneva, sans-serif;
            font-size: 10px;
            text-align: left;
        }
        .notasa {
            float: right;
            width: 50%;
            padding-right: 60px;
            font-size: 12px;
            color: #7B7B7B;
        }
        ma {
            margin-top: 0;
            color: #636363;
        }
        a img { 
            border: none;
        }
        .wrds {
            float: left;
            width: 95%;
            padding: 10px 0;
            padding-left: 25px;
            padding-bottom: 120px;
            font-family: Verdana, Geneva, sans-serif;
            font-size: 14px;
            font-weight: bolder;
            color: #666;
        }
        .wrdimg {
            font-family: Verdana, Geneva, sans-serif;
            font-size: 14px;
            font-weight: bold;
            color: #666;
        }
        .wrdstable {
            font-family: Verdana, Geneva, sans-serif;
            font-size: 13px;
            font-weight: bold;
            color: #666;
        }
        .side {
            width: 3px;
        }
        body {
            margin-left: 20px;
            margin-top: 10px;
            margin-right: 10px;
            margin-bottom: 10px;
        }
        </style>
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
        #images
        cd "$DM_tlt/words/images"
        cnt=`ls -1 *.jpg 2>/dev/null | wc -l`
        if [ $cnt != 0 ]; then
            cd $DT/mkhtml/images/
            ls *.png | sed 's/\.png//g' > $DT/mkhtml/nimg
            cd $DT/mkhtml
            echo '<table width="90%" align="center" border="0" class="wrdimg">' >> pdf_doc
            n=1
            while [ $n -le "$(cat nimg | wc -l)" ]; do
                    if [ -f nnn ]; then
                    n=$(cat nnn)
                    fi
                    nn=$(($n + 1))
                    nnn=$(($n + 2))
                    d1m=$(cat nimg | sed -n "$n","$nn"p | sed -n 1p)
                    d2m=$(cat nimg | sed -n "$n","$nn"p | sed -n 2p)
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
        #words
        cd $DT/mkhtml
        n=1
        while [ $n -le "$(cat $iw | wc -l)" ]; do
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
        #sentences
        n=1
        while [ $n -le "$(cat s.inx.l | wc -l)" ]; do
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
        #html
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
        wkhtmltopdf -s A4 -O Portrait --ignore-load-errors pdf_doc.html tmp.pdf
        mv -f tmp.pdf "$pdf"
        rm -fr pdf_doc $DT/mkhtml $DT/*.x $DT/*.l

    else
        exit 0
    fi
fi

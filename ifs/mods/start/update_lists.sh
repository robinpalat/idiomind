#!/bin/bash
# -*- ENCODING: UTF-8 -*-

[ -z "$DM" ] && source /usr/share/idiomind/ifs/c.conf
source "$DS/ifs/mods/cmns.sh"
log="$DC_s/log"
items=$(mktemp "$DT/w9.XXXX")
words=$(grep -o -P '(?<=w9.).*(?=\.w9)' "${log}" |tr '|' '\n' \
| sort | uniq -dc | sort -n -r | sed 's/ \+/ /g')
sentences=$(grep -o -P '(?<=s9.).*(?=\.s9)' "${log}" |tr '|' '\n' \
| sort | uniq -dc | sort -n -r | sed 's/ \+/ /g')
img1='/usr/share/idiomind/images/1.png'
img2='/usr/share/idiomind/images/2.png'
img3='/usr/share/idiomind/images/3.png'
img0='/usr/share/idiomind/images/0.png'
[ ! -e "${DC_tlt}/1.cfg" ] && touch "${DC_tlt}/1.cfg"
[ ! -e "${DC_tlt}/6.cfg" ] && touch "${DC_tlt}/6.cfg"
[ ! -e "${DC_tlt}/9.cfg" ] && touch "${DC_tlt}/9.cfg"

for n in {1..100}; do
    if [[ $(sed -n ${n}p <<<"${words}" |awk '{print ($1)}') -ge 3 ]]; then
        fwk=$(sed -n ${n}p <<<"${words}" |awk '{print ($2)}')
        [ -n "${fwk}" ] && echo "${fwk}" >> "${items}"
    fi
    if [[ $(sed -n ${n}p <<<"${sentences}" |awk '{print ($1)}') -ge 1 ]]; then
        fwk=$(sed -n ${n}p <<<"${sentences}" |cut -c 4-)
        [ -n "${fwk}" ] && echo "${fwk}" >> "${items}"
    fi
done

sed -i '/^$/d' "${items}"
f_lock "$DT/co_lk"
dir="$DM_tl/"
topics="${DM_tl}/.1.cfg"
lstp="${items}"
export dir topics lstp img0 img1 img2 img3
python <<PY
import os
topics = os.environ['topics']
topics = [line.strip() for line in open(topics)]
dir = os.environ['dir']
img0 = os.environ['img0']
img1 = os.environ['img1']
img2 = os.environ['img2']
img3 = os.environ['img3']
lstp = os.environ['lstp']
lstp = [line.strip() for line in open(lstp)]
for tpc in topics:
    cfg1 = dir + tpc + "/.conf/1.cfg"
    if os.path.exists(cfg1):
        try:
            cont = str
            cfg = dir + tpc + "/.conf/id.cfg"
            cfg5 = dir + tpc + "/.conf/5.cfg"
            cfg6 = dir + tpc + "/.conf/6.cfg"
            cfg7 = dir + tpc + "/.conf/7.cfg"
            cfg9 = dir + tpc + "/.conf/9.cfg"
            log1 = dir + tpc + "/.conf/practice/log1"
            log2 = dir + tpc + "/.conf/practice/log2"
            log3 = dir + tpc + "/.conf/practice/log3"
            cfg = [line.strip() for line in open(cfg)]
            try:
                cont = (cfg[18].split('set_1="'))[1].split('"')[0]
            except:
                try:
                    cont = (cfg[17].split('set_1="'))[1].split('"')[0]
                except:
                    pass
            if cont == 'TRUE':
                cont = True
            else:
                cont = False
            if os.path.exists(cfg1) and not os.path.exists(cfg7):
                cont = True
            if not os.path.exists(dir + tpc + "/.conf/practice") or not os.path.exists(cfg9):
                cont = False
            if cont == True:
                items = [line.strip() for line in open(cfg1)]
                marks = [line.strip() for line in open(cfg6)]
                steps = [line.strip() for line in open(cfg9)]
                chk = False
                if len(steps) > 3:
                    chk = True
                f = open(cfg5, "w")
                for item in items:
                    if item in marks:
                        i="<b><big>"+item+"</big></b>"
                    else:
                        i=item
                    if item in lstp:
                        chk = True
                    if item in log3:
                        f.write("FALSE\n"+i+"\n"+img3+"\n")
                    elif item in log2:
                        f.write("FALSE\n"+i+"\n"+img2+"\n")
                    elif item in log1:
                        print 'check - > ' + item
                        f.write(chk+"\n"+i+"\n"+img1+"\n")
                    else:
                        f.write("FALSE\n"+i+"\n"+img0+"\n")
                f.close()
        except:
            print 'err -> ' + tpc
PY
rm -f "$DT/co_lk"
if [ $(date +%d) = 28 -o $(date +%d) = 14 ]; then
rm "$log"; touch "$log"; fi
rm -f "$items"
echo "--updated lists"
exit

#!/bin/bash
# -*- ENCODING: UTF-8 -*-

[ -z "$DM" ] && source /usr/share/idiomind/default/c.conf
source "$DS/ifs/mods/cmns.sh"
[ ! -e "$DC_s/log" ] && exit 1 || log="$DC_s/log"
items=$(mktemp "$DT/w1.XXXX")
words=$(grep -o -P '(?<=w1.).*(?=\.w1)' "${log}" |tr '|' '\n' \
|sort |uniq -dc |sort -n -r |sed 's/ \+/ /g')
sentences=$(grep -o -P '(?<=s9.).*(?=\.s9)' "${log}" |tr '|' '\n' \
|sort |uniq -dc |sort -n -r |sed 's/ \+/ /g')
topics="$(cd "$DM_tl"; find ./ -maxdepth 1 -mtime -80 -type d ! \
-path "./.share" -exec ls -tNd {} + |sed 's|\./||g'|sed '/^$/d')"
check_file "${DC_tlt}/1.cfg" "${DC_tlt}/6.cfg" "${DC_tlt}/9.cfg"
img1="$DS/images/1.png"
img2="$DS/images/2.png"
img3="$DS/images/3.png"
img0="$DS/images/0.png"

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
lstp="${items}"
export dir topics lstp img0 img1 img2 img3

python <<PY
import os
topics = os.environ['topics']
dir = os.environ['dir']
img0 = os.environ['img0']
img1 = os.environ['img1']
img2 = os.environ['img2']
img3 = os.environ['img3']
lstp = os.environ['lstp']
lstp = [line.strip() for line in open(lstp)]
topics = topics.split ('\n')
for tpc in topics:
    cfg1 = dir + tpc + "/.conf/1.cfg"
    if os.path.exists(cfg1):
        try:
            cont = str
            cfg = dir + tpc + "/.conf/10.cfg"
            cfg5 = dir + tpc + "/.conf/5.cfg"
            cfg6 = dir + tpc + "/.conf/6.cfg"
            cfg7 = dir + tpc + "/.conf/7.cfg"
            cfg9 = dir + tpc + "/.conf/9.cfg"
            log1 = dir + tpc + "/.conf/practice/log1"
            log2 = dir + tpc + "/.conf/practice/log2"
            log3 = dir + tpc + "/.conf/practice/log3"
            log1 = [line.strip() for line in open(log1)]
            log2 = [line.strip() for line in open(log2)]
            log3 = [line.strip() for line in open(log3)]
            cfg = [line.strip() for line in open(cfg)]
            try:
                auto_mrk = (cfg[9].split('acheck="'))[1].split('"')[0]
            except:
                try:
                    auto_mrk = (cfg[10].split('acheck="'))[1].split('"')[0]
                except:
                    pass
                    
            if auto_mrk == 'TRUE':
                auto_mrk = True
            else:
                auto_mrk = False
            if os.path.exists(cfg1) and not os.path.exists(cfg7):
                cont = True
            if not os.path.exists(dir + tpc + "/.conf/practice"):
                cont = False
            if os.path.exists(cfg9):
                steps = [line.strip() for line in open(cfg9)]
            else:
                steps = []
            if cont == True:
                items = [line.strip() for line in open(cfg1)]
                marks = [line.strip() for line in open(cfg6)]
                chk = 'FALSE'
                if len(steps) > 3 and auto_mrk == True:
                    chk = 'TRUE'
                f = open(cfg5, "w")
                for item in items:
                    if item in marks:
                        i="<b><big>"+item+"</big></b>"
                    else:
                        i=item
                    if item in lstp and auto_mrk == True:
                        chk = 'TRUE'
                    if item in log3:
                        f.write("FALSE\n"+i+"\n"+img3+"\n")
                    elif item in log2:
                        f.write("FALSE\n"+i+"\n"+img2+"\n")
                    elif item in log1:
                        print chk + ' check -> ' + item
                        f.write(chk+"\n"+i+"\n"+img1+"\n")
                    else:
                        f.write("FALSE\n"+i+"\n"+img0+"\n")
                f.close()
        except:
            print 'err -> ' + tpc
PY

[ $(date +%d) = 1 -o $(date +%d) = 14 ] && rm "$log"; touch "$log"
cleanups "$items" "$DT/co_lk"
echo "--updated lists"
touch "$DM_tl/.share/data/pre_data"
exit

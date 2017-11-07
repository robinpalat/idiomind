#!/bin/bash
# -*- ENCODING: UTF-8 -*-

[ -z "$DM" ] && source /usr/share/idiomind/default/c.conf
source "$DS/ifs/cmns.sh"
check_list > "$DM_tl/.share/2.cfg"
echo -e "\n------------- updating lists..."
[ ! -e "$DC_s/log" ] && exit 1 || log="$DC_s/log"
items=$(mktemp "$DT/w1.XXXX")
words=$(grep -o -P '(?<=w1.).*(?=\.w1)' "${log}" |tr '|' '\n' \
|sort |uniq -dc |sort -n -r |sed 's/ \+/ /g')
sentences=$(grep -o -P '(?<=s1.).*(?=\.s1)' "${log}" |tr '|' '\n' \
|sort |uniq -dc |sort -n -r |sed 's/ \+/ /g')
topics="$(cat "$DM_tl/.share/2.cfg"|head -n20)"
check_file "${DC_tlt}/1.cfg" "${DC_tlt}/6.cfg" "${DC_tlt}/9.cfg"
# grep -o -P '(?<=w1.).*(?=\.w1)' "${log}" |tr '|' '\n' |sort |uniq
img1="$DS/images/1.png"
img2="$DS/images/2.png"
img3="$DS/images/3.png"
img0="$DS/images/0.png"
dir="$DM_tl/"

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

if grep '^$' "${items}"; then sed -i '/^$/d' "${items}"; fi
f_lock "$DT/co_lk"
lstp="${items}"
export dir topics lstp img0 img1 img2 img3
cleanups "$DM_tl/.share/5.cfg"

python <<PY
import os, re, subprocess
from os import path
from datetime import datetime, timedelta
topics = os.environ['topics']
dir = os.environ['dir']
img0 = os.environ['img0']
img1 = os.environ['img1']
img2 = os.environ['img2']
img3 = os.environ['img3']
lstp = os.environ['lstp']
lstp = [line.strip() for line in open(lstp)]
topics = topics.split('\n')
days_ago = datetime.now() - timedelta(days=10)
for tpc in topics:
    cnfg_dir = dir + tpc + "/.conf/"
    cfg1 = cnfg_dir + "1.cfg"
    if os.path.exists(cfg1):
        #try:
            cont = str
            log1m = datetime.fromtimestamp(path.getctime(cnfg_dir+"practice/log1"))
            log1 = [line.strip() for line in open(cnfg_dir+"practice/log1")]
            log2m = datetime.fromtimestamp(path.getctime(cnfg_dir+"practice/log2"))
            log2 = [line.strip() for line in open(cnfg_dir+"practice/log2")]
            log3m = datetime.fromtimestamp(path.getctime(cnfg_dir+"practice/log3"))
            log3 = [line.strip() for line in open(cnfg_dir+"practice/log3")]
            cfg = [line.strip() for line in open(cnfg_dir+"10.cfg")]
            items = [line.strip() for line in open(cnfg_dir+"0.cfg")]

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
            if os.path.exists(cfg1) and not os.path.exists(cnfg_dir+"7.cfg"):
                cont = True
            if not os.path.exists(dir + tpc + "/.conf/practice"):
                cont = False
            if os.path.exists(cnfg_dir+"9.cfg"):
                steps = [line.strip() for line in open(cnfg_dir+"9.cfg")]
            else:
                steps = []
            steps=len(steps)
            
            f = open(cnfg_dir+"/8.cfg")
            stts = [line.rstrip('\n') for line in f]
            topractice = open(dir+"/.share/5.cfg", "a")
            l1m = False
            l2m = False
            l3m = False
            if log1m < days_ago:
                l1m = True
            if log2m < days_ago:
                l2m = True
            if log3m < days_ago:
                l3m = True
            if (int(stts[0]) == 5 or int(stts[0]) == 6):
                if (len(log3) > 0 or len(log2) > 0):
                    topractice.write(tpc+"|6\n")
                    print "- back to practice: "+tpc
                elif l3m == True and l2m == True and l1m == True:
                    topractice.write(tpc+"|5\n")
                    print "- to practice: "+tpc
            topractice.close()

            cfg1len = 0
            if cont == True:
                cfg1 = [line.strip() for line in open(cfg1)]
                marks = [line.strip() for line in open(cnfg_dir+"6.cfg")]
                f = open(cnfg_dir+"5.cfg", "w")
                for item in items:
                    item = item.replace('}', '}\n')
                    fields = re.split('\n',item)
                    item = (fields[0].split('trgt{'))[1].split('}')[0]
                    if item in cfg1:
                        srce = (fields[1].split('srce{'))[1].split('}')[0]
                        if item in marks:
                            i="<b><big>"+item+"</big></b>"
                        else:
                            i=item
                        if item in lstp and auto_mrk == True and steps > 3:
                            chk = 'TRUE'
                        else:
                            chk = 'FALSE'
                        if item in log3:
                            f.write(img3+"\n"+i+"\nFALSE\n"+srce+"\n")
                        elif item in log2:
                            f.write(img2+"\n"+i+"\nFALSE\n"+srce+"\n")
                        elif item in log1:
                            print chk + ' -> ' + item
                            f.write(img1+"\n"+i+"\n"+chk+"\n"+srce+"\n")
                        else:
                            f.write(img0+"\n"+i+"\nFALSE\n"+srce+"\n")
                        if chk == 'TRUE':
                            cfg1len=cfg1len+1
                f.close()
                if len(cfg1) == cfg1len and len(cnfg_dir+"0.cfg") > 15:
                    subprocess.Popen(['/usr/share/idiomind/mngr.sh %s %s' % ('mark_to_learnt_ok', '"'+tpc+'"')], shell=True)
                    print 'mark_as_learnt -> ' + tpc
        #except:
            #print 'err -> ' + tpc
PY

[ $(date +%d) = 1 -o $(date +%d) = 14 ] && rm "$log"; touch "$log"
"$DS/mngr.sh" mkmn 1 &
cleanups "$items" "$DT/co_lk"
echo -e "------------- lists updated\n"
exit

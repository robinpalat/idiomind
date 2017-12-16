#!/bin/bash
# -*- ENCODING: UTF-8 -*-

[ -z "$DM" ] && source /usr/share/idiomind/default/c.conf
source "$DS/ifs/cmns.sh"
echo -e "\n--- updating lists..."

while read -r tpc; do
	dir="$DM_tl/${tpc}/.conf"; unset stts tpc
	stts=$(sed -n 1p "${dir}/stts")
	if [ ${stts} != 12 ]; then
		mv -f "${dir}/stts"  "${dir}/stts.bk"; echo 12 > "${dir}/stts"
	fi
done < <(cd "$DM_tl"; find ./ -maxdepth 1 -mtime +80 -type d \
-not -path '*/\.*' -exec ls -tNd {} + |sed 's|\./||g;/^$/d')

[ ! -e "$DC_s/log" ] && exit 1 || log="$DC_s/log"
items=$(mktemp "$DT/w1.XXXX")
words=$(grep -o -P '(?<=w1.).*(?=\.w1)' "${log}" |tr '|' '\n' \
|sort |uniq -dc |sort -n -r |sed 's/ \+/ /g')
sentences=$(grep -o -P '(?<=s1.).*(?=\.s1)' "${log}" |tr '|' '\n' \
|sort |uniq -dc |sort -n -r |sed 's/ \+/ /g')
topics="$(cdb "${shrdb}" 5 topics|head -n30)"
echo 

# grep -o -P '(?<=w1.).*(?=\.w1)' "${log}" |tr '|' '\n' |sort |uniq
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

export dir topics lstp shrdb
cleanups "$DM_tl/.share/index"

python <<PY
import os, re, subprocess, sqlite3, sys
from os import path
from datetime import datetime, timedelta
reload(sys)
sys.setdefaultencoding('utf8')
topics = os.environ['topics']
dir = os.environ['dir']
lstp = os.environ['lstp']
shrdb = os.environ['shrdb']
lstp = [line.strip() for line in open(lstp)]
topics = topics.split('\n')
days_ago = datetime.now() - timedelta(days=10)
shr_db = sqlite3.connect(shrdb)
shr_db.text_factory = str
cur_shr_db = shr_db.cursor()
cur_shr_db.execute("delete from T5")
cur_shr_db.execute("delete from T6")
for tpc in topics:
    cnfg_dir = dir + tpc + "/.conf/"
    tpcdb = cnfg_dir + "tpc"
    tpc_db = sqlite3.connect(tpcdb)
    tpc_db.text_factory = str
    cur_tpc_db = tpc_db.cursor()
    auto_mrk = cur_tpc_db.execute("select acheck from config")
    auto_mrk = [i[0] for i in auto_mrk]
    marks = cur_tpc_db.execute("select list from marks")
    marks = cur_tpc_db.fetchall()
    marks = [i[0] for i in marks]
    learn = cur_tpc_db.execute("select list from learning")
    learn = cur_tpc_db.fetchall()
    learn = [i[0] for i in learn]
    reviews = cur_tpc_db.execute("select * from reviews")
    reviews = cur_tpc_db.fetchall()
    reviews = [i[0] for i in reviews]
    try:
        cont = str
        f = open(cnfg_dir+"/stts")
        stts = [line.rstrip('\n') for line in f]
        stts = stts[0]
        log1m = datetime.fromtimestamp(path.getctime(cnfg_dir+"practice/log1"))
        log1 = [line.strip() for line in open(cnfg_dir+"practice/log1")]
        log2m = datetime.fromtimestamp(path.getctime(cnfg_dir+"practice/log2"))
        log2 = [line.strip() for line in open(cnfg_dir+"practice/log2")]
        log3m = datetime.fromtimestamp(path.getctime(cnfg_dir+"practice/log3"))
        log3 = [line.strip() for line in open(cnfg_dir+"practice/log3")]
        items = [line.strip() for line in open(cnfg_dir+"data")]
        reviews = len(reviews)
        if auto_mrk[0] == 'TRUE':
            auto_mrk = True
        else:
            auto_mrk = False
        if (stts == '3' or stts == '4' or stts == '7' \
        or stts == '8' or stts == '9' or stts == '10' ):
            cont = True
        if not os.path.exists(dir + tpc + "/.conf/practice"):
            cont = False
        l1m = False
        l2m = False
        l3m = False
        if log1m < days_ago:
            l1m = True
        if log2m < days_ago:
            l2m = True
        if log3m < days_ago:
            l3m = True
        if (stts == '5' or stts == '6'):
            if (len(log3) > 0 or len(log2) > 0):
                cur_shr_db.execute("insert into T6 values (?)", (tpc,))
                shr_db.commit()
                print "- back to practice: "+tpc
            elif l3m == True and l2m == True and l1m == True:
                cur_shr_db.execute("insert into T5 values (?)", (tpc,))
                shr_db.commit()
                print "- to practice: "+tpc

		cfg1len = 0
		if cont == True:
			index = open(cnfg_dir+"index", "w")
			for item in items:
				item = item.replace('}', '}\n')
				fields = re.split('\n',item)
				item = (fields[0].split('trgt{'))[1].split('}')[0]
				if item in learn:
					srce = (fields[1].split('srce{'))[1].split('}')[0]
					if item in marks:
						i="<b><big>"+item+"</big></b>"
					else:
						i=item
					if item in lstp and auto_mrk == True and reviews > 3:
						chk = 'TRUE'
					else:
						chk = 'FALSE'
					if item in log3:
						index.write("<span color='#AE3259'>"+i+"</span>\nFALSE\n"+srce+"\n")
					elif item in log2:
						index.write("<span color='#C15F27'>"+i+"</span>\nFALSE\n"+srce+"\n")
					elif item in log1:
						print chk + ' -> ' + item
						index.write("<span color='#4C8C12'>"+i+"</span>\n"+chk+"\n"+srce+"\n")
					else:
						index.write(i+"\nFALSE\n"+srce+"\n")
					if chk == 'TRUE':
						cfg1len=cfg1len+1
			index.close()
			if len(learn) == cfg1len and len(cnfg_dir+"data") > 15:
				subprocess.Popen(['/usr/share/idiomind/mngr.sh %s %s' % ('mark_to_learnt_ok', '"'+tpc+'"')], shell=True)
				print 'mark_as_learnt -> ' + tpc
    except:
        print 'err -> ' + tpc
shr_db.close()      
PY

[ $(date +%d) = 1 -o $(date +%d) = 14 ] && rm "$log"; touch "$log"
"$DS/mngr.sh" mkmn 1 &
cleanups "$items" "$DT/co_lk"
echo -e "--- lists updated\n"
exit

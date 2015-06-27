#!/bin/bash
# -*- ENCODING: UTF-8 -*-
exit 1
[ -z "$DM" ] && source /usr/share/idiomind/ifs/c.conf
source "$DS/ifs/mods/cmns.sh"
DSV="$DM_t/backup"

xml="<?xml version='1.0' encoding='UTF-8'?>
<xsl:stylesheet version='1.0'
xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
xmlns:atom='http://www.w3.org/2005/Atom'>
<xsl:output method='text'/>
<xsl:template match='/'>
<xsl:for-each select='/rss/channel/item'>
<xsl:value-of select='id'/><xsl:text></xsl:text>
</xsl:for-each>
</xsl:template>
</xsl:stylesheet>"


update() {

    id="$(grep -o 'usrid="[^"]*' "$DC_s/3.cfg" |grep -o '[^"]*$')"
    feed="http://55.2fh.co/idiomind/?rss=${id}.${1}"
    items="$(xsltproc - "$feed" <<<"$xml" 2> /dev/null)"
    items="$(echo "${items}" |sed '/^$/d')"
    
    while read -r item; do
    
        trgt=`grep -oP '(?<=trgt={).*(?=})' <<<"${item}"`
        srce=`grep -oP '(?<=srce={).*(?=})' <<<"${item}"`
        exmp=`grep -oP '(?<=exmp={).*(?=})' <<<"${item}"`
        defn=`grep -oP '(?<=defn={).*(?=})' <<<"${item}"`
        id=`grep -oP '(?<=id=\[).*(?=\])' <<<"${item}"`
        
        [ -z "$item" ] && continue

        if ! grep -F "id=[${id}]" "${DC_tlt}/0.cfg"; then
        
            if grep -F "id=[${trgt}]" "${DC_tlt}/0.cfg"; then
            
                echo "$trgt" >> $HOME/Desktop/modes
            else 
                echo "$trgt" >> $HOME/Desktop/addes
        fi
        
        fi
        
    done < <(xsltproc - "$feed" <<<"$xml" 2> /dev/null)

} >/dev/null 2>&1


while read tps; do

    name=$(sed -n 1p "$DSV/$tps.id" \
    | grep -o name=\"[^\"]* | grep -o '[^"]*$')
    ls=$(sed -n 2p "$DSV/$tps.id" \
    | grep -o language_source=\"[^\"]* | grep -o '[^"]*$')
    lt=$(sed -n 3p "$DSV/$tps.id" \
    | grep -o language_target=\"[^\"]* | grep -o '[^"]*$')
    c=$(sed -n 6p "$DSV/$tps.id" \
    | grep -o category=\"[^\"]* | grep -o '[^"]*$')
    id=$(sed -n 7p "$DSV/$tps.id" \
    | grep -o link=\"[^\"]* | grep -o '[^"]*$')
    lgs=$(lnglss $_lgsl)

    update "${tps}"

done < <(cd "$DM_t/saved"; ls -t *.id | sed 's/\.id//g')


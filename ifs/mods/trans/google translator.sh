#!/bin/bash
# -*- ENCODING: UTF-8 -*-
source "$HOME/.config/idiomind/addons/gts.cfg"
if [ "$set1" = TRUE ]; then
result=$(curl -s -i --user-agent "" -d "sl=$2" -d "tl=$3" --data-urlencode text="$1" https://translate.google.com)
encoding=$(awk '/Content-Type: .* charset=/ {sub(/^.*charset=["'\'']?/,""); sub(/[ "'\''].*$/,""); print}' <<<"$result")
iconv -f "$encoding" <<<"$result" | awk 'BEGIN {RS="</div>"};/<span[^>]* id=["'\'']?result_box["'\'']?/' | html2text -utf8
fi

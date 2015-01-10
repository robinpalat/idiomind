#!/bin/bash
DS=/usr/share/idiomind
DADOS=($*)
QTD=$((${#DADOS[@]}-1))
for i in $(seq 0 $QTD)
do
    CMD[$i]=${DADOS[$i]}
done
CMD="${CMD[@]}"

if echo "$CMD" | grep "Google translation service"; then
	$DS/addons/"Google_translation_service"/cnf
elif echo "$CMD" | grep "Weekly Report"; then
	$DS/addons/"Stats"/rprt C
elif echo "$CMD" | grep "Learning with News"; then
	$DS/addons/"Learning_with_news"/cnf
elif echo "$CMD" | grep "Dictionary"; then
	$DS/addons/Dics/dict 1 1 cnf
elif echo "$CMD" | grep "User data"; then
	$DS/addons/"User_data"/t_bd.sh
fi

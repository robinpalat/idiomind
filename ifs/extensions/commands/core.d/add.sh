#!/bin/bash
# -*- ENCODING: UTF-8 -*-
# core wrapper: add ("$1"/"$2" son los antiguos "$2"/"$3").
exec "$DS/add.sh" new_item '__cmd__' "$(sed -n 1p "$DC_s/tpc")" "$1" "$2"

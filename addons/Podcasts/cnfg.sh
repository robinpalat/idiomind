#!/bin/bash
# -*- ENCODING: UTF-8 -*-

cd "$(dirname "$0")"

if [ $1 = 'viewer' ]; then

export item="$3"

./podcasts viewer & exit

elif [ $1 = 'remove_item' ]; then

./podcasts remove_item & exit

elif [ $1 = 'delete_all' ]; then

./podcasts delete_all & exit

else

./podcasts & exit

fi

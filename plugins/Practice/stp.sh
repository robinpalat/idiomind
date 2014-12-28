#!/bin/bash
killall lrng
kill -9 $(pgrep -f "/lib32/yad_idiomind --form ")
exit 1

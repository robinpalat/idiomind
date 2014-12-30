#!/bin/bash
killall lrng
kill -9 $(pgrep -f "yad --form ")
exit 1

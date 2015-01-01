#!/bin/bash
killall lrng
killall vms
kill -9 $(pgrep -f "yad --form ")
exit 1

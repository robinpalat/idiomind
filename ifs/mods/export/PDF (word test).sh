#!/bin/bash
f=2
export f
$(dirname "$0")/PDF.sh "$@"

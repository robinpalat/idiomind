#!/bin/bash
# -*- ENCODING: UTF-8 -*-

source /usr/share/idiomind/ifs/c.conf
du -b -h "$DM" | tail -1 | awk '{print ($1)}' > "$DC_a/1.cfg"


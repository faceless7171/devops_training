#!/bin/bash

set -e
cat <<- EOF
Welcome - $(date +'%A, %e %B %Y, %r')
Load avg: $(cat /proc/loadavg)
Uptime: $(cat /proc/uptime)
Memory: $(cat /proc/meminfo | grep MemFree | awk {'print $2'})kB (Free) / $(cat /proc/meminfo | grep MemTotal | awk {'print $2'})kB (Total))
Processes: $(ps ax | wc -l | tr -d " ")
IPs: $(ip a | grep glo | awk '{print $2}' | head -1 | cut -f1 -d/) and $(wget -q -O - http://icanhazip.com/ | tail)
EOF

#!/bin/bash
TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"
UPTIME="$(uptime -p)"
CPU="$(mpstat 1 1 | awk '/Average/ {print 100-$NF"%"}')"
MEMORY=$(free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2}')
DISK=$(df -h / | awk 'NR==2{print $5}')
TOP3=$(ps -eo pid,comm,%cpu --sort=-%cpu | head -n 4 | tail -n 3)

cat <<REPORT
===== System Report =====
Timestamp: $TIMESTAMP
Uptime: $UPTIME
CPU: $CPU
Memory: $MEMORY
Disk: $DISK
Top 3 CPU processes:
$TOP3
=========================
REPORT
#!/bin/bash

LOG_PATH="/var/log/system_report.log"

# Ensure log file exists
log_file() {
    if [ ! -f "$LOG_PATH" ]; then
        sudo touch "$LOG_PATH"
        echo "Created log file."
    else
        echo "File present."
    fi
}

# file should be owned by user
change_log_ownership() {
    chown devops_intern:devops_intern "$LOG_PATH" 2>/dev/null
}


# Get CPU Usage
get_cpu() {
    local raw idle
    raw=$(mpstat 1 1 | grep "Average")
    idle=$(echo "$raw" | sed 's/.* //')     
    printf "%.2f%%" "$(echo "100 - $idle" | bc)"
}


# Get Memory Usage
get_memory() {
    local mem total used
    mem=$(free -m | sed -n '2p' | sed 's/  */ /g')
    total=$(echo "$mem" | cut -d " " -f2)
    used=$(echo "$mem"  | cut -d " " -f3)
    printf "%.2f%%" "$(echo "$used*100/$total" | bc -l)"
}

# Get Disk Usage
get_disk() {
    df -h / | sed -n '2p' | sed 's/  */ /g' | cut -d " " -f5
}


# Get Top 3 CPU Processes
get_top_processes() {
    ps -eo pid,comm,%cpu --sort=-%cpu | sed -n '2,4p'
}

# Main Report Function
main() {
    log_file
    change_log_ownership
    
    local timestamp uptime cpu memory disk top3

    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    uptime=$(uptime -p)
    cpu=$(get_cpu)
    memory=$(get_memory)
    disk=$(get_disk)
    top3=$(get_top_processes)

    cat <<EOF
===== System Report =====
Timestamp: $timestamp
Uptime: $uptime
CPU: $cpu
Memory: $memory
Disk: $disk
Top 3 CPU processes:
$top3
=========================
EOF
}

# Script Execution

main



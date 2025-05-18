#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
CYAN='\033[1;36m'
RESET='\033[0m'
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

separator="================================================================================"

print_header() {
    echo -e "\n${CYAN}${BOLD}$1${RESET}"
    echo "$separator"
}

# ------------------------ OS Info ------------------------

print_header "🖥️  OS Info"

if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo -e "${GREEN}${NAME} ${VERSION}${RESET}"
else
    uname -a
fi

# ------------------------ CPU Uptime ------------------------

read system_uptime idle_time < /proc/uptime

total_seconds=${system_uptime%.*}
fractional_part=${system_uptime#*.}

days=$((total_seconds / 86400))
hours=$(((total_seconds % 86400) / 3600))
minutes=$(((total_seconds % 3600) / 60))
seconds=$((total_seconds % 60))

print_header "⏱️  CPU Uptime"
[[ $days -gt 0 ]] && echo "$days days"
[[ $hours -gt 0 ]] && echo "$hours hours"
[[ $minutes -gt 0 ]] && echo "$minutes minutes"
[[ $seconds -gt 0 || $fractional_part -ne 0 ]] && echo "$seconds.${fractional_part} seconds"

# ------------------------ CPU Usage ------------------------

top_output=$(top -bn1)

cpu_idle=$(echo "$top_output" | grep "Cpu(s)" | sed 's/.*, *\([0-9.]*\)%* id.*/\1/')
cpu_usage=$(awk -v idle="$cpu_idle" 'BEGIN { printf("%.1f", 100 - idle) }')

print_header "🧠 CPU Usage"
echo -e "Usage         : ${GREEN}${cpu_usage}%${RESET}"

# ------------------------ Memory Usage ------------------------

read total_memory available_memory <<< $(awk '/MemTotal/ {t=$2} /MemAvailable/ {a=$2} END {print t, a}' /proc/meminfo)
used_memory=$((total_memory - available_memory))

used_memory_percent=$(awk -v u=$used_memory -v t=$total_memory 'BEGIN { printf("%.1f", (u / t) * 100) }')
free_memory_percent=$(awk -v a=$available_memory -v t=$total_memory 'BEGIN { printf("%.1f", (a / t) * 100) }')

total_memory_mb=$(awk -v t=$total_memory 'BEGIN { printf("%.1f", t/1024) }')
used_memory_mb=$(awk -v u=$used_memory 'BEGIN { printf("%.1f", u/1024) }')
available_memory_mb=$(awk -v a=$available_memory 'BEGIN { printf("%.1f", a/1024) }')

print_header "🧠 Memory Usage"
printf "Total Memory    : ${YELLOW}%-10s MB${RESET}\n" "$total_memory_mb"
printf "Used Memory     : ${YELLOW}%-10s MB${RESET} (%s%%)\n" "$used_memory_mb" "$used_memory_percent"
printf "Free/Available  : ${YELLOW}%-10s MB${RESET} (%s%%)\n" "$available_memory_mb" "$free_memory_percent"

# ------------------------ Disk & Inode Usage ------------------------

print_header "💾 Disk & Inode Usage"

df -hT | awk 'NR==1 || $2 ~ /ext4|xfs|btrfs/ {printf "%-20s %-6s %-8s %-8s %-8s %-5s\n", $1, $2, $3, $4, $5, $7}'

echo -e "\n${CYAN}${BOLD}Inode Usage:${RESET}"
df -ih | awk 'NR==1 || $1 ~ /\// { printf "%-20s %-8s %-8s %-8s %-5s\n", $1, $2, $3, $4, $5 }'

# ------------------------ Top Processes ------------------------

print_header "🔥 Top 5 Processes by CPU"
ps aux --sort=-%cpu | awk 'NR==1 || NR<=6 { printf "%-10s %-6s %-5s %-5s %s\n", $1, $2, $3, $4, $11 }'

print_header "🧠 Top 5 Processes by Memory"
ps aux --sort=-%mem | awk 'NR==1 || NR<=6 { printf "%-10s %-6s %-5s %-5s %s\n", $1, $2, $3, $4, $11 }'

# ------------------------ Recently Failed Services ------------------------

print_header "🚨 Recently Failed Services (Unique, Last 1 Hour)"

recent_failed=$(journalctl --since "1 hour ago" -p 3 -o cat --no-pager | grep -i "failed" | awk -F: '{print $1}' | sort | uniq)

if [ -n "$recent_failed" ]; then
    echo -e "${RED}Recent failed services (unique):${RESET}"
    for svc in $recent_failed; do
        latest_failure=$(journalctl --since "1 hour ago" -p 3 -u "$svc" --no-pager | grep -i "failed" | tail -1)
        echo -e "${YELLOW}$svc:${RESET} $latest_failure"
    done
else
    echo -e "${GREEN}No failed services in the last hour.${RESET}"
fi

print_header "🔁 Currently Running Services"
systemctl list-units --type=service --state=running | awk 'NR==1 || /service/ { print }'

# ------------------------ OS Patch Check ------------------------

print_header "🛡️  OS Patch/Updates Available"

if command -v apt &>/dev/null; then
    updates=$(apt list --upgradable 2>/dev/null | grep -v "Listing...")
    if [ -n "$updates" ]; then
        echo -e "${YELLOW}Available updates:${RESET}"
        echo "$updates" | awk '{print $1}' | sort
    else
        echo -e "${GREEN}System is up to date.${RESET}"
    fi
elif command -v dnf &>/dev/null; then
    updates=$(dnf check-update 2>/dev/null)
    if [ $? -eq 100 ]; then
        echo -e "${YELLOW}Available updates:${RESET}"
        echo "$updates"
    else
        echo -e "${GREEN}System is up to date.${RESET}"
    fi
elif command -v yum &>/dev/null; then
    updates=$(yum check-update 2>/dev/null)
    if [ $? -eq 100 ]; then
        echo -e "${YELLOW}Available updates:${RESET}"
        echo "$updates"
    else
        echo -e "${GREEN}System is up to date.${RESET}"
    fi
else
    echo -e "${RED}Unsupported OS for update check.${RESET}"
fi

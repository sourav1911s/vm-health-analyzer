#!/bin/bash

# Usage: ./vm-health-check.sh [--explain]

EXPLAIN=false
THRESHOLD=60

# Parse arguments
for arg in "$@"; do
  case $arg in
    --explain)
      EXPLAIN=true
      shift
      ;;
  esac
done

# Function to get CPU usage
total_cpu_usage() {
  mpstat | grep "all" | awk '{print 100 - $13}'
}

# Function to get memory usage
memory_usage() {
  free | grep Mem | awk '{print $3/$2 * 100.0}'
}

# Function to get disk usage
# Usage: disk_usage <path>
disk_usage() {
  df -h | grep "^/dev/" | awk '{print $5}' | sed 's/%//' | sort -n | tail -1
}

# Determine health status
get_health_status() {
  local cpu=$1
  local memory=$2
  local disk=$3

  if (( $(echo "$cpu > $THRESHOLD" | bc -l) )) || \
     (( $(echo "$memory > $THRESHOLD" | bc -l) )) || \
     (( $(echo "$disk > $THRESHOLD" | bc -l) )); then
    echo "UNHEALTHY"
  else
    echo "HEALTHY"
  fi
}

# Get system metrics
cpu_usage=$(total_cpu_usage)
mem_usage=$(memory_usage)
disk_used=$(disk_usage)
health_status=$(get_health_status $cpu_usage $mem_usage $disk_used)

# Color-coded output
if [ "$health_status" == "HEALTHY" ]; then
  color="\e[32m" # Green
else
  color="\e[31m" # Red
fi

# Output results
if [ "$EXPLAIN" = true ]; then
  echo -e "\nCPU Usage: $cpu_usage%\nMemory Usage: $mem_usage%\nDisk Usage: $disk_used%\n";
  echo -e "Health Status: $health_status\n"
else
  echo -e "Health Status: ${color}$health_status\e[0m"
fi

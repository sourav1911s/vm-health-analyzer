#!/bin/bash

# Script to check the health of a virtual machine
# Usage: ./vm-health-check.sh [--explain]

# Function to check CPU usage
check_cpu() {
    echo "Checking CPU usage..."
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    echo "CPU Usage: $cpu_usage%"
}

# Function to check Memory usage
check_memory() {
    echo "Checking Memory usage..."
    mem_info=$(free -m)
    echo "$mem_info"
}

# Function to check Disk usage
check_disk() {
    echo "Checking Disk usage..."
    disk_usage=$(df -h)
    echo "$disk_usage"
}

# Function to explain the checks
explain() {
    echo "This script checks the health of the VM by monitoring CPU, Memory, and Disk usage."
    echo "Usage: ./vm-health-check.sh [--explain]"
    echo "If --explain is provided, detailed information about the checks will be displayed."
}

# Check if --explain flag is provided
if [[ " $@ " =~ " --explain " ]]; then
    explain
else
    check_cpu
    check_memory
    check_disk
fi

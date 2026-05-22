#!/bin/bash

# Ensure required commands exist
for cmd in arp curl; do
    if ! command -v $cmd &> /dev/null; then
        echo "Error: '$cmd' is required but not installed." >&2
        exit 1
    fi
done

echo "=================================================="
echo "  Scanning ARP Table Devices... (Please wait)"
echo "=================================================="

# Extract unique IP addresses from arp -a output (ignores broadcast/multicast)
ips=$(arp -a | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | grep -vE "255$|224\.")

# Loop through each extracted IP address
for ip in $ips; do
    echo -e "\n--------------------------------------------------"
    echo -e "IP Address:   \033[1;32m$ip\033[0m"
    
    # 1. Fetch Hostname (Reverse DNS)
    hostname=$(host "$ip" 2>/dev/null | awk '{print $NF}' | sed 's/\.$//')
    if [ -z "$hostname" ] || [[ "$hostname" == *"NXDOMAIN"* ]]; then
        hostname="Unknown"
    fi
    echo "Hostname:     $hostname"
    
    # 2. Extract corresponding MAC Address
    mac=$(arp -n "$ip" 2>/dev/null | awk '{print $3}' | grep -iE '([0-9a-f]{2}[:-]){5}[0-9a-f]{2}')
    
    # 3. Fetch MAC Vendor/Manufacturer
    if [ -n "$mac" ] && [ "$mac" != "(incomplete)" ]; then
        echo "MAC Address:  $mac"
        # Query ://macvendors.com (rate limited to 1 request/sec)
        vendor=$(curl -s "https://://macvendors.com/$mac")
        sleep 1
        if [[ "$vendor" == *"errors"* ]] || [ -z "$vendor" ]; then
            vendor="Unknown Vendor"
        fi
        echo "Vendor:       $vendor"
    else
        echo "MAC Address:  Not found"
    fi
    
    # 4. Optional: Quick Port Scan for clues (HTTP, HTTPS, SSH, SMB)
    echo -n "Common Ports: "
    open_ports=""
    for port in 22 80 443 445; do
        if (timeout 1 bash -c "</dev/tcp/$ip/$port" 2>/dev/null); then
            open_ports="$open_ports $port"
        fi
    done
    if [ -z "$open_ports" ]; then
        echo "None detected (or blocking traffic)"
    else
        echo -e "\033[1;33m$open_ports\033[0m"
    fi
done
echo -e "\n=================================================="


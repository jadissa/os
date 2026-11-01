import socket
import sqlite3
import time
from datetime import datetime
import sys
import requests

import maxminddb
import ipaddress
import psutil
import json
from scapy.all import sniff
from scapy.all import IP, IPv6
from functools import lru_cache
from ipwhois import IPWhois

# Database setup
RAW_DB = './data/database.sqlite'
GEO_DB = './data/GeoLite2-City.mmdb'

ABUSE_KEY = '745e2d7991dc47144efd55d4cf5063907a08bb30e13ed8a3232cac28d7b6bba37121ba139de994c1'
# https://abuseipdb.com

# Correct endpoint URL for checking individual IPs
ABUSE_URL = 'https://abuseipdb.com'

ABUSE_PARAMS = {
    "ipAddress": "",
    "maxAgeInDays": 90,  # Lookback window (1-365)
    "verbose": ""        # Required to return individual report comments
}

ABUSE_HEADERS = {
    "Key": ABUSE_KEY,
    "Accept": "application/json"
}

try:
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.connect(("8.8.8.8", 80)) # Connect to a known external IP
    LOCAL_IP = s.getsockname()[0]
    s.close()
except socket.error:
    LOCAL_IP = '127.0.0.1' # Fallback if no external connection
print(f"Local IP address detected: {LOCAL_IP}")

processed_networks = set()

@lru_cache(maxsize=128)
def get_hostname(ip):
    """Resolve hostname from IP address using a cache."""
    try:
        return socket.gethostbyaddr(ip)[0]
    except (socket.herror, socket.gaierror):
        return "N/A"

def get_who(ip):
    try:
        obj = IPWhois(str(ip))
        results = obj.lookup_rdap(depth=1) # depth controls the level of detail
        return results["asn_description"]
    except Exception as e:
        print(f"An unexpected error occurred for {ip}: {e}\n")
        return None

def get_location(reader, ip):
    try:
        match = reader.get(ip)
        if match:
            city = match.get('city', {}).get('names', {}).get('en')
            country = match.get('country', {}).get('names', {}).get('en')
            return f"{city}, {country}" if city and country else (city or country or "Unknown")
        return "Unknown"
    except Exception as e:
        return f"Location Error: {e}"

def insert_request(ip_address, server_hostname, location, process, origin, whois, abuse_score=0, total_reports=0):
    """Update an existing record's details or insert a new one if it doesn't exist."""
    now = datetime.now()
    date_time = now.strftime('%Y-%m-%d %H:%M:%S')

    with sqlite3.connect(RAW_DB) as conn:
        cursor = conn.cursor()

        # Check if the exact IP metadata already exists
        cursor.execute("SELECT ip_address FROM requests WHERE ip_address=?", (ip_address,))
        data = cursor.fetchone()
        
        if data:
            # Update existing record metadata and tracking timestamp
            cursor.execute('''
                UPDATE requests 
                SET server_hostname=?, location=?, process=?, origin=?, whois=?, abuse_score=?, total_reports=?, updated_at=?
                WHERE ip_address=?
            ''', (server_hostname, location, process, origin, whois, abuse_score, total_reports, date_time, ip_address))
        else:
            # Insert brand new tracked IP entry
            cursor.execute('''
                INSERT INTO requests (ip_address, server_hostname, location, process, origin, whois, abuse_score, total_reports, created_at, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (ip_address, server_hostname, location, process, origin, whois, abuse_score, total_reports, date_time, date_time))
            
        conn.commit()

def check_abuse_ip(source_ip):
    """
    Queries the AbuseIPDB API for reports on a specific source IP address.
    """
    params = ABUSE_PARAMS.copy()
    params["ipAddress"] = source_ip

    try:
        response = requests.get(ABUSE_URL, params=params, headers=ABUSE_HEADERS)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"[!] Error connecting to AbuseIPDB: {e}")
        return None

def get_process_for_remote_ip(target_ip: str) -> str:
    """
    Attempts to find the executable path of the process that has an active
    connection with the given remote IP address.
    """
    for proc in psutil.process_iter(['pid', 'name', 'exe']):
        try:
            connections = proc.net_connections(kind='inet')
            for conn in connections:
                if conn.raddr and conn.raddr.ip == target_ip:
                    return proc.exe()
        except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
            continue

    return "Unknown"

def process_packet(packet, geo_reader):
    if IP in packet:
        source_ip_str = packet[IP].src
    elif IPv6 in packet:
        source_ip_str = packet[IPv6].src
    else:
        return 

    try:
        source_ip = ipaddress.ip_address(source_ip_str)
        process = get_process_for_remote_ip(source_ip_str)
    except ValueError:
        return

    if source_ip_str == LOCAL_IP:
        direction = "OUTBOUND"
    else:
        direction = "INBOUND"

    if source_ip.is_loopback or source_ip.is_private or source_ip.is_multicast or source_ip.is_link_local:
        return

    if direction == "OUTBOUND":
        return

    if source_ip.version == 4:
        network_prefix = 24
    else:
        network_prefix = 64
        
    source_network = ipaddress.ip_network(f"{source_ip_str}/{network_prefix}", strict=False)

    for existing_network in processed_networks:
        if source_network.subnet_of(existing_network) or existing_network.subnet_of(source_network) or source_network.overlaps(existing_network):
            return

    processed_networks.add(source_network)
    
    # 1. Start processing output block
    print("\nProcessing packet.................................................")
    print(f"Connecting to the AbuseIPDB network to check: {source_ip_str}...")
    print(f"IP Address:      {source_ip_str}")
    print(f"Process:         {process}")
    print(f"Facing:          {direction}")
    print(f"Source Network:  {source_network}")

    # 2. Local lookup operations
    hostname = get_hostname(source_ip_str)
    location = get_location(geo_reader, source_ip_str)
    origin = f"{hostname} ({source_ip_str})"
    whois_info = get_who(source_ip_str) or "Unknown"

    print(f"Host Name:       {hostname}")
    print(f"Location Name:   {location}")

    # Initialize explicit threat metadata variables
    abuse_score = 0
    total_reports = 0

    # 3. Query the external threat intelligence network
    api_result = check_abuse_ip(source_ip_str)
    
    if api_result and "data" in api_result:
        data_payload = api_result["data"]
        abuse_score = data_payload.get("abuseConfidenceScore", 0)
        total_reports = data_payload.get("totalReports", 0)
        isp = data_payload.get("isp", "Unknown ISP")
        
        # Keep whois column focused cleanly on network attribution
        whois_info = f"ISP: {isp} | ASN Desc: {whois_info}"
        print(f"Abuse Score:     {abuse_score}% (Total Reports: {total_reports})")
        
        # Print the 3 most recent attack log notes to standard output if flagged
        reports = data_payload.get("reports", [])
        if reports:
            print("Recent Findings:")
            for i, report in enumerate(reports[:3], 1):
                comment = report.get("comment", "No description").strip()
                print(f"  - [{i}] {comment[:80]}...")
    else:
        whois_info = f"ASN Desc: {whois_info}"
        print("Abuse Score:     Lookup Failed / No Data")

    print(f"Whois Data:      {whois_info}")
    print("Processing packet finished........................................\n")

    # 4. Final DB Synchronization step passing explicit abuse integer metrics
    insert_request(
        ip_address=source_ip_str, 
        server_hostname=hostname, 
        location=location, 
        process=process, 
        origin=origin, 
        whois=whois_info,
        abuse_score=abuse_score,
        total_reports=total_reports
    )

def start_sniffing():
    """network traffic."""
    try:
        geo_reader = maxminddb.open_database(GEO_DB)
        sniff(prn=lambda pkt: process_packet(pkt, geo_reader), store=False)
    except KeyboardInterrupt:
        print("\nSniffing stopped by user.")
    except FileNotFoundError:
        print(f"Error: GeoLite2-City.mmdb not found.")
    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        if 'geo_reader' in locals():
            geo_reader.close()

if __name__ == '__main__':
    start_sniffing()
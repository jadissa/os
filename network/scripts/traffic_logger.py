import socket
import sqlite3
import time
from datetime import datetime
import sys

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
    except whois.parser.PywhoisError as e:
        print(f"Error performing WHOIS lookup for {ip}: {e}\n")
    except Exception as e:
        print(f"An unexpected error occurred for {ip}: {e}\n")

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

def insert_request(ip_address, server_hostname, location, process, origin, whois):
    now = datetime.now()
    date_time = now.strftime('%Y-%m-%d %H:%M:%S')

    """Update an existing record or insert a new one."""
    with sqlite3.connect(RAW_DB) as conn:
        cursor = conn.cursor()

        cursor.execute("SELECT ip_address from requests where ip_address=?", (ip_address,))
        data = cursor.fetchall()
        if not data:
            cursor.execute("SELECT whois from requests where whois=? AND whois != 'Unknown'", (whois,))
            data = cursor.fetchall()
            if not data:
                cursor.execute('''
                    INSERT INTO requests (ip_address, server_hostname, location, process, origin, whois, created_at, updated_at)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                ''', (ip_address, server_hostname, location, process, origin, whois, date_time, date_time))
                conn.commit()

def get_process_for_remote_ip(target_ip: str) -> str:
    """
    Attempts to find the executable path of the process that has an active
    connection with the given remote IP address.

    Args:
        target_ip: The remote IP address to look for.

    Returns:
        A string with the full executable path of the process, or a message
        indicating the process was not found.
    """
    for proc in psutil.process_iter(['pid', 'name', 'exe']):
        try:
            # Check the open network connections for the process
            connections = proc.net_connections(kind='inet')
            for conn in connections:
                # 'conn.raddr' is the remote address tuple (ip, port)
                if conn.raddr and conn.raddr.ip == target_ip:
                    # Found a match. Return the full executable path.
                    return proc.exe()
        except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
            # Skip processes that are gone or inaccessible
            continue

    return f"Unknown"

def process_packet(packet, geo_reader):
    # Determine the correct IP layer (IPv4 or IPv6)
    if IP in packet:
        source_ip_str = packet[IP].src
    elif IPv6 in packet:
        source_ip_str = packet[IPv6].src
    else:
        return # Not an IP packet we care about

    try:
        source_ip = ipaddress.ip_address(source_ip_str)
        process = get_process_for_remote_ip(source_ip_str)
    except ValueError:
        # Invalid IP address string, ignore
        return

    # Filter standard local/multicast network traffic out using built-in methods
    if source_ip.is_loopback or source_ip.is_private or source_ip.is_multicast or source_ip.is_link_local:
        return

    # Determine the network for the current IP. We assume a default subnet mask if one isn't specified.
    # A /24 for IPv4 and /64 for IPv6 are reasonable defaults for identifying unique local networks.
    if source_ip.version == 4:
        network_prefix = 24
    else:
        network_prefix = 64
        
    source_network = ipaddress.ip_network(f"{source_ip_str}/{network_prefix}", strict=False)

    # Check if this network has already been processed
    if source_network in processed_networks:
        #print(f"Network {source_network} already processed. Skipping insertion.")
        return
    
    # Check if the current network overlaps or is a subnet/supernet of any existing network in the set.
    # This is more robust than simple membership check.
    for existing_network in processed_networks:
        if source_network.subnet_of(existing_network) or existing_network.subnet_of(source_network) or source_network.overlaps(existing_network):
            #print(f"Network {source_network} overlaps with existing network {existing_network}. Skipping insertion.")
            return

    # If the network is new, add it to the processed set
    processed_networks.add(source_network)
    
    # Use GEO reader to try and 'look up' the location and hostname
    hostname = get_hostname(source_ip_str)
    location = get_location(geo_reader, source_ip_str)
    origin = f"{hostname} ({source_ip_str})"
    whois = get_who(source_ip_str)
    if not whois:
        whois = "Unknown"
    insert_request(source_ip_str, hostname, location, process, origin, whois)

def start_sniffing():
    """network traffic."""
    try:
        geo_reader = maxminddb.open_database(GEO_DB)
        start_time = time.time()
        # sniff() continuously enter blocking loop to capture packets
        sniff(prn=lambda pkt: process_packet(pkt, geo_reader), store=False) # Sniff for 5 seconds at a time by adding timeout=5, as final param
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
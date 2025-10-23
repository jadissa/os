import socket
import sqlite3
import time
from datetime import datetime
from scapy.all import sniff
from scapy.layers.inet import IP
import maxminddb
from functools import lru_cache

# Database setup
DATABASE_NAME = './data/traffic_data.db'
GEOLITE2_DB = './data/GeoLite2-City.mmdb'

def setup_database():
    """Create the requests table if it doesn't exist."""
    with sqlite3.connect(DATABASE_NAME) as conn:
        cursor = conn.cursor()
        cursor.execute(f"DROP TABLE IF EXISTS requests")
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS requests (
                server_hostname TEXT,
                ip_address TEXT PRIMARY KEY,
                origin TEXT,
                location TEXT,
                hits INTEGER,
                time_connected REAL,
                date INTEGER
            );
        ''')
        print('setup db done')
        conn.commit()

@lru_cache(maxsize=128)
def get_hostname(ip):
    """Resolve hostname from IP address using a cache."""
    try:
        return socket.gethostbyaddr(ip)[0]
    except (socket.herror, socket.gaierror):
        return "N/A"

def get_location(reader, ip):
    """Get location data from IP using GeoLite2 database."""
    try:
        match = reader.get(ip)
        if match:
            city = match.get('city', {}).get('names', {}).get('en')
            country = match.get('country', {}).get('names', {}).get('en')
            return f"{city}, {country}" if city and country else (city or country or "Unknown")
        return "Unknown"
    except Exception as e:
        return f"Location Error: {e}"

def update_or_insert_request(ip, hostname, location, origin, initial_timestamp):
    """Update an existing record or insert a new one."""
    with sqlite3.connect(DATABASE_NAME) as conn:
        cursor = conn.cursor()
        cursor.execute('SELECT hits, time_connected FROM requests WHERE ip_address = ?', (ip,))
        result = cursor.fetchone()

        if result:
            hits, old_time_connected = result
            new_hits = hits + 1
            new_time_connected = old_time_connected + (time.time() - initial_timestamp)
            cursor.execute('''
                UPDATE requests
                SET hits = ?, time_connected = ?, date = ?
                WHERE ip_address = ?
            ''', (new_hits, new_time_connected, int(time.time()), ip))
        else:
            cursor.execute('''
                INSERT INTO requests (server_hostname, ip_address, origin, location, hits, time_connected, date)
                VALUES (?, ?, ?, ?, ?, ?, ?)
            ''', (hostname, ip, origin, location, 1, time.time() - initial_timestamp, int(time.time())))
        conn.commit()

def process_packet(packet, geo_reader, start_time):
    """Extract and process data from a network packet."""
    if IP in packet:
        source_ip = packet[IP].src
        # Filter out local network traffic
        if source_ip.startswith(('127.', '192.168.', '10.', '172.')):
            return

        # print(f"Captured inbound packet from: {source_ip}")
        
        # Get data
        hostname = get_hostname(source_ip)
        location = get_location(geo_reader, source_ip)
        origin = f"{hostname} ({source_ip})"

        # Store in database
        update_or_insert_request(source_ip, hostname, location, origin, start_time)

def start_sniffer():
    """Start the network traffic sniffer."""
    try:
        geo_reader = maxminddb.open_database(GEOLITE2_DB)
        start_time = time.time()
        print("Starting traffic collector. Press Ctrl+C to stop.")
        sniff(prn=lambda pkt: process_packet(pkt, geo_reader, start_time), store=False)
    except FileNotFoundError:
        print(f"Error: GeoLite2-City.mmdb not found. Please download it and place it in this directory.")
    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        if 'geo_reader' in locals():
            geo_reader.close()

if __name__ == '__main__':
    setup_database()
    start_sniffer()
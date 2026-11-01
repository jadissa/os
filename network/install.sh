#!/bin/sh

if [[ -d .venvs ]]; then
	rm -rf .venvs
fi
mkdir -p .venvs
python3 -m venv .venvs/MyEnv
.venvs/MyEnv/bin/python -m pip install --upgrade pip
#.venvs/MyEnv/bin/python -m pip install package_name > /dev/null
.venvs/MyEnv/bin/python -m pip install scapy maxminddb tabulate ipwhois psutil python-whois requests
source .venvs/MyEnv/bin/activate

mkdir -p ./data

# Use the virtual environment's Python to rebuild the SQLite database
.venvs/MyEnv/bin/python3 << 'EOF'
import sqlite3
import os

db_path = './data/database.sqlite'

# Wipe the database if it already exists to guarantee a clean slate
if os.path.exists(db_path):
    try:
        os.remove(db_path)
        print("[+] Existing database file wiped successfully.")
    except Exception as e:
        print(f"[!] Warning: Could not remove old database file: {e}")

# Connect to database (creates a brand new file)
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

# Create the optimized table schema with structural constraints
cursor.execute('''
    CREATE TABLE requests (
        ip_address TEXT PRIMARY KEY,
        server_hostname TEXT,
        location TEXT,
        process TEXT,
        origin TEXT,
        whois TEXT,
        abuse_score INTEGER DEFAULT 0,
        total_reports INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT
    )
''')

conn.commit()
conn.close()
print("[+] Fresh database structure deployed.")
EOF
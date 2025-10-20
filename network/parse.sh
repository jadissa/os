mkdir -p .venvs
python3 -m venv .venvs/MyEnv
.venvs/MyEnv/bin/python -m pip install --upgrade pip
#.venvs/MyEnv/bin/python -m pip install package_name > /dev/null
.venvs/MyEnv/bin/python -m pip install python-whois
source .venvs/MyEnv/bin/activate

cat <<'EOF'>./scripts/whodis.py
import sqlite3
import whois

DATABASE_NAME = './data/traffic_data.db'

def perform_whois_lookup_from_db(database_path, table_name, column_name):
    """
    Connects to an SQLite database, iterates over a specified column,
    and performs a WHOIS lookup for each value.

    Args:
        database_path (str): The path to the SQLite database file.
        table_name (str): The name of the table to query.
        column_name (str): The name of the column containing values for WHOIS lookup.
    """
    conn = None
    try:
        conn = sqlite3.connect(database_path)
        cursor = conn.cursor()

        # Fetch all values from the specified column
        cursor.execute(f"SELECT {column_name} FROM {table_name}")
        rows = cursor.fetchall()

        for row in rows:
            domain_or_ip = row[0]  # Get the value from the current row
            if domain_or_ip:  # Ensure the value is not empty
                print(f"Performing WHOIS lookup for: {domain_or_ip}")
                try:
                    w = whois.whois(domain_or_ip)
                    print(f"WHOIS information for {domain_or_ip}:\n{w}\n")
                except whois.parser.PywhoisError as e:
                    print(f"Error performing WHOIS lookup for {domain_or_ip}: {e}\n")
                except Exception as e:
                    print(f"An unexpected error occurred for {domain_or_ip}: {e}\n")

    except sqlite3.Error as e:
        print(f"SQLite error: {e}")
    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        if conn:
            conn.close()

table_name='requests'
column_name='ip_address'
perform_whois_lookup_from_db(DATABASE_NAME, table_name, column_name)
print('done performing whois lookups')
EOF

.venvs/MyEnv/bin/python ./scripts/whodis.py
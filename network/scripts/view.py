import sqlite3
import time
import os
from tabulate import tabulate

# Database file location
# IMPORTANT: Change 'traffic_data.db' to your actual database path.
DATABASE_NAME = './data/database.sqlite'

def get_data():
    """Queries the database and returns sorted data."""
    try:
        with sqlite3.connect(DATABASE_NAME) as conn:
            cursor = conn.cursor()
            # The SQL query sorts by time_connected and then hits, both in descending order.
            query = """
            SELECT ip_address, server_hostname, origin, location, whois, process, created_at, updated_at, reviewed 
            FROM requests
            ORDER BY updated_at ASC;
            """
            cursor.execute(query)
            return cursor.fetchall()
    except sqlite3.Error as e:
        return f"Database error: {e}"

def display_data(data):
    """Clears the screen and displays the data in a formatted table."""
    # Clear the console. 'cls' for Windows, 'clear' for Linux/macOS.
    os.system('cls' if os.name == 'nt' else 'clear')

    if isinstance(data, str):
        print(data) # Print the database error message
        return
    if not data:
        print("No data available.")
        return

    headers = [
        "ip_address", "server_hostname", "origin", "location", "whois", "process", "created_at", "updated_at", "reviewed"
    ]
    print(tabulate(data, headers=headers, tablefmt="grid"))

def main():
    results = get_data()
    display_data(results)

if __name__ == "__main__":
    main()
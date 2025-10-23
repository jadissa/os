import sqlite3
import time
import os
from tabulate import tabulate

# Database file location
# IMPORTANT: Change 'traffic_data.db' to your actual database path.
DATABASE_NAME = './data/traffic_data.db'

def get_data():
    """Queries the database and returns sorted data."""
    try:
        with sqlite3.connect(DATABASE_NAME) as conn:
            cursor = conn.cursor()
            # The SQL query sorts by time_connected and then hits, both in descending order.
            query = """
            SELECT ip_address, origin, location, hits, time_connected, date
            FROM requests
            ORDER BY time_connected DESC, hits DESC;
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
        "ip_address", "origin", "location", "hits", "time_connected", "date"
    ]
    print(tabulate(data, headers=headers, tablefmt="grid"))

def main():
    """Main function to query and display data every 10 seconds."""
    while True:
        results = get_data()
        display_data(results)
        time.sleep(10)

if __name__ == "__main__":
    main()
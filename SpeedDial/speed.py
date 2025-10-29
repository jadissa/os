#!/usr/bin/env python
import speedtest
import json
import time
import sys # Import the sys module

def get_internet_speed():
    """
    Calculates download and upload internet speeds and returns them as a dictionary.
    """
    try:
        st = speedtest.Speedtest(secure=True)
        st.get_best_server()  # Find the best server for testing
        
        download_speed_raw = st.download()  # Bytes per second
        upload_speed_raw = st.upload()      # Bytes per second
        ping = st.results.ping              # Milliseconds

        # Convert to Mbps (Megabits per second)
        download_speed_mbps = download_speed_raw / 1_000_000
        upload_speed_mbps = upload_speed_raw / 1_000_000

        speed_data = {
            "download_speed_mbps": round(download_speed_mbps, 2),
            "upload_speed_mbps": round(upload_speed_mbps, 2),
            "ping_ms": round(ping, 2),
            "time_stamp": time.time(),
        }
        return speed_data
    except speedtest.SpeedtestException as e:
        # Return a dictionary with an error key on failure
        return {"error": str(e), "time_stamp": time.time()}

if __name__ == "__main__":
    speed_results = get_internet_speed()
    
    # Check if 'download_speed_mbps' is missing or the result has an 'error' key
    if "download_speed_mbps" not in speed_results:
        print("An error occurred or the speed key is empty. Exiting.")
        json_output = json.dumps(speed_results, indent=4)
        print(json_output)
        sys.exit(1) # Exit with a non-zero status to indicate an error
    
    json_output = json.dumps(speed_results, indent=4)
    print(json_output)

    with open("output.json", "w") as f:
        f.write(json_output)
    
    print("\nSpeed results have been saved to output.json")

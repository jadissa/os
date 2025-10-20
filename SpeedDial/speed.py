#!/usr/bin/env python
import speedtest
import json

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
            "ping_ms": round(ping, 2)
        }
        return speed_data
    except speedtest.SpeedtestException as e:
        return {"error": str(e)}

if __name__ == "__main__":
    speed_results = get_internet_speed()
    json_output = json.dumps(speed_results, indent=4)
    print(json_output)
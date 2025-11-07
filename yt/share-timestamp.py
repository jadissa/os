import sys

def generate_timestamped_youtube_link(base_url, hours=0, minutes=0, seconds=0):
    """
    Generates a YouTube link that plays the video from a specific timestamp.

    Args:
        base_url (str): The base YouTube video URL (e.g., "https://www.youtube.com/watch?v=dQw4w9WgXcQ").
        hours (int): The starting hour.
        minutes (int): The starting minute.
        seconds (int): The starting second.

    Returns:
        str: The timestamped YouTube link.
    """
    total_seconds = (hours * 3600) + (minutes * 60) + seconds
    
    if '?' in base_url:
        return f"{base_url}&t={total_seconds}s"
    else:
        return f"{base_url}?t={total_seconds}s"

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python youtube_timestamp.py <youtube_url> [hours] [minutes] [seconds]")
        sys.exit(1)

    youtube_url = sys.argv[1]
    hours = int(sys.argv[2]) if len(sys.argv) > 2 else 0
    minutes = int(sys.argv[3]) if len(sys.argv) > 3 else 0
    seconds = int(sys.argv[4]) if len(sys.argv) > 4 else 0

    timestamped_link = generate_timestamped_youtube_link(youtube_url, hours, minutes, seconds)
    print(f"Shareable YouTube link: {timestamped_link}")
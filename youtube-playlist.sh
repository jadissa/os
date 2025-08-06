#!/bin/bash

# Install
curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o ~/.local/bin/yt-dlp
chmod a+rx ~/.local/bin/yt-dlp  # Make executable

# Update
./yt-dlp -U

# Download playlist
./yt-dlp https://music.youtube.com/playlist?list=PLOfTY28w1MFkfSrWF3WjdIe5Igk4wMEqm
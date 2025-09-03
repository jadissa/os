#!/bin/bash

if [[ -z "$1" ]]; then
	echo 'Supply a playlist...exiting'
	exit
fi

# Install
curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o ~/.local/bin/yt-dlp
chmod a+rx ~/.local/bin/yt-dlp  # Make executable

# Update
~/.local/bin/./yt-dlp -U

# Download playlist
~/.local/bin/./yt-dlp $1

# Move playlist
mkdir -p /Volumes/LaCie/mus && mv *.mp4 /Volumes/LaCie/mus

# List playlist
ls -ltrah /Volumes/LaCie/mus
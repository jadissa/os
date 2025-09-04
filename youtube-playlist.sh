#!/bin/bash

if [[ -z "$1" ]]; then
	echo 'Supply a playlist...exiting'
	exit
fi

if [[ -z "$2" ]]; then
	echo 'Supply an output directory...exiting'
	exit
fi

# Install
curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o ~/.local/bin/yt-dlp
chmod a+rx ~/.local/bin/yt-dlp  # Make executable

# Update
~/.local/bin/./yt-dlp -U

~/.local/bin/./yt-dlp \
    --ignore-errors \
    --extract-audio \
    --audio-format "mp3" \
    --audio-quality 0 \
    --yes-playlist \
    -o "$2/%(playlist_index)s - %(title)s.%(ext)s" \
    "$1"

# List playlist
ls -ltrah $2
#!/bin/sh

if [[ -z "$1" ]]; then
	echo 'Supply a path to the files...exiting'
	exit
fi

sh ~/Server/os/brew/brew-update.sh
brew install ffmpeg imagemagick

for FILE in "$1"/*.m4s; do
    # Skip if no matching files found
    [ -e "$FILE" ] || continue

    # Convert to high-quality, lossless APNG with infinite looping
    # -f apng: Forces APNG container format
    # -plays 0: Sets infinite looping for APNG (equivalent to -loop 0 for WebP/GIF)
    # -pred mixed: Optimizes compression dynamically per frame
    ffmpeg -i "$FILE" -f apng -plays 0 -pred mixed -y "${FILE%.m4s}.gif"

    # Check if the conversion succeeded before deleting the source
    if [ $? -eq 0 ]; then
        rm "$FILE"
    else
        echo "Error: Conversion failed for $FILE"
    fi
done

#brew remove ffmpeg imagemagick
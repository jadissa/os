#!/bin/sh

if [[ -z "$1" ]]; then
	echo 'Supply a path to the files...exiting'
	exit
fi

sh ~/Server/os/brew/brew-update.sh
brew install ffmpeg imagemagick

# convert is part of imagemagick and translates the image to gif

# -layers Optimize: An ImageMagick option to optimize the GIF for smaller file size.

# -f image2pipe -vcodec ppm -: Configures FFmpeg to output raw PPM image data to standard output.

# -loop 0: Specifies that the GIF should loop infinitely.

# -delay 10: Sets the delay between frames in hundredths of a second (e.g., 10 means 0.1 seconds, which corresponds to 10 frames per second). 
# Adjust this value to match the frame rate used in the FFmpeg step to maintain consistent animation speed.

# -r 10: Sets the frame rate for extraction to 10 frames per second. Adjust this value to control the speed and smoothness of the resulting GIF.

for FILE in "$1"/*.m4s; do
    # Generate a custom color palette for this specific video
    ffmpeg -i "$FILE" -vf "fps=10,palettegen" -y /tmp/palette.png
    
    # Use the palette to convert to GIF with high-quality scaling
    ffmpeg -i "$FILE" -i /tmp/palette.png -filter_complex "fps=10,paletteuse=dither=sierra2_4a" "$FILE.gif"
    
    # Check if the last command succeeded before deleting the source
    if [[ $? -eq 0 ]]; then
        rm "$FILE"
    fi
done

#brew remove ffmpeg imagemagick
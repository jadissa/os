#!/bin/sh

if [[ -z "$1" ]]; then
	echo 'Supply a path to the files...exiting'
	exit
fi

sh ~/Server/os/brew-update.sh
brew install ffmpeg imagemagick

# convert is part of imagemagick and translates the image to gif

# -layers Optimize: An ImageMagick option to optimize the GIF for smaller file size.

# -f image2pipe -vcodec ppm -: Configures FFmpeg to output raw PPM image data to standard output.

# -loop 0: Specifies that the GIF should loop infinitely.

# -delay 10: Sets the delay between frames in hundredths of a second (e.g., 10 means 0.1 seconds, which corresponds to 10 frames per second). 
# Adjust this value to match the frame rate used in the FFmpeg step to maintain consistent animation speed.

# -r 10: Sets the frame rate for extraction to 10 frames per second. Adjust this value to control the speed and smoothness of the resulting GIF.

for FILE in $(ls $1/*.webp); do
	ffmpeg -i $FILE -r 10 -f image2pipe -vcodec ppm - | convert -delay 10 -loop 0 -layers Optimize - $FILE.gif
	if [[ $?==0 ]]; then
		rm $FILE
	fi
done

for FILE in $(ls $1/*.webm); do
	ffmpeg -i $FILE -r 10 -f image2pipe -vcodec ppm - | convert -delay 10 -loop 0 -layers Optimize - $FILE.gif
	if [[ $?==0 ]]; then
		rm $FILE
	fi
done
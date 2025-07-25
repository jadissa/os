#!/bin/bash
# Check for dependency
echo 'Checking for imagemagick...'
INSTALLED=`brew list imagemagick`
if [ -n "$INSTALLED" ]; then
	echo 'Already installed'
else
	echo 'Installing...'
	brew install imagemagick
	brew install ffmpeg
fi;
# Check succcess of last command
if [[ $?==0 ]]; then
	echo "Running mogrify on $1*.webp..."
	magick mogrify -format gif $1*.webp
fi;
# Check succcess of last command
if [[ $?==0 ]]; then
	echo "Removing $1*.webp files..."
	rm -f $1*.webp
fi;

mogrify -strip $1*
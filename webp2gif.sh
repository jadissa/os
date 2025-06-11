#!/bin/bash
# Check for dependency
echo 'Checking for imagemagick...'
INSTALLED=`brew list imagemagick`
if [ -n "$INSTALLED" ]; then
	echo 'Already installed'
else
	echo 'Installing...'
	brew install imagemagick
fi;
# Check succcess of last command
if [[ $?==0 ]]; then
	echo 'Running mogrify on ~/Downloads/*.webp...'
	magick mogrify -format gif ~/Downloads/*.webp
fi;
# Check succcess of last command
if [[ $?==0 ]]; then
	echo 'Removing ~/Downloads/*.webp files...'
	rm -f ~/Downloads/*.webp
fi;
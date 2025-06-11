#!/bin/bash
brew install imagemagick
magick mogrify -format gif ~/Downloads/*.webp
rm -f ~/Downloads/*.webp
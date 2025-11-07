#!/bin/sh

SEARCH_TERM=$1
defaults read | grep --colour="always" --before-context=3 --after-context=3 --ignore-case --text --line-number $SEARCH_TERM
defaults find $SEARCH_TERM
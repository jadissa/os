#!/bin/sh

SEARCH_TERM=$1
defaults read | grep --colour="always" -B3 -A3 -ian $SEARCH_TERM
defaults find $SEARCH_TERM
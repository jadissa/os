#!/bin/sh

rm -rf ~/Library/Caches/*
rm -rf /Library/Caches/*
rm -rf ~/Library/Logs/*
rm -rf /Library/Logs/*
open ~/Library/Application\ support
open ~/Library/Containers
open /Library/Application\ support
open /Library/Containers
open /Library/LaunchAgents
open /Library/LaunchDaemons
for d in $(tmutil listlocalsnapshotdates | grep "-"); do tmutil deletelocalsnapshots $d; done
#while [[ `brew list | wc -l` -ne 0 ]]; do
#    for EACH in `brew list`; do
#        brew uninstall --force --ignore-dependencies $EACH
#    done
#done
brew cleanup --prune=all
#!/bin/bash
cmd='curl --verbose --connect-timeout 15 --location --head'
echo $cmd $1
$cmd $1
echo $cmd $1
#!/bin/bash
cmd='curl --verbose --connect-timeout 30 --location -s -o /dev/null -w "%{url_effective}\n"'
echo $cmd $1
$cmd $1
echo $cmd $1
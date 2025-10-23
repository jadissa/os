#!/bin/sh

mkdir -p .venvs
python3 -m venv .venvs/MyEnv
.venvs/MyEnv/bin/python -m pip install --upgrade pip
#.venvs/MyEnv/bin/python -m pip install package_name > /dev/null
.venvs/MyEnv/bin/python -m pip install scapy maxminddb tabulate python-whois
source .venvs/MyEnv/bin/activate
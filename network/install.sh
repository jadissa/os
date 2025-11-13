#!/bin/sh

if [[ -d .venvs ]]; then
	rm -rf .venvs
fi
mkdir -p .venvs
python3 -m venv .venvs/MyEnv
.venvs/MyEnv/bin/python -m pip install --upgrade pip
#.venvs/MyEnv/bin/python -m pip install package_name > /dev/null
.venvs/MyEnv/bin/python -m pip install scapy maxminddb tabulate ipwhois psutil
source .venvs/MyEnv/bin/activate

sqlite3 ./data/database.sqlite
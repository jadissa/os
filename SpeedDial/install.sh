mkdir -p .venvs > /dev/null 
python3 -m venv .venvs/MyEnv
.venvs/MyEnv/bin/python -m pip install --upgrade pip
#.venvs/MyEnv/bin/python -m pip install package_name > /dev/null
.venvs/MyEnv/bin/python -m pip install speedtest-cli
source .venvs/MyEnv/bin/activate
deactivate
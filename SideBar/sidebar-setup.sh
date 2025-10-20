#!/bin/sh
mkdir -p .venvs/MyEnv > /dev/null 
python3 -m venv .venvs/MyEnv > /dev/null
.venvs/MyEnv/bin/python -m pip install --upgrade pip > /dev/null
.venvs/MyEnv/bin/python -m pip install finder-sidebar-editor > /dev/null
source .venvs/MyEnv/bin/activate > /dev/null
.venvs/MyEnv/bin/python sidebar-setup.py $HOME > /dev/null					# Add $HOME to Finder Favorites
deactivate
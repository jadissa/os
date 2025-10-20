#!/usr/bin/python
# https://github.com/Ajordat/finder-sidebar-editor
import sys, importlib

from finder_sidebar_editor import FinderSidebar											# Import the module

sidebar = FinderSidebar()																# Create a Finder sidebar instance to act on.

sidebar.add(sys.argv[1])																# You can escape the slash. Use \\ and you get just one slash
sidebar.add(sys.argv[1]+"/Library/Mobile Documents/com~apple~CloudDocs")			# Add Icloud folder to Finder Favorites
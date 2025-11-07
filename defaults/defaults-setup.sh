#!/bin/sh

# https://git.herrbischoff.com/awesome-macos-command-line/about/
# https://macos-defaults.com/#%F0%9F%92%BB-list-of-commands
# https://www.real-world-systems.com/docs/defaults.1.html
# https://github.com/kevinSuttle/macOS-Defaults/blob/master/.macos

# Ask for the administrator password upfront
sudo -v

# Enable integrity protection
csrutil enable
csrutil status

# Enable firewall
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate

# Enable file valut/encrypt disc contents
sudo fdesetup enable
sudo fdesetup status
sudo fdesetup isactive
sudo fdesetup list

# Enable stealth mode/don't respond to pings
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getstealthmode

# Disable Login for Hidden User ">Console"
defaults write com.apple.loginwindow DisableConsoleAccess -bool true

# Secure keyboard entry in Terminal (prevents other processes from monitoring keystrokes in Terminal)
defaults write com.apple.terminal SecureKeyboardEntry -bool true

# Disable bluetooth
sudo defaults write /Library/Preferences/com.apple.Bluetooth ControllerPowerState -bool false && sudo killall -HUP bluetoothd

# Disable AirPlay and AirDrop
ps aux | grep sharing
defaults write com.apple.sharingd DiscoverableMode -string "Off"
sudo ifconfig awdl0 down
sudo /bin/launchctl disable system/com.apple.sharingd
sudo /bin/launchctl stop com.apple.sharingd
sudo /bin/launchctl stop com.apple.NetworkSharing
sudo /bin/launchctl disable system/com.apple.NetworkSharing
defaults -currentHost write com.apple.controlcenter.plist AirplayRecieverEnabled -bool false

# Disable remote access
ps aux | grep remote
sudo systemsetup -f -setremotelogin off && \
	sudo systemsetup -getremotelogin && \
	sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -deactivate -configure -access -off && \
	sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -deactivate && \
	sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -deactivate -stop && \
	sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -clientopts -setmenuextra -menuextra no
sudo launchctl unload system/com.apple.remoted

# Screensaver immediate lock
defaults write com.apple.screensaver askForPassword -bool true
defaults write com.apple.screensaver askForPasswordDelay -bool false

# Lock the screen after x minutes
MINUTES_TO_LOCK=5
defaults write com.apple.screensaver idleTime -int $((MINUTES_TO_LOCK * 60 ))
defaults read com.apple.screensaver 

# Disable guest account
sudo defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false

# Disable automatic login
sudo defaults write /Library/Preferences/com.apple.loginwindow AutomaticLogin -bool FALSE

# Disable Screen Sharing (VNC)/ssh/smb
sudo defaults write /var/db/launchd.db/com.apple.launchd/overrides.plist com.apple.screensharing -dict Disabled -bool true
sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.screensharing.plist 2> /dev/null
sudo launchctl disable system/com.apple.screensharing

sudo defaults write /var/db/launchd.db/com.apple.launchd/overrides.plist com.openssh.sshd -dict Disabled -bool true
sudo launchctl unload -w /System/Library/LaunchDaemons/com.openssh.sshd.plist 2> /dev/null
sudo launchctl disable system/com.openssh.sshd

sudo defaults write /var/db/launchd.db/com.apple.launchd/overrides.plist com.apple.AppleFileServer -dict Disabled -bool true
sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.AppleFileServer.plist 2> /dev/null
sudo launchctl disable system/com.apple.AppleFileServer

sudo defaults write /var/db/launchd.db/com.apple.launchd/overrides.plist com.apple.smbd -dict Disabled -bool true
sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.smbd.plist 2> /dev/null
sudo launchctl disable system/com.apple.smbd


# Disable `gamed` process
defaults write com.apple.gamed Disabled -bool true

# Disable the sound effects on boot
# sudo nvram SystemAudioVolume=%01
# sudo nvram SystemAudioVolume=%80
# sudo nvram SystemAudioVolume=%00
sudo nvram SystemAudioVolume=" "
sudo nvram SystemStartupMute=%01

# Automatically quit printer app once the print jobs complete
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# Check for software updates daily, not just once per week
defaults write com.apple.SoftwareUpdate ScheduleFrequency -bool true

# Enable automatic security updates
defaults write com.apple.SoftwareUpdate AutomaticSecurityUpdates -bool true

# Check for software updates automatically
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

# Download newly available updates in the background
defaults write com.apple.SoftwareUpdate AutomaticallyDownload -bool true

# Set keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 25

# Set the timezone; see `sudo systemsetup -listtimezones` for other values
sudo systemsetup -settimezone "America/Chicago" > /dev/null
sudo systemsetup -gettimezone

# Disable Notification Center and remove the menu bar 
launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist 2> /dev/null

# Disable drag windows to menu bar to fill screen
defaults write com.apple.WindowManager EnableTopTilingByEdgeDrag -bool false

# Desktop icon size
defaults write com.apple.finder gridSpacing -int 34
defaults write com.apple.finder iconSize -int 36
defaults write com.apple.finder labelOnBottom -bool false
defaults write com.apple.finder textSize -int 12

# Show hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Put the Dock on the left of the screen
defaults write com.apple.dock orientation -string "left" && killall Dock

# Finder List view
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Show hard disks on desktop
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true

# Show external disks on desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true

# Show connected servers on desktop
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true

# Set TextEdit format to text
defaults write com.apple.TextEdit RichText -bool "false"

# Disable autocorrect
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Disable smart dashes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable automatic period substitution as it’s annoying when typing code
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Disable smart quotes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable automatic capitalization as it’s annoying when typing code
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Login text
sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "Gondor is watching"

# Show full path in finder title
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder "_FXShowPosixPathInTitle" -bool true

# Show finder status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Turn off idiotic doc bounce
defaults write com.apple.doc no-bouncing -bool true
defaults write com.apple.dock no-bouncing -bool true

# Restart
killall Finder && killall TextEdit && sudo killall -HUP sharingd && sudo killall -HUP bluetoothd

# Generate system performance report
#sudo sysdiagnose -f ~/Desktop/
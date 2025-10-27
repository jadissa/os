#!/bin/sh

zsh_path(){
	echo ~/.oh-my-zsh
}

zsh_install(){
	if [[ -x "$(command -v zsh)" ]]; then
		ZSH=$(zsh_path)
		rm -rf $ZSH
		rm -f ~/.zshrc*
	fi
	sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" > /dev/null 2>&1 &
	wait
	echo 0
}

zsh_config(){
	if [[ -x "$(command -v zsh)" ]]; then
		ZSH=$(zsh_path)
		ZSHRC=~/.zshrc
		LPURPLE=135
		PURPLE=057
		LPINK=219
		PINK=005
		LWHITE=244
		WHITE=240
		GREEN=084
		RED=162
		# for i in {0..255}; do print -Pn "%K{$i} %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$\'\n\'}; done

		echo '' >$ZSH/themes/jcandy.zsh-theme
		echo "LPURPLE=$LPURPLE" >>$ZSH/themes/jcandy.zsh-theme
		echo "PURPLE=$PURPLE" >>$ZSH/themes/jcandy.zsh-theme
		echo "LPINK=$LPINK" >>$ZSH/themes/jcandy.zsh-theme
		echo "PINK=$PINK" >>$ZSH/themes/jcandy.zsh-theme
		echo "LWHITE=$LWHITE" >>$ZSH/themes/jcandy.zsh-theme
		echo "WHITE=$WHITE" >>$ZSH/themes/jcandy.zsh-theme
		echo "GREEN=$GREEN" >>$ZSH/themes/jcandy.zsh-theme
		echo "RED=$RED" >>$ZSH/themes/jcandy.zsh-theme

		echo 'PROMPT=$'\''%F{$LPINK}%n%f%F{$PINK}@%m%f %F{$WHITE}12 %F{$LWHITE}%D{[%X]}%f %F{$WHITE}24%f %F{$LWHITE}[%D{%H:%M:%S}]%f %F{$WHITE}UNIX%f %F{$LWHITE}[%D{%s}]%f %F{$LPURPLE}[%~]%f$(git_prompt_info)%f%F{$PURPLE}->%f%F{$PURPLE}%#%f '\''' >>$ZSH/themes/jcandy.zsh-theme
		echo 'ZSH_THEME_GIT_PROMPT_PREFIX="%F{$GREEN}["' >>$ZSH/themes/jcandy.zsh-theme
		echo 'ZSH_THEME_GIT_PROMPT_SUFFIX="]%f"' >>$ZSH/themes/jcandy.zsh-theme
		echo 'ZSH_THEME_GIT_PROMPT_DIRTY=" %F{$RED}*%F{$GREEN}"' >>$ZSH/themes/jcandy.zsh-theme
		echo 'ZSH_THEME_GIT_PROMPT_CLEAN=""' >>$ZSH/themes/jcandy.zsh-theme
		# color format %F{color}%f, where %f resets the color back to nothing. %F is foreground
		# https://zsh-prompt-generator.site/

		echo 'ZSH=~/.oh-my-zsh' >$ZSHRC
		echo 'export ZSH="$ZSH"' >>$ZSHRC
		echo 'ZSH_THEME="jcandy"' >>$ZSHRC
		echo 'DISABLE_AUTO_TITLE="true"' >>$ZSHRC
		echo 'HIST_STAMPS=yyyy-mm-dd' >>$ZSHRC
		echo 'export PAGER="cat"' >>$ZSHRC
		echo 'export MANPAGER="cat"' >>$ZSHRC
		echo 'plugins=(git)' >>$ZSHRC
		echo 'export PATH="/usr/local/opt/php@*/bin:$PATH"' >>$ZSHRC
		echo 'source $ZSH/oh-my-zsh.sh' >>$ZSHRC
		echo 'source ~/.bash_profile' >>$ZSHRC
		source $ZSHRC > /dev/null 2>&1 &

		touch ~/.hushlogin > /dev/null 2>&1 &
		source ~/.hushlogin > /dev/null 2>&1 &

		ZSHRC=~/.zprofile
		echo '' >$ZSHRC
		echo "LPURPLE=$LPURPLE" >>$ZSHRC
		echo "PURPLE=$PURPLE" >>$ZSHRC
		echo "LPINK=$LPINK" >>$ZSHRC
		echo "PINK=$PINK" >>$ZSHRC
		echo "LWHITE=$LWHITE" >>$ZSHRC
		echo "WHITE=$WHITE" >>$ZSHRC

		echo "print -P '%F{$LPINK}________                              .____                    .___%f'" >>$ZSHRC
		echo "print -P '%F{$PINK}\\\______ \\\_______  ____ _____    _____ |    |    ____  __ __  __| _/%f'" >>$ZSHRC
		echo "print -P '%F{$PINK} |    |  \\\_  __ _/ __ .\\\__  \\\  /     \\\|    |   /  _ \\\|  |  \\\/ __ | %f'" >>$ZSHRC
		echo "print -P '%F{$LPURPLE} |    .   |  | .\\\  ___/ / __ \\\|  Y Y  |    |__(   O  |  |  / /_/ | %f'" >>$ZSHRC
		echo "print -P '%F{$PURPLE}/_______  |__|   \\\___  (____  |__|_|  |_______ \\\____/|____/\\\____ | %f'" >>$ZSHRC
		echo "print -P '%F{$PURPLE}        \\\/           \\\/     \\\/      \\\/        \\\/                \\\/ %f'" >>$ZSHRC
		# https://patorjk.com/software/taag/#p=display&f=Graffiti&t=DreamLoud&x=none&v=3&h=3&w=80&we=false
		# backslashes are escaped above using \\\ instead of \
		source $ZSHRC > /dev/null 2>&1 &
		echo 0
	else
		echo 1
	fi
}

composer_install(){
	if [[ ! -x "$(command -v php)" ]]; then
		echo 1
	else
		if [[ ! -x "$(command -v composer)" ]]; then
			php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
			php composer-setup.php > /dev/null 2>&1 &
			wait
			php -r "unlink('composer-setup.php');"
			mv composer.phar /usr/local/bin/composer
		fi
	fi
	echo 0
}

#vim_install(){}

vim_config(){
	if [[ -x "$(command -v vim)" ]]; then
		VIMRC=~/.vimrc
		echo 'set nocompatible' >$VIMRC
		echo 'set showmatch' >>$VIMRC
		echo 'set nu' >>$VIMRC
		echo 'set mouse=a' >>$VIMRC
		echo 'filetype on' >>$VIMRC
		echo 'filetype indent on' >>$VIMRC
		echo 'filetype plugin on' >>$VIMRC
		echo 'set backspace=indent,eol,start' >>$VIMRC
		echo 'syntax enable' >>$VIMRC
		source $VIMRC > /dev/null 2>&1 &
		echo 0
	else
		echo 1
	fi
}

ssh_config(){
	if [[ -x "$(command -v ssh)" ]]; then
		if [ ! -f ~/.ssh/config ]; then
			touch ~/.ssh/config
		fi
		test=`cat ~/.ssh/config | grep 'ServerAliveInterval 300'`
		if [[ $test == '' ]]; then
		    echo 'ServerAliveInterval 300' >> ~/.ssh/config 2>&1 &
		fi
		echo 0
	else
		echo 1
	fi
}

git_config(){
	if [[ -x "$(command -v git)" ]]; then
		git config --global core.pager cat
		echo 0
	else 
		echo 1
	fi
}

bash_config(){
	if [[ -x "$(command -v bash)" ]]; then
		test=$( cat ~/.bash_profile | grep 'alias ll=' )
		if [[ $test == '' ]]; then
			echo "alias ll='ls -lGafh'" >> ~/.bash_profile 
			source ~/.bash_profile > /dev/null 2>&1 &
		fi
	else
		echo 1
	fi
	echo 0
}

process() {
	INSTALLS=(
		'zsh'
		'composer'
	)
	CONFIGS=(
		'bash'
		'zsh'
		'vim'
		'ssh'
		'git'
	)
	if [[ $1 == 'installs' ]]; then
		for install in ${INSTALLS[@]}; do
			echo "Installing ${install}...";
			if (( $("${install}_install") > 0 )) ; then
				if [[ $VERBOSE == 'yes' ]]; then
					echo 'Failed'
					return 1
				fi
			fi
		done
	elif [[ $1 == 'configs' ]]; then
		for config in ${CONFIGS[@]}; do
			if [[ $VERBOSE == 'yes' ]]; then
				echo "Configuring ${config}...";
			fi
			if (( $("${config}_config") > 0 )) ; then
				if [[ $VERBOSE == 'yes' ]]; then
					echo 'Failed'
					return 1
				fi
			fi
		done
	fi
}

help(){
	echo 'Usage: setup.sh [<options>]'
	echo
	echo 'Named options: '
	echo '	--install		Install requirements'
	echo '	--configure		Configure installed software'
	echo '	--verbose		Display output'
	echo '	--help			Show this help doc'
}

main()(
	VERBOSE=no
	INSTALL=no
	CONFIG=no
	while (( $# > 0 )); do
		case $1 in
		--verbose)		VERBOSE=yes; SOMETHING=no ;;
		--install)		INSTALL=yes;;
		--configure)	CONFIG=yes;;
		esac
		shift
	done
	if [[ "$INSTALL" == "yes" && "$CONFIG" == "yes" ]]; then
		process 'installs';process 'configs'
	elif [[ "$INSTALL" == "yes" ]]; then
		process 'installs'
	elif [[ "$CONFIG" == "yes" ]]; then
		process 'configs'
	else
		help
	fi
)

main "$@"
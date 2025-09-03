#!/bin/bash
#
# ~/.bashrc
#

# History Control
export HISTCONTROL=ignoredups

# Command Completion
complete -cf sudo
complete -cf man

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

#-----------------------
# Greeting, motd etc...
#-----------------------
#cowsay $(fortune)
#date
[ -z "$PS1" ] && return

PATH=$PATH:$HOME/.local/bin

#PS1='\[\033[01;32m\][\u@\h\[\033[01;37m\] \W\[\033[01;32m\]]\$\[\033[00m\] '

# Add support for git branch in prompt
source ~/.local/bin/git-prompt.sh
PS1='\[\033[01;32m\][\u@\h\[\033[01;37m\] \W\[\033[01;32m\]\[\033[01;35m\]$(__git_ps1 " (%s)")\[\033[01;32m\]]\$\[\033[00m\] '

# Setup keyboard
xset r rate 185 50

export GREP_COLOR="mt=1;33"
export EDITOR="vim"

### Aliases ###
alias more="less"
alias ll="ls -l"
alias la="ls -al"
alias random="strings -n8 /dev/urandom | egrep "[a-zA-Z0-9]{8}""
alias ls='ls --color=auto'
alias zip='7za a output.zip'
alias grep='grep --color=auto --line-number'
alias ..='cd ..'
alias ps='ps auxf'
alias halt='sudo halt'
alias mkdir='mkdir -p'
alias which='type -all'
alias path='echo -e ${PATH//:/\\n}'
alias view='vim -R'
alias ffuf='ffuf -c'

# -> SCRIPTS

man() {
	env \
		LESS_TERMCAP_mb=$(printf "\e[1;31m") \
		LESS_TERMCAP_md=$(printf "\e[1;31m") \
		LESS_TERMCAP_me=$(printf "\e[0m") \
		LESS_TERMCAP_se=$(printf "\e[0m") \
		LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
		LESS_TERMCAP_ue=$(printf "\e[0m") \
		LESS_TERMCAP_us=$(printf "\e[1;32m") \
			man "$@"
}
LS_COLORS='rs=0:di=1;33;44:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.webp=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:';
export LS_COLORS

# conda stuff
[ -f /opt/miniconda3/etc/profile.d/conda.sh ] && source /opt/miniconda3/etc/profile.d/conda.sh
CRYPTOGRAPHY_OPENSSL_NO_LEGACY=1

# autostart tmux
if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [[ -z "$TMUX" ]]; then
  exec tmux
fi

# Auto-activate virtualenv if .venv folder exists
function check_venv() {
    # Check if the current directory or any parent directory contains a .venv folder
    local dir=$(pwd)
    while [ "$dir" != "/" ]; do
        if [ -d "$dir/.venv" ]; then
            # Activate the virtual environment
            source "$dir/.venv/bin/activate"
            return 0
        fi
        dir=$(dirname "$dir")
    done
    # Deactivate if no .venv found
    if [[ -n "$VIRTUAL_ENV" ]]; then
        deactivate
    fi
}

# Automatically check and activate/deactivate virtualenv when changing directories
export PROMPT_COMMAND="check_venv; $PROMPT_COMMAND"

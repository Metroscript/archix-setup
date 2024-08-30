# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

#System stuff
alias ls=lsd
alias ll='lsd -l'
alias la='lsd -a'
alias find=fd
alias cat=bat
alias neofetch=fastfetch
alias cp='cp -riv'
alias mv='mv -iv'
alias mkdir='mkdir -vp'
alias rm='rm -Iv'
alias cl=clear
alias open=xdg-open
alias vim=nvim
alias grep='grep --colour=auto'
alias free='free -mht'
alias tree='tree --dirsfirst -C'
alias dmesg='dmesg -HePxL=auto'
alias ffmpeg='ffmpeg -hide_banner'
export VISUAL=/usr/bin/nvim
export EDITOR="$VISUAL"
export PATH="$PATH:$HOME/.cargo/bin"
source /usr/share/doc/pkgfile/command-not-found.bash
HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=5000
shopt -s cmdhist
shopt -s lithist
shopt -s histappend
shopt -sq autocd
shopt -sq checkwinsize
complete -cf sudo

#Pacman
alias p='sudo pacman -S'
alias r='sudo pacman -Rns'
alias s='pacman -Ss'
alias q='pacman -Qs'
alias u='paru -Syu;flatpak update;exit'

#YT-DLP
alias ytm='yt-dlp -x -f ba/b --audio-quality 0 --add-metadata --embed-thumbnail'
alias yt='yt-dlp -f bv+ba/b --embed-thumbnail --merge-output-format mp4'

#KEK
alias pony='fortune|ponysay 2> /dev/null'

#Other/Help
PS1='[\u@\h \W]\$ '

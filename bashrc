 
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

#System stuff
alias ls='lsd'
alias ll='lsd -l'
alias la='lsd -a'
alias find='fd'
alias slf='sudo lf'
alias cat='bat'
alias cp='cp -riv'
alias mv='mv -iv'
alias mkdir='mkdir -vp'
alias rm='rm -iv'
alias cl='clear'
alias v='vim'
alias open='xdg-open'
alias grep='grep --colour=auto'
alias free='free -mht'
alias tree='tree --dirsfirst -C'
alias dmesg='dmesg --color=auto --reltime --human --nopager --decode'
if grep -E neovim <<< $(pacman -Q neovim);then
    alias vim='nvim'
    export VISUAL="/usr/bin/nvim"
elif grep -E vim <<< $(pacman -Q vim);then
    export VISUAL="/usr/bin/vim";else
    export VISUAL="/usr/bin/nano"
fi
export EDITOR="$VISUAL"
source /usr/share/doc/pkgfile/command-not-found.bash
HISTCONTROL=ignoreboth
shopt -s cmdhist
shopt -s lithist
shopt -sq autocd
shopt -sq checkwinsize
complete -cf sudo

#Pacman
alias p='sudo pacman -S'
alias r='sudo pacman -Rns'
alias s='pacman -Ss'
alias q='pacman -Qs'
alias yay='paru'
alias update='sudo pacman -Syu && yt-dlp -U'
alias clean='sudo pacman -Sc'
alias ukernel="sudo pacman -Syu --needed linux{,-{headers,firmware,lts{,-headers}}}"
alias aur='paru -Syu --aur'

#YT-DLP
alias ytm='yt-dlp -x -f ba/b --audio-quality 0 --audio-format flac --add-metadata --embed-thumbnail -o ~/Music/%"(title)s.%(ext)"s'
alias yt='yt-dlp -f bv+ba/b'
alias yta='yt-dlp -x -f ba/b --audio-quality 0 --audio-format wav'

#KEK
alias speak='fortune | ponysay'

#Other/Help
alias tips='echo Write ISO to USB: sudo dd if=/path/to/iso/file.iso of=/dev/sdX status=progress'
PS1='[\u@\h \W]\$ '

##-----------------------------------------------------
## synth-shell-prompt.sh
if [ -f /home/endeavour/.config/synth-shell/synth-shell-prompt.sh ] && [ -n "$( echo $- | grep i )" ]; then
	source /home/endeavour/.config/synth-shell/synth-shell-prompt.sh
fi

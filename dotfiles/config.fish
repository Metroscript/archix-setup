if status is-interactive
#System stuff
alias ls lsd
alias ll 'lsd -l'
alias la 'lsd -a'
alias find fd
alias cat bat
alias neofetch fastfetch
alias cp 'cp -riv'
alias mv 'mv -iv'
alias mkdir 'mkdir -vp'
alias rm 'rm -Iv'
alias cl clear
alias open xdg-open
alias vim nvim
alias grep 'grep --colour=auto'
alias free 'free -mht'
alias tree 'tree --dirsfirst -C'
alias dmesg 'dmesg -HePxL=auto'
alias ffmpeg='ffmpeg -hide_banner'
set -x VISUAL /usr/bin/nvim
set -x EDITOR $VISUAL
set -x PATH "$PATH:$HOME/.cargo/bin"
set HISTCONTROL ignoreboth
set HISTSIZE 10000
set HISTFILESIZE 5000
    
#Pacman
alias p 'sudo pacman -S'
alias r 'sudo pacman -Rns'
alias s 'pacman -Ss'
alias q 'pacman -Qs'
alias u 'paru -Syu;flatpak update;exit'

#YT-DLP
alias ytm 'yt-dlp -x -f ba/b --audio-quality 0 --add-metadata --embed-thumbnail'
alias yt 'yt-dlp -f bv+ba/b --embed-thumbnail --merge-output-format mp4'

#KEK
alias pony 'fortune|ponysay 2> /dev/null'
end

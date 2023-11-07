if status is-interactive
    #System stuff
    alias sudo 'doas'
    alias ls 'lsd'
    alias ll 'lsd -l'
    alias la 'lsd -a'
    alias find 'fd'
    alias cat 'bat'
    alias cp 'cp -riv'
    alias mv 'mv -iv'
    alias mkdir 'mkdir -vp'
    alias rm 'rm -Iv'
    alias cl 'clear'
    alias vim 'nvim'
    alias open 'xdg-open'
    alias grep 'grep --colour=auto'
    alias free 'free -mht'
    alias tree 'tree --dirsfirst -C'
    alias dmesg 'dmesg -HePxL=auto'
    set -x VISUAL /usr/bin/nvim
    set -x EDITOR $VISUAL
    set -x GOPATH "$HOME/.go"
    set -x PATH "$PATH:$GOPATH/bin"
    set HISTCONTROL ignoreboth
    set HISTSIZE 10000
    set HISTFILESIZE 5000

    #Pacman
    alias p 'sudo pacman -S'
    alias r 'sudo pacman -Rns'
    alias u 'paru -Syu;flatpak update;exit'
    alias s 'pacman -Ss'
    alias q 'pacman -Qs'

    #YT-DLP
    alias ytm 'yt-dlp -x -f ba/b --audio-quality 0 --add-metadata --embed-thumbnail'
    alias yt 'yt-dlp -f bv+ba/b'

    #KEK
    alias pony 'fortune|ponysay'
end

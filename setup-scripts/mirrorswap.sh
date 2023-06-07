if [ $artix == y ] || [ $grub == y ];then
    bootdir=/etc/default/grub;else
    bootdir=/boot/loader/entries/arch.conf
fi

#Repo config + doas base-devel packages
if [ $artix == y ];then
    sudo sed -i -z -e 's;\[galaxy\]\nInclude = /etc/pacman.d/mirrorlist;\[galaxy\]\nInclude = /etc/pacman.d/mirrorlist\n\n\[universe\]\nServer = https://universe.artixlinux.org/$arch\nServer = https://mirror1.artixlinux.org/universe/$arch\nServer = https://mirror.pascalpuffke.de/artix-universe/$arch\nServer = https://artixlinux.qontinuum.space/artixlinux/universe/os/$arch\nServer = https://mirror1.cl.netactuate.com/artix/universe/$arch\nServer = https://ftp.crifo.org/artix-universe/$arch\nServer = https://artix.sakamoto.pl/universe/$arch;' -i -z -e 's;\[lib32\]\n#Include = /etc/pacman.d/mirrorlist;\[lib32\]\n#Include = /etc/pacman.d/mirrorlist\n\n#Arch Repos\n\n#\[testing\]\n#Include = /etc/pacman.d/mirrorlist-arch\n\n#\[extra\]\n#Include = /etc/pacman.d/mirrorlist-arch\n\n#\[multilib-testing\]\n#Include = /etc/pacman.d/mirrorlist-arch\n\n#\[multilib\]\n#Include = /etc/pacman.d/mirrorlist-arch;' /etc/pacman.conf
    sudo pacman -Syu --needed --noconfirm artix-archlinux-support
    sudo sed -i -e "/\[lib32\]/,/Include/"'s/^#//' -i -e "/\[extra\]/,/Include/"'s/^#//' /etc/pacman.conf
    sudo pacman-key --populate
fi
    sudo sed -i -e 's/#Color/Color/' -i -e '/Color/a ILoveCandy' -i -e 's/#Verbose/Verbose/' -i -e 's/#Parallel/Parallel/' -i -e "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
    sudo pacman -Sy
if [ $suas == y ];then
    sudo pacman -S --needed --noconfirm autoconf automake binutils bison debugedit fakeroot flex gcc groff libtool m4 make patch pkgconf texinfo which
fi
sudo pacman -S --needed --noconfirm reflector rsync pacman-contrib
if [ $artix == y ];then
    sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.pacnew
    sudo rankmirrors /etc/pacman.d/mirrorlist.pacnew > mirrorlist
    sudo rm /etc/pacman.d/mirrorlist
    sudo mv mirrorlist /etc/pacman.d/
    countr=$(curl https://ipapi.co/timezone)
    #####################################
    ### ADD SUPPORT FOR MORE COUNTRIES ##
    #####################################
    if grep -E "Australia" <<< ${countr};then
        country=Australia
    elif grep -E "Canada" <<< ${countr};then
        country=Canada
    elif grep -E "France" <<< ${countr};then
        country=France
    elif grep -E "Germany" <<< ${countr};then
        country=Germany
    elif grep -E "US" <<< ${countr};then
        country=US
    elif grep -E "Mexico" <<< ${countr};then
        country=Mexico
    elif grep -E "Chile" <<< ${countr};then
        country=Chile
    elif grep -E "Japan" <<< ${countr};then
        country=Japan
    elif grep -E "China" <<< ${countr};then
        country=China
    elif grep -E "America" <<< ${countr};then
        country=America
    fi
    ###################################
    ######## END OF PROBLEM AREA ######
    ###################################
    sudo reflector --save /etc/pacman.d/mirrorlist-arch --sort rate -c ${country} -p https,rsync;else
    sudo reflector --save /etc/pacman.d/mirrorlist --sort rate -c ${country} -p https,rsync
fi

sudo pacman -Sy

#Make Swapfile
if [ $swap -gt 0 ];then
    sudo dd if=/dev/zero of=/swapfile bs=1M count=$swap status=progress
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo cp /etc/fstab /etc/fstab.bak
    sudo echo '/swapfile none swap 0 0' | sudo tee -a /etc/fstab
    sudo mount -a
    sudo swapon -a
    free -m
    sudo sed -i -e 's/#resume=/resume=/' -i -e 's/quiet/swap_offset= quiet/' $bootdir
    sudo filefrag -v /swapfile | awk '$1=="0:" {print substr($4, 1, length($4)-2)}'
    printf "Remember the above value and place it in the swap offset value in your boot config (Press enter to continue)"
    read blank
    sudo vim $bootdir
fi

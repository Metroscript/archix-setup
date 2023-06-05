if [ $artix == y ] || [ $grub == y ];then
    bootdir=/etc/default/grub;else
    bootdir=/boot/loader/entries/arch.conf
fi

#Repo config + doas base-devel packages
if [ $artix == y ];then
    sudo mv ${repo}/dotfiles/root/artixpacman.conf /etc/pacman.conf
    sudo pacman -Sy --needed --noconfirm artix-archlinux-support
    sudo sed -i -e "/\[extra\]/,/Include/"'s/^#//' -i -e "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
    sudo pacman-key --populate
else
    sudo sed -i -e 's/#Color/Color/' -i -e '/Color/a ILoveCandy' -i -e 's/#Verbose/Verbose/' -i -e 's/#Parallel/Parallel/' -i -e "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
fi
sudo pacman -Sy
if [ $suas == y ];then
    sudo pacman -S --needed --noconfirm autoconf automake binutils bison debugedit fakeroot flex gcc groff libtool m4 make patch pkgconf texinfo which
fi
sudo pacman -S --needed --noconfirm reflector rsync
if [ $artix == y ];then
    sudo reflector --save /etc/pacman.d/mirrorlist-arch --sort rate -c Australia -p https,rsync;else
    sudo reflector --save /etc/pacman.d/mirrorlist --sort rate -c Australia -p https,rsync
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

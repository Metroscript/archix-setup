if [ $bin == y ];then
    git clone https://aur.archlinux.org/paru-bin.git
    cd paru-bin;else
    git clone https://aur.archlinux.org/paru.git
    cd paru
fi
#bat PKGBUILD
makepkg -si --noconfirm
cd
if ! grep -E ".config" <<< $(ls -a);then
    mkdir -p .config/paru/;else
    mkdir .config/paru/
fi

cp /etc/paru.conf .config/paru/
#sed -i -e 's/#SudoLoop/SudoLoop/' 
sed -i -e 's/#Clean/Clean/' -i -e 's/#UpgradeMenu/UpgradeMenu/' -i -e 's/#News/News/' .config/paru/paru.conf

if [ $suas == y ];then
    #sed -i -e 's/SudoLoop/SudoLoop = true/'
    sed -i -e 's/#\[bin\]/\[bin\]/' -i -e 's\#Sudo = doas\Sudo = /bin/doas\' .config/paru/paru.conf
else
    echo "No changes Needed"
fi


if [ $bin == y ];then
    if [ $de == 1 ];then
        paru -S sddm-git archlinux-themes-sddm
    fi
    if [ $gayms == y ];then
        if [ $rlx == y ];then
            paru -S grapejuice-git
        fi
        if [ $min == y ];then
            paru -S prismlauncher-bin
        fi
        if [ $waydroid == y ];then
            paru -S waydroid
        fi
    fi
    if [ $artix == y ];then
        paru -S downgrade
        sudo pacman -S --needed --noconfirm librewolf timeshift;else
        paru -S downgrade librewolf-bin timeshift-bin
    fi
else
    if [ $de == 1 ];then
        paru -S sddm-git archlinux-themes-sddm
    fi
    if [ $gayms == y ];then
        if [ $rlx == y ];then
            paru -S grapejuice-git
        fi
        if [ $min == y ];then
            paru -S prismlauncher
        fi
        if [ $waydroid == y ];then
            paru -S waydroid
        fi
    fi
    if [ $artix == y ];then
        paru -S downgrade
        sudo pacman -S --needed --noconfirm librewolf timeshift;else
        paru -S librewolf timeshift downgrade
    fi
fi

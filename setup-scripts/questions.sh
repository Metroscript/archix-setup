#SET EDITOR#
if grep -E neovim <<< $(pacman -Q);then
    alias vim='nvim'
    sed -i 's,VISUAL=,VISUAL="/usr/bin/nvim",' ${repo}dotfiles/bashrc
elif grep -E emacs <<< $(pacman -Q);then
    alias vim='emacs -nw'
    sed -i 's,VISUAL=,VISUAL="/usr/bin/emacs",' ${repo}dotfiles/bashrc
elif grep -E nano <<< $(pacman -Q);then
    alias vim='nano'
    sed -i 's,VISUAL=,VISUAL="/usr/bin/nano",' ${repo}dotfiles/bashrc;else
    sed -i 's,VISUAL=,VISUAL="/usr/bin/vim",' ${repo}dotfiles/bashrc
fi

if grep -E "cronie" <<< $(pacman -Q);then
    cron=cronie
elif grep -E "fcron" <<< $(pacman -Q)
    cron=fcron
else
    echo "What cron provider would you like to use? 1.Cronie (Default) or 2. Fcron?"
    printf "[1/2]: "
    read croninst
    until [ $croninst == 1 ] || [ $croninst == 2 ];do
        echo "What cron provider would you like to use? 1.Cronie (Default) or 2. Fcron?"
        printf "[1/2]: "
        read croninst
    done
fi
if grep -E "Artix" <<< $(cat /etc/issue);then
    artix=y
    sed -i -e 's/#exec-once/exec-once/' -i -e '/--systemd/d' -i -e '/systemctl/d' ${repo}dotfiles/hypr-rice/hypr/hyprland.conf
    sed -i -e 's/action" : "reboot/action" : "loginctl reboot/' -i -e 's/poweroff/loginctl poweroff/' -i -e 's/action" : "suspend/action" : "loginctl suspend/' ${repo}dotfiles/hypr-rice/wlogout/layout
    if grep -E openrc <<< $(pacman -Q openrc);then
        init=openrc
    elif grep -E runit <<< $(pacman -Q runit);then
        init=runit
    elif grep -E s6-base <<< $(pacman -Q s6-base);then
        init=s6
    elif grep -E dinit <<< $(pacman -Q dinit);then
        init=dinit
    fi;else
    artix=n
    if grep -E grub <<< $(pacman -Q grub);then
        grub=y;else
        grub=n
    fi
fi

if [ $artix == y ] || [ $grub == y ];then
    bootdir=/etc/default/grub;else
    bootdir=/boot/loader/entries/arch.conf
fi

if grep -E "opendoas" <<< $(pacman -Q opendoas);then
    suas=y
    alias sudo='doas'
    sed -i "/stuff/a alias sudo='doas'" ${repo}dotfiles/bashrc
    echo "-----------------------------------------------------------------------------------------"
    echo -e "SudoLoop is enabled on paru, when tweaking doas.conf, put 'permit persist :wheel as root cmd true' so SudoLoop works\nYou should make any changes & run 'chmod 0400 /etc/doas.conf' as root after install"
    echo "-----------------------------------------------------------------------------------------"
    sleep 5;else
    suas=n
fi

if grep -E networkmanager <<< $(pacman -Q);then
    printf "Enable Network Privacy features for NetworkManager? (May cause network instability) [y/n]: "
    read nmp
    until [ $nmp == y ] || [ $nmp == n ];do
        echo "Sorry, please try again"
        printf "Enable Network Privacy features for NetworkManager? (May cause network instability) [y/n]: "
        read nmp
    done
    if [ $nmp == y ];then
        echo -e "[device]\nwifi.scan-rand-mac-address=yes\n\n[connection]\nwifi.cloned-mac-address=random\nethernet.cloned-mac-address=random" > 99-random-mac.conf
        sudo chown root:root 99-random-mac.conf
        sudo mv 99-random-mac.conf /etc/NetworkManager/conf.d/
        printf "Change hostname to 'localhost'? (Improves DHC privacy) [y/n]: "
        read host
        until [ $host == y ] || [ $host == n ];do
            echo "Sorry, please try again."
            printf "Change hostname to 'localhost'? (Improves DHC privacy) [y/n]: "
            read host
        done
        if [ $host == y ];then
            echo "localhost" > hostname
            sudo chown root:root hostname
            sudo mv hostname /etc/
        fi
        sudo nmcli general reload conf
    fi
fi

############################################################################
########### ADD SUPPORT FOR OTHER GUIs? ####################################
############################################################################
echo "Which DE/WM would you like to install? 1.Hyprland or 2.KDE Plasma"
printf "[1/2]: "
read de
until [ $de == 1 ] || [ $de == 2 ];do
    echo "Please try again. Which DE/WM would you like to install? 1.Hyprland or 2.KDE Plasma"
    printf "[1/2]: "
    read de
done
if [ $de == 1 ] || [ $de == 2 ];then
    dm=sddm
fi
############################################################################
####################### END OF PROBLEM AREA ################################
############################################################################

printf "Use precompiled AUR binaries where availiable? [y/n]: "
read bin
until [ $bin == y ] || [ $bin == n ];do
    echo "Sorry, please try again."
    printf "Use precompiled binaries where availiable? [y/n]: "
    read bin
done

printf "Install Emulation & Steam/WINE support? [y/n]: "
read gayms
until [ $gayms == y ] || [ $gayms == n ];do
    echo "Sorry, please try again"
    printf "Install Emulation & Steam/WINE support? [y/n]: "
    read gayms
done
if [ $gayms == y ];then
    printf "Install Grapejuice? (A WINE wrapper for Roblox) [y/n]: "
    read rlx
    until [ $rlx == y ] || [ $rlx == n ];do
        echo "Sorry, please try again"
        printf "Install Grapejuice? (A WINE wrapper for Roblox) [y/n]: "
        read rlx
    done
    printf "Install Prismlauncher? (A custom Minecraft launcher with mod support) [y/n]: "
    read min
    until [ $min == y ] || [ $min == n ];do
        echo "Sorry, please try again."
        printf "Install Prismlauncher? (A custom Minecraft launcher with mod support) [y/n]: "
        read min
    done
    if [ $de == 1 ] || [ $de == 2 ] || [ $de == 3 ];then
        printf "Install WayDroid? (An Android emulator that exclusively runs on Wayland) [y/n]: "
        read waydroid
        until [ $waydroid == y ] || [ $waydroid == n ];do
            echo "Sorry, please try again."
            printf "Install WayDroid? (An Android emulator that exclusively runs on Wayland) [y/n]: "
            read waydroid
    done
    fi
fi

echo "Swapfile size. 2048Mib is usually a good choice. Put '0' for no swapfile."
printf "Size of swapfile in Mib: "
read swap
until [ $swap -ge 0 ];do
    echo "Sorry, please try again."
    echo "Swapfile size. 2048Mib is usually a good choice. Put '0' for no swapfile."
    printf "Size of swapfile in Mib: "
    read swap
done

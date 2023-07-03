#SET EDITOR#
if grep -E neovim <<< $(pacman -Q);then
    sed -i -e 's,VISUAL=,VISUAL="/usr/bin/nvim",' -i -e "/cl=/a alias vim='nvim'" ${repo}dotfiles/bashrc
elif grep -E emacs <<< $(pacman -Q);then
    sed -i 's,VISUAL=,VISUAL="/usr/bin/emacs -nw",' ${repo}dotfiles/bashrc
elif grep -E nano <<< $(pacman -Q);then
    sed -i 's,VISUAL=,VISUAL="/usr/bin/nano",' ${repo}dotfiles/bashrc;else
    sed -i 's,VISUAL=,VISUAL="/usr/bin/vim",' ${repo}dotfiles/bashrc
fi

if grep mkinitcpio <<< $(pacman -Q);then
    img=mkinit
elif grep dracut <<< $(pacman -Q);then
    img=dracut;else
    img=booster
fi

###################################################################################################
########### ADD SUPPORT FOR OTHER INITRAMFs GENERATORs? ###########################################
###################################################################################################
#if ( [ $img == dracut ] && ! grep 'hostonly="true"' /etc/dracut.conf.d/* ) || ( [ $img == booster ] && ! grep 'universal: false' /etc/booster.yaml && ! grep 'universal: true' /etc/booster.yaml );then
#    printf "Enable hostonly initramfs generation? (Speeds up generation by excluding modules your system doesn't need) [y/n]: "
#    read hostonly
#    until [ $hostonly == y ] || [ $hostonly == n ];do
#        printf "Enable hostonly initramfs generation? (Speeds up generation by excluding modules your system doesn't need) [y/n]: "
#        read hostonly
#    done
#    if [ $hostonly == y ];then
#        if [ $img == dracut ];then
#            sudo sh -c 'echo hostonly=\"yes\" > /etc/dracut.conf.d/hostonly.conf'
#            sudo dracut-rebuild #;else
            #sudo sh -c 'echo "universal: false" >> /etc/booster.yaml'
            #sudo booster build
#        fi
#    fi
#fi

if grep Artix <<< $(cat /etc/issue);then
    artix=y
    sed -i -e 's/#exec-once/exec-once/' -i -e '/--systemd/d' -i -e '/systemctl/d' ${repo}dotfiles/hypr-rice/hypr/hyprland.conf
    sed -i -e 's/action" : "reboot/action" : "loginctl reboot/' -i -e 's/poweroff/loginctl poweroff/' -i -e 's/action" : "suspend/action" : "loginctl suspend/' ${repo}dotfiles/hypr-rice/wlogout/layout
    if grep openrc <<< $(pacman -Q openrc);then
        init=openrc
    elif grep runit <<< $(pacman -Q runit);then
        init=runit
    elif grep s6-base <<< $(pacman -Q s6-base);then
        init=s6
    elif grep dinit <<< $(pacman -Q dinit);then
        init=dinit
    fi
fi

bootdir=/etc/default/grub

if grep opendoas <<< $(pacman -Q opendoas);then
    suas=y
    alias sudo='doas'
    sed -i "/stuff/a alias sudo='doas'" ${repo}dotfiles/bashrc
    echo "-----------------------------------------------------------------------------------------"
    echo -e "SudoLoop is enabled on paru, when tweaking doas.conf, put 'permit persist :wheel as root cmd true' so SudoLoop works\nYou should make any changes & run 'chmod 0400 /etc/doas.conf' as root after install"
    echo "-----------------------------------------------------------------------------------------"
    sleep 5
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
printf "Install Plymouth? (Adds boot splash screen) [y/n]: "
read ply
until [ $ply == y ] || [ $ply == n ];do
    printf "Install Plymouth? (Adds boot splash screen) [y/n]: "
    read ply
done
printf "Install MakeMKV? (A DVD/Bluray ripper) [y/n]: "
read makemkv
until [ $makemkv == y ] || [ $makemkv == n ];do
    printf "Install MakeMKV? (A DVD/Bluray ripper) [y/n]: "
    read makemkv
done
printf "Install OpenRGB? (RGB management software) [y/n]: "
read rgb
until [ $rgb == y ] || [ $rgb == n ];do
    printf "Install OpenRGB? (RGB management software) [y/n]: "
    read rgb
done
if ! grep Size <<< $(swapon -s);then
    echo "Swapfile size. 2048Mib is usually a good choice. Put '0' for no swapfile."
    printf "Size of swapfile in Mib: "
    read swap
    until [ $swap -ge 0 ];do
        echo "Sorry, please try again."
        echo "Swapfile size. 2048Mib is usually a good choice. Put '0' for no swapfile."
        printf "Size of swapfile in Mib: "
        read swap
    done
    if [ $swap -gt 0 ];then
        printf "Enable suspend to & resume from disk support? [y/n]: "
        read res
        until [ $res == y ] || [ $res == n ];do 
            printf "Enable suspend to & resume from disk support? [y/n]: "
            read res
        done
    fi
fi

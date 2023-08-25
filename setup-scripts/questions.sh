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
    sdir=/etc/elogind/
    sed -i -e 's/#exec-once/exec-once/' -i -e '/--systemd/d' -i -e '/systemctl/d' ${repo}dotfiles/hypr-rice/hypr/hyprland.conf
    sed -i -e 's/action" : "reboot/action" : "loginctl reboot/' -i -e 's/poweroff/loginctl poweroff/' -i -e 's/action" : "suspend/action" : "loginctl suspend/' ${repo}dotfiles/hypr-rice/wlogout/layout
    if grep openrc <<< $(pacman -Q);then
        init=openrc
    elif grep runit <<< $(pacman -Q);then
        init=runit
    elif grep s6-base <<< $(pacman -Q);then
        init=s6
    elif grep dinit <<< $(pacman -Q);then
        init=dinit
    fi;else
    sdir=/etc/systemd/
fi

bootdir=/etc/default/grub

if grep opendoas <<< $(pacman -Q);then
    suas=y
    alias sudo='doas'
    sed -i "/stuff/a alias sudo='doas'" ${repo}dotfiles/bashrc
    echo "-----------------------------------------------------------------------------------------"
    echo -e "SudoLoop is enabled on paru, when tweaking doas.conf, put 'permit persist :wheel cmd true' so SudoLoop works\nYou should make any changes & run 'chmod 0400 /etc/doas.conf' as root after install"
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

printf "Enable compile optimisations such as multithreading & native binaries to makepkg.conf? [y/n]: "
read opt
until [ $opt == y ] || [ $opt == n ];do
    echo "Sorry, please try again."
    printf "Enable compile optimisations such as multithreading & native binaries to makepkg.conf? [y/n]: "
    read opt
done

printf "Install multithreaded drop-ins for gzip & bzip2? [y/n]: "
read mtdi
until [ $mtdi == y ] || [ $mtdi == n ];do
    echo "Sorry, please try again."
    printf "Install multithreaded drop-ins for gzip & bzip2? [y/n]: "
    read mtdi
done

printf "Install Emulation & Steam/WINE support? [y/n]: "
read gayms
until [ $gayms == y ] || [ $gayms == n ];do
    echo "Sorry, please try again"
    printf "Install Emulation & Steam/WINE support? [y/n]: "
    read gayms
done
if [ $gayms == y ];then
    printf "Install Vinegar? (A WINE wrapper for Roblox) [y/n]: "
    read rlx
    until [ $rlx == y ] || [ $rlx == n ];do
        echo "Sorry, please try again"
        printf "Install Vinegar? (A WINE wrapper for Roblox) [y/n]: "
        read rlx
    done
    printf "Install Prismlauncher? (A custom Minecraft launcher with mod support) [y/n]: "
    read min
    until [ $min == y ] || [ $min == n ];do
        echo "Sorry, please try again."
        printf "Install Prismlauncher? (A custom Minecraft launcher with mod support) [y/n]: "
        read min
    done
fi
echo "What shell would you like to use? (Use BASH if unsure) 1.BASH 2.FISH"
printf "[1/2]: "
read shel
until [ $shel == 1 ] || [ $shel == 2 ];do
    echo "What shell would you like to use? (Use BASH if unsure) 1.BASH 2.FISH"
    printf "[1/2]: "
    read shel
done
if [ $shel == 1 ];then
    shell=bash;else
    shell=fish
fi
echo "What cron would you like? (If unsure, choose Cronie) 1.Cronie or 2.Fcron"
printf "[1/2]: "
read crock
until [ $crock == 1 ] || [ $crock == 2 ];do
    echo "What cron would you like? (If unsure, choose Cronie) 1.Cronie or 2.Fcron"
    printf "[1/2]: "
    read crock
done
if [ $crock == 1 ];then
    cron=cronie;else
    cron=fcron
fi
printf "Install Plymouth? (Adds boot splash screen) [y/n]: "
read ply
until [ $ply == y ] || [ $ply == n ];do
    printf "Install Plymouth? (Adds boot splash screen) [y/n]: "
    read ply
done
if [ $ply == y ];then
    echo 'Select Plymouth Theme: spinner, bgrt, breeze, breeze-text, fade-in, glow, solar, spininfinity, spinner, text, tribar, script, details.'
    printf "Type desired theme name: "
    read plytheme
    until [ "$plytheme" == spinner ] || [ "$plytheme" == bgrt ] || [ "$plytheme" == breeze ] || [ "$plytheme" == breeze-text ] || [ "$plytheme" == fade-in ] || [ "$plytheme" == glow ] || [ "$plytheme" == solar ] ||  [ "$plytheme" == spininfinity ] || [ "$plytheme" == text ] || [ "$plytheme" == tribar ] || [ "$plytheme" == script ] || [ "$plytheme" == details ];do
        echo 'Sorry, please try again.'
        echo 'Select Plymouth Theme: spinner, bgrt, breeze, breeze-text, fade-in, glow, solar, spininfinity, spinner, text, tribar, script, details.'
        printf "Type desired theme name: "
        read plytheme
    done
    if [ "$plytheme" == bgrt ];then
        printf "Remove distro watermark to leave only BIOS vender logo? [y/n] "
        read vr
        until [ "$vr" == y ] || [ "$vr" == n ];do
            echo "Sorry, please try again."
            printf "Remove distro watermark to leave only BIOS vender logo? [y/n] "
            read vr
        done
    fi
fi
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
if [ $rgb == y ];then
    printf "Are you planning to control motherboard or RAM LEDs? [y/n]: "
    read rgsmb
    until [ $rgsmb == y ] || [ $rgsmb == n ];do
        printf "Are you planning to control motherboard or RAM LEDs? [y/n]: "
        read rgsmb
    done
fi
if [ $img == mkinit ];then
    printf "Install mkinitcpio-firmware (Removes missing firmware warnings when generating initramfs) [y/n]: "
    read mkfirm
    until [ $mkfirm == y ] || [ $mkfirm == n ];do
        echo "Sorry, please try again."
        printf "Install mkinitcpio-firmware (Removes missing firmware warnings when generating initramfs) [y/n]: "
        read mkfirm
    done
fi
printf "Add installed kernels & firmware to IgnorePkg? [y/n]: "
read kignore
until [ $kignore == y ] || [ $kignore == n ];do
    echo "Sorry, please try again."
    printf "Add installed kernels & firmware to IgnorePkg? [y/n]: "
    read kignore
done

if ! grep Size <<< $(swapon -s);then
    echo "Swapfile size. 8192/Equal to RAM Mib is usually a good choice for hibernation. Put '0' for no swapfile."
    printf "Size of swapfile in Mib: "
    read swap
    until [ $swap -ge 0 ];do
        echo "Sorry, please try again."
        echo "Swapfile size. 8192/Equal to RAM Mib is usually a good choice. Put '0' for no swapfile."
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

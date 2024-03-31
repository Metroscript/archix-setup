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

if grep -q Artix <<< $(cat /etc/issue);then
    artix=y
    sdir=/etc/elogind/
    sed -i -e 's/#exec-once/exec-once/' -i -e '/--systemd/d' -i -e '/systemctl/d' ${repo}dotfiles/hypr-rice/hypr/hyprland.conf
    sed -i -e 's/action" : "reboot/action" : "loginctl reboot/' -i -e 's/poweroff/loginctl poweroff/' -i -e 's/action" : "suspend/action" : "loginctl suspend/' ${repo}dotfiles/hypr-rice/wlogout/layout
    if grep -q openrc <<< $(pacman -Q);then
        init=openrc
    elif grep -q runit <<< $(pacman -Q);then
        init=runit
    elif grep -q s6-base <<< $(pacman -Q);then
        init=s6
    elif grep -q dinit <<< $(pacman -Q);then
        init=dinit
    fi;else
    sdir=/etc/systemd/
fi

bootdir=/etc/default/grub

if grep -q opendoas <<< $(pacman -Q);then
    suas=y
    alias sudo='doas'
    sed -i "/stuff/a alias sudo=doas" ${repo}dotfiles/bashrc
    sed -i "/stuff/a alias sudo 'doas'" ${repo}dotfiles/config.fish
fi

if grep -q btrfs <<< $(sudo blkid);then
    btrfs=y
fi

############################################################################
########### ADD SUPPORT FOR OTHER GUIs? ####################################
############################################################################
echo "Which DE/WM would you like to install? 1.Hyprland or 2.KDE Plasma"
printf "[1/2]: "
read de
until [ "$de" == 1 ] || [ "$de" == 2 ];do
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

printf "Use repo dotfiles? (Does not apply to Hyprland Rice) [y/n]: "
read dotfs
until [ "$dotfs" == y ] || [ "$dotfs" == n ];do
    echo "Sorry, please try again."
    printf "Use repo dotfiles? (Does not apply to Hyprland Rice) [y/n]: "
    read dotfs
done

printf "Use precompiled AUR binaries where availiable? [y/n]: "
read bin
until [ "$bin" == y ] || [ "$bin" == n ];do
    echo "Sorry, please try again."
    printf "Use precompiled binaries where availiable? [y/n]: "
    read bin
done

printf "Enable compile optimisations such as multithreading & native binaries to makepkg.conf? [y/n]: "
read opt
until [ "$opt" == y ] || [ "$opt" == n ];do
    echo "Sorry, please try again."
    printf "Enable compile optimisations such as multithreading & native binaries to makepkg.conf? [y/n]: "
    read opt
done

printf "Install multithreaded drop-ins for gzip & bzip2? [y/n]: "
read mtdi
until [ "$mtdi" == y ] || [ "$mtdi" == n ];do
    echo "Sorry, please try again."
    printf "Install multithreaded drop-ins for gzip & bzip2? [y/n]: "
    read mtdi
done

printf "Install Virtualisation Software? [y/n]: "
read vir
until [ "$vir" == y ] || [ "$vir" == n ];do
    echo "Sorry, please try again"
    printf "Install Virtualisation Software? [y/n]: "
    read vir
done
if [ $vir == y ];then
    echo "Install 1.Qemu, 2.Virtualbox or 3.Both?"
    printf " [1/2/3]: "
    read virt
    until [ "$virt" == 1 ] || [ "$virt" == 2 ] || [ "$virt" == 3 ];do
        echo "Sorry, please try again"
        echo "Install 1.Qemu, 2.Virtualbox or 3.Both?"
        printf " [1/2/3]: "
        read virt
    done;else
    virt=0
fi
printf "Install WINE Games support? (Steam, Lutris, HeroicLauncher) [y/n]: "
read games
until [ "$games" == y ] || [ "$games" == n ];do
    echo "Sorry, please try again"
    printf "Install WINE Games support? (Steam, Lutris, HeroicLauncher) [y/n]: "
    read games
done
if [ $games == y ];then
    printf "Install Vinegar? (A WINE wrapper for Roblox) [y/n]: "
    read rlx
    until [ "$rlx" == y ] || [ "$rlx" == n ];do
        echo "Sorry, please try again"
        printf "Install Vinegar? (A WINE wrapper for Roblox) [y/n]: "
        read rlx
    done
    printf "Install Prismlauncher? (A custom Minecraft launcher with mod support - Flatpak) [y/n]: "
    read min
    until [ "$min" == y ] || [ "$min" == n ];do
        echo "Sorry, please try again."
        printf "Install Prismlauncher? (A custom Minecraft launcher with mod support - Flatpak) [y/n]: "
        read min
    done
    printf "Install console emulators? (Most are installed through Flatpak) [y/n]: "
    read emu
    until [ "$emu" == y ] || [ "$emu" == n ];do
        printf "Install console emulators? (Most are installed through Flatpak) [y/n]: "
        read emu
    done
    if [ "$emu" == y ];then
        printf "Install MelonDS? (DS emulator) [y/n]: "
        read melonds
        until [ "$melonds" == y ] || [ "$melonds" == n ];do
            printf "Install MelonDS? (DS emulator) [y/n]: "
            read melonds
        done
        printf "Install Citra? (3DS emulator [NO LONGER MAINTAINED]) [y/n]: "
        read citra
        until [ "$citra" == y ] || [ "$citra" == n ];do
            printf "Install Citra? (3DS emulator [NO LONGER MAINTAINED]) [y/n]: "
            read citra
        done
        printf "Install Dolphin? (Gamecube/Wii emulator) [y/n]: "
        read dolphin
        until [ "$dolphin" == y ] || [ "$dolphin" == n ];do
            printf "Install Dolphin? (Gamecube/Wii emulator) [y/n]: "
            read dolphin
        done
        printf "Install Cemu? (Wii U emulator) [y/n]: "
        read cemu
        until [ "$cemu" == y ] || [ "$cemu" == n ];do
            printf "Install Cemu? (Wii U emulator) [y/n]: "
            read cemu
        done
        printf "Install Ryujinx? (Switch emulator) [y/n]: "
        read switch
        until [ "$switch" == y ] || [ "$switch" == n ];do
            printf "Install Ryujinx? (Switch emulator) [y/n]: "
            read switch
        done
        printf "Install Duckstation? (PS1 emulator) [y/n]: "
        read duckstation
        until [ "$duckstation" == y ] || [ "$duckstation" == n ];do
            printf "Install Duckstation? (PS1 emulator) [y/n]: "
            read duckstation
        done
        printf "Install PCSX2? (PS2 emulator) [y/n]: "
        read pcsx2
        until [ "$pcsx2" == y ] || [ "$pcsx2" == n ];do
            printf "Install PCSX2? (PS2 emulator) [y/n]: "
            read pcsx2
        done
        printf "Install PPSSPP? (PS Portable emulator) [y/n]: "
        read ppsspp
        until [ "$ppsspp" == y ] || [ "$ppsspp" == n ];do
            printf "Install PPSSPP? (PS Portable emulator) [y/n]: "
            read ppsspp
        done
    fi
fi
echo "Install Multimedia tools? (Kdenlive, OBS)"
printf "[y/n]: "
read multitools
until [ "$multitools" == y ] || [ "$multitools" == n ];do
    echo "Install Multimedia tools? (Kdenlive, OBS)"
    printf "[y/n]: "
    read multitools
done

echo "Install Graphics tools? (GIMP, Blender)"
printf "[y/n]: "
read graphitools
until [ "$graphitools" == y ] || [ "$graphitools" == n ];do
    echo "Install Graphics tools? (GIMP, Blender)"
    printf "[y/n]: "
    read graphitools
done
echo "Install LibreOffice?"
printf "[y/n]: "
read office
until [ "$office" == y ] || [ "$office" == n ];do
    echo "Install LibreOffice?"
    printf "[y/n]: "
    read office
done
echo "What shell would you like to use? (Use BASH if unsure) 1.BASH 2.FISH"
printf "[1/2]: "
read shell
until [ "$shell" == 1 ] || [ "$shell" == 2 ];do
    echo "What shell would you like to use? (Use BASH if unsure) 1.BASH 2.FISH"
    printf "[1/2]: "
    read shell
done
if [ $shell == 1 ];then
    shell=bash;else
    shell=fish
fi
echo "What cron would you like? (If unsure, choose Cronie) 1.Cronie or 2.Fcron"
printf "[1/2]: "
read cron
until [ "$cron" == 1 ] || [ "$cron" == 2 ];do
    echo "What cron would you like? (If unsure, choose Cronie) 1.Cronie or 2.Fcron"
    printf "[1/2]: "
    read cron
done
if [ $cron == 1 ];then
    cron=cronie;else
    cron=fcron
fi
printf printf "Sort package mirrors to prioritse faster servers? [y/n]: "
read mirrorsort
until [ "$mirrorsort" == y ] || [ "$mirrorsort" == n ];do
    printf "Sort package mirrors to prioritse faster servers? [y/n]: "
    read mirrorsort
done
printf "Install Plymouth? (Adds boot splash screen) [y/n]: "
read ply
until [ "$ply" == y ] || [ "$ply" == n ];do
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
until [ "$makemkv" == y ] || [ "$makemkv" == n ];do
    printf "Install MakeMKV? (A DVD/Bluray ripper) [y/n]: "
    read makemkv
done
printf "Install OpenRGB? (RGB management software) [y/n]: "
read rgb
until [ "$rgb" == y ] || [ "$rgb" == n ];do
    printf "Install OpenRGB? (RGB management software) [y/n]: "
    read rgb
done
if [ $rgb == y ];then
    printf "Are you planning to control motherboard or RAM LEDs? [y/n]: "
    read rgsmb
    until [ "$rgsmb" == y ] || [ "$rgsmb" == n ];do
        printf "Are you planning to control motherboard or RAM LEDs? [y/n]: "
        read rgsmb
    done
fi
if [ $img == mkinit ];then
    printf "Install mkinitcpio-firmware (Removes missing firmware warnings when generating initramfs) [y/n]: "
    read mkfirm
    until [ "$mkfirm" == y ] || [ "$mkfirm" == n ];do
        echo "Sorry, please try again."
        printf "Install mkinitcpio-firmware (Removes missing firmware warnings when generating initramfs) [y/n]: "
        read mkfirm
    done
fi
#printf "Add installed kernels & firmware to IgnorePkg? [y/n]: "
#read kignore
#until [ "$kignore" == y ] || [ "$kignore" == n ];do
#    echo "Sorry, please try again."
#    printf "Add installed kernels & firmware to IgnorePkg? [y/n]: "
#    read kignore
#done

echo "Enable Kernel lockdown to prevent modification of kernel during runtime? (Prevents non-signed kernel modules from loading & disables hibernation)"
echo "0.No (Default) 1.Integrity (Standard Lockdown) 2.Confidential (Changes how RAM is accessed; Can cause issues)"
printf "0/1/2: "
read lckdwn
until [ "$lckdwn" == 0 ] || [ "$lckdwn" == 1 ] || [ "$lckdwn" == 2 ];do
    echo "Enable Kernel lockdown to prevent modification of kernel during runtime? (Prevents non-signed kernel modules from loading & disables hibernation)"
    echo "0.No (Default) 1.Integrity (Standard Lockdown) 2.Confidential (Changes how RAM is accessed; Can cause issues)"
    printf "0/1/2: "
    read lckdwn
done

if [ $lckdwn -gt 0 ] && [ "$virt" -ge 2 ];then
    echo "VIRTUALBOX KERNEL MODULES DO NOT APPLY WITH LOCKDOWN. ARE YOU SURE YOU STILL WANT TO ENABLE LOCKDOWN?"
    printf "[y/n]: "
    read lckdwn_con
    until [ "$lckdwn_con" == y ] || [ "$lckdwn_con" == n ];do
        echo "VIRTUALBOX KERNEL MODULES DO NOT APPLY WITH LOCKDOWN. ARE YOU SURE YOU STILL WANT TO ENABLE LOCKDOWN?"
        printf "[y/n]: "
        read lckdwn_con
    done
    if [ $lckdwn_con == n ];then
        lckdwn=0
    fi
fi

if ! grep Size <<< $(swapon -s);then
    echo "Swapfile size in GiB. Matching RAM size OR RAM x 1.5 sized swap is usually a good choice for hibernation. Put '0' for no swapfile."
    printf "Size of swapfile in GiB: "
    read swap
    until [ "$swap" -ge 0 ];do
        echo "Sorry, please try again."
        echo "Swapfile size in GiB. Put '0' for no swapfile."
        printf "Size of swapfile in GiB: "
        read swap
    done
    if [ $swap -gt 0 ];then
        if [ "$btrfs" == y ];then
            printf "What would you like your swap subvolume to be called?: "
            read swapvol
            echo "Are you sure you want to call your swap subvolume \"${swapvol}\"?"
            printf "[y/n]: "
            read swapvolconf
            until [ "$swapvolconf" == y ] || [ "$swapvolconf" == n ];do
                echo "Are you sure you want to call your swap subvolume \"${swapvol}\"?"
                printf "[y/n]: "
                read swapvolconf
            done
            if [ "$swapvolconf" == n ];then
                until [ "$swapvolconf" == y ];do
                    printf "What would you like your swap subvolume to be called?: "
                    read swapvol
                    echo "Are you sure you want to call your swap subvolume \"${swapvol}\"?"
                    printf "[y/n]: "
                    read swapvolconf
                    until [ "$swapvolconf" == y ] || [ "$swapvolconf" == n ];do
                        echo "Are you sure you want to call your swap subvolume \"${swapvol}\"?"
                        printf "[y/n]: "
                        read swapvolconf
                    done
            done
            fi
        fi
        if [ $swap -ge $(($(grep MemTotal /proc/meminfo|cut -d: -f2|cut -dk -f1)/1024/1024)) ] && [ "$lckdwn" == 0 ];then
            printf "Enable suspend to & resume from disk support? [y/n]: "
            read res
            until [ $res == y ] || [ $res == n ];do 
                printf "Enable suspend to & resume from disk support? [y/n]: "
                read res
            done
        fi
    fi
fi
if [ "$btrfs" == y ];then
    echo "Install snapper & snap-pac for automated subvolume snapshots?"
    printf "[y/n]: "
    read snap
    until [ $snap == y ] || [ $snap == n ];do
        echo "Install snapper & snap-pac for automated subvolume snapshots?"
        printf "[y/n]: "
        read snap
    done
    if [ $snap == y ];then
        echo "Additional changes to snapshot configs must be done manually after install"
        sleep 5
        if grep .snapshots <<< $(ls -a /);then
            echo "/.snapshots directory detected! Prevents snapper from installing! /.snapshots will be unmounted and removed until snapper recreates the directory & any fstab entries for /.snapshots will be removed!"
            sleep 5
            snap_dir=y
        fi
        if [ "$suas" == y ];then
            echo -e 'alias sudo=doas\n' > ~/archix-setup/snapper_conf_gen.sh
        fi
        for submnt in $(findmnt -nt btrfs|cut -d\  -f1|sed 's/─//'|sed 's/├//'|sed 's/└//');do 
            subvol=$(findmnt -nt btrfs|grep "$submnt "|sed 's,.*subvol=/,,')
            echo "Create snapshot config for subvolume: \"$subvol\" (Mounted at $submnt)?"
            printf "[y/n]: "
            read snap_conf
            until [ $snap_conf == y ] || [ $snap_conf == n ];do
                echo "Create snapshot config for subvolume: \"$subvol\" (Mounted at $submnt)?"
                printf "[y/n]: "
                read snap_conf
            done
            if [ $snap_conf == y ];then
                echo -e "sudo snapper -c $subvol create-config $submnt\n" >> ~/archix-setup/snapper_conf_gen.sh
            fi
        done
    fi
fi
if ! grep zram <<< $(lsblk);then
    echo "Would you like to use zram? (Compressed RAM; faster than standard swap) Please input the size in GiB of uncompressed data zram should have. Half of RAM is usually good. Put 0 for no zram"
    printf "Size of zram in GiB: "
    read zram
    until [ "$zram" -ge 0 ];do
        echo "Sorry, please try again."
        echo "Would you like to use zram? (Compressed RAM; faster than standard swap) Please input the size in GiB of uncompressed data zram should have. Half of RAM is usually good. Put 0 for no zram"
        printf "Size of zram in GiB: "
        read zram
    done
    if [ "$zram" -gt 0 ];then
        echo -e "Please select the compression algorithm for zram. 1. LZ4, 2. ZSTD.\nLZ4 is faster, but less effective. ZSTD is slower, but more effective at compression"
        printf "1 OR 2: "
        read zramc
        until [ "$zramc" == 1 ] || [ "$zramc" == 2 ];do
            echo "Sorry, please try again."
            echo -e "Please select the compression algorithm for zram. 1. LZ4, 2. ZSTD.\nLZ4 is faster, but less effective. ZSTD is slower, but more effective at compression"
            printf "1 OR 2: "
            read zramc
        done
        if [ "$zramc" == 1 ];then
            zramcomp=lz4;else
            zramcomp=zstd
        fi
    fi
fi

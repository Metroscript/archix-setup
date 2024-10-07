#Start in $HOME to require less user input
cd "$HOME"

if pacman -Q mkinitcpio;then
    img=mkinit
elif pacman -Q dracut;then
    img=dracut;else
    img=booster
fi

if [ "$img" != mkinit ];then
    printf "WARNING: This script doesn't support initramfs generators other than mkinitcpio. Proceed at your own risk.\n"
    sleep 3
    until [ "$imgcont" = y ] || [ "$imgcont" = n ];do
        printf "Continue? [y/n]: "
        read imgcont
    done
    if [ "$imgcont" = n ];then
        printf "EXITING....\n"
        exit 1
    fi
fi

CHASSIS=$(cat /sys/class/dmi/id/chassis_type)
if [ "$CHASSIS" = 9 ] || [ "$CHASSIS" = 10 ];then
    LAPTOP=1
fi

if grep -q Artix /etc/issue;then
    artix=y
    sdir=/etc/elogind/
    sed -i -e 's/action" : "reboot/action" : "loginctl reboot/' -i -e 's/poweroff/loginctl poweroff/' -i -e 's/action" : "suspend/action" : "loginctl suspend/' "$repo"dotfiles/hypr-rice/wlogout/layout
    if pacman -Q openrc;then
        init=openrc
    elif pacman -Q runit;then
        init=runit
    elif pacman -Q s6-base;then
        init=s6;else
        init=dinit
    fi;else
    sdir=/etc/systemd/
fi

bootdir=/etc/default/grub

if pacman -Q opendoas;then
    suas=y
    alias sudo=doas
    sed -i "/stuff/a alias sudo=doas" "$repo"dotfiles/bashrc
    sed -i "/stuff/a alias sudo doas" "$repo"dotfiles/config.fish
fi

if findmnt -t btrfs;then
    btrfs=y
fi

#Add quiet if not present so later sed calls do not break
if ! grep -q quiet "$bootdir";then
    sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="quiet/' "$bootdir"
fi

until [ "$de" = 1 ] || [ "$de" = 2 ];do
    printf "Which DE/WM would you like to install? 1.Hyprland or 2.KDE Plasma\n[1/2]: "
    read de
done
if [ "$de" = 1 ] || [ "$de" = 2 ];then
    dm=sddm
fi

until [ "$dotfs" = y ] || [ "$dotfs" = n ];do
    printf "Use repo dotfiles? (Does not apply to Hyprland Rice) [y/n]: "
    read dotfs
done

until [ "$bin" = y ] || [ "$bin" = n ];do
    printf "Use precompiled binaries where availiable? [y/n]: "
    read bin
done

until [ "$opt" = y ] || [ "$opt" = n ];do
    printf "Enable compile optimisations such as multithreading & native binaries to makepkg.conf? [y/n]: "
    read opt
done

until [ "$mtdi" = y ] || [ "$mtdi" = n ];do
    printf "Install multithreaded drop-ins for gzip & bzip2?\n[y/n]: "
    read mtdi
done

until [ "$terminal" = 1 ] || [ "$terminal" = 2 ] || [ "$terminal" = 3 ];do
    printf "Install 1.Alacritty, 2.Kitty or 3.Wezterm for terminal emulatior?\n[1,2,3]: "
    read terminal
done
if [ "$terminal" = 1 ];then
    terminal=alacritty
elif [ "$terminal" = 2 ];then
    terminal=kitty
    sed -i 's/bind = CONTROL ALT, T, exec, alacritty/bind = CONTROL ALT, T, exec, kitty/' "$repo"dotfiles/hypr-rice/hypr/hyprland.conf
    sed -i 's/alacritty/kitty/g' "$repo"dotfiles/hypr-rice/waybar/config.jsonc
    sed -i "/ffmpeg/a   alias icat='kitty icat'" "$repo"dotfiles/bashrc
    sed -i "/ffmpeg/a   alias icat 'kitty icat'" "$repo"dotfiles/config.fish
else
    terminal=wezterm
    sed -i 's/bind = CONTROL ALT, T, exec, alacritty/bind = CONTROL ALT, T, exec, wezterm/' "$repo"dotfiles/hypr-rice/hypr/hyprland.conf
    sed -i 's/alacritty/wezterm/g' "$repo"dotfiles/hypr-rice/waybar/config.jsonc
    sed -i "/ffmpeg/a   alias icat='wezterm imgcat'" "$repo"dotfiles/bashrc
    sed -i "/ffmpeg/a   alias icat 'wezterm imgcat'" "$repo"dotfiles/config.fish
fi

until [ "$vir" = y ] || [ "$vir" = n ];do
    printf "Install Virtualisation Software? [y/n]: "
    read vir
done
if [ "$vir" = y ];then
    until [ "$virt" = 1 ] || [ "$virt" = 2 ] || [ "$virt" = 3 ];do
        printf "Install 1.Qemu, 2.Virtualbox or 3.Both?\n[1/2/3]: "
        read virt
    done;else
    virt=0
fi
until [ "$games" = y ] || [ "$games" = n ];do
    printf "Install WINE Games support? (Steam, Lutris, HeroicLauncher) [y/n]: "
    read games
done
if [ "$games" = y ];then
    until [ "$rlx" = y ] || [ "$rlx" = n ];do
        printf "Install Vinegar? (A WINE wrapper for Roblox) [y/n]: "
        read rlx
    done
    until [ "$min" = y ] || [ "$min" = n ];do
        printf "Install Prismlauncher? (A custom Minecraft launcher with mod support - Flatpak) [y/n]: "
        read min
    done
    until [ "$emu" = y ] || [ "$emu" = n ];do
        printf "View installable console emulators? (Most are installed through Flatpak) [y/n]: "
        read emu
    done
    if [ "$emu" = y ];then
        until [ "$melonds" = y ] || [ "$melonds" = n ];do
            printf "Install MelonDS? (DS emulator) [y/n]: "
            read melonds
        done
        until [ "$citra" = y ] || [ "$citra" = n ];do
            printf "Install Citra? (3DS emulator [NO LONGER MAINTAINED]) [y/n]: "
            read citra
        done
        until [ "$dolphin" = y ] || [ "$dolphin" = n ];do
            printf "Install Dolphin? (Gamecube/Wii emulator) [y/n]: "
            read dolphin
        done
        until [ "$cemu" = y ] || [ "$cemu" = n ];do
            printf "Install Cemu? (Wii U emulator) [y/n]: "
            read cemu
        done
        until [ "$switch" = y ] || [ "$switch" = n ];do
            printf "Install Ryujinx? (Switch emulator) [y/n]: "
            read switch
        done
        until [ "$duckstation" = y ] || [ "$duckstation" = n ];do
            printf "Install Duckstation? (PS1 emulator) [y/n]: "
            read duckstation
        done
        until [ "$pcsx2" = y ] || [ "$pcsx2" = n ];do
            printf "Install PCSX2? (PS2 emulator) [y/n]: "
            read pcsx2
        done
        until [ "$ppsspp" = y ] || [ "$ppsspp" = n ];do
            printf "Install PPSSPP? (PS Portable emulator) [y/n]: "
            read ppsspp
        done
    fi
fi
until [ "$multitools" = y ] || [ "$multitools" = n ];do
    printf "Install Multimedia tools? (Kdenlive, OBS)\n[y/n]: "
    read multitools
done
until [ "$graphitools" = y ] || [ "$graphitools" = n ];do
    printf "Install Graphics tools? (GIMP, Blender)\n[y/n]: "
    read graphitools
done
until [ "$office" = y ] || [ "$office" = n ];do
    printf "Install LibreOffice?\n[y/n]: "
    read office
done
until [ "$shell" = 1 ] || [ "$shell" = 2 ] || [ "$shell" = 3 ] || [ "$shell" = 4 ];do
    printf "What shell would you like to use? (Use BASH if unsure) 1.BASH 2.FISH 3.ZSH 4.DASH\n[1/2/3/4]: "
    read shell
done
if [ "$shell" = 1 ];then
    shell=bash
elif [ "$shell" = 2 ];then
    shell=fish
elif [ "$shell" = 3 ];then
    shell=zsh;else
    shell=dash
fi
until [ "$cron" = 1 ] || [ "$cron" = 2 ];do
    printf "Use which cron provider? (If unsure, choose Cronie) 1.Cronie or 2.Fcron\n[1/2]: "
    read cron
done
if [ "$cron" = 1 ];then
    cron=cronie;else
    cron=fcron
fi
until [ "$mirrorsort" = y ] || [ "$mirrorsort" = n ];do
    printf "Sort package mirrors to prioritse faster servers? [y/n]: "
    read mirrorsort
done
until [ "$ply" = y ] || [ "$ply" = n ];do
    printf "Install Plymouth? (Adds boot splash screen) [y/n]: "
    read ply
done
if [ "$ply" = y ];then
    until [ "$plytheme" = spinner ] || [ "$plytheme" = bgrt ] || [ "$plytheme" = breeze ] || [ "$plytheme" = breeze-text ] || [ "$plytheme" = fade-in ] || [ "$plytheme" = glow ] || [ "$plytheme" = solar ] ||  [ "$plytheme" = spininfinity ] || [ "$plytheme" = text ] || [ "$plytheme" = tribar ] || [ "$plytheme" = script ] || [ "$plytheme" = details ];do
        printf "Select Plymouth Theme: spinner, bgrt, breeze, breeze-text, fade-in, glow, solar, spininfinity, spinner, text, tribar, script, details.\nType desired theme name: "
        read plytheme
    done
    if [ "$plytheme" = bgrt ];then
        until [ "$vr" = y ] || [ "$vr" = n ];do
            printf "Remove distro watermark to leave only BIOS vender logo? [y/n] "
            read vr
        done
    fi
fi
until [ "$makemkv" = y ] || [ "$makemkv" = n ];do
    printf "Install MakeMKV? (A DVD/Bluray ripper) [y/n]: "
    read makemkv
done
if [ "$img" = mkinit ];then
    until [ "$mkfirm" = y ] || [ "$mkfirm" = n ];do
        printf "Install mkinitcpio-firmware (Removes missing firmware warnings when generating initramfs) [y/n]: "
        read mkfirm
    done
fi

until [ "$lckdwn" = 0 ] || [ "$lckdwn" = 1 ] || [ "$lckdwn" = 2 ];do
    printf "Enable Kernel lockdown to prevent modification of kernel during runtime? (Prevents non-signed kernel modules from loading & disables hibernation)\n0.No (Default) 1.Integrity (Standard Lockdown) 2.Confidential (Changes how RAM is accessed; Can cause issues)\n[0/1/2]: "
    read lckdwn
done

if [ "$lckdwn" -gt 0 ] && [ "$virt" -ge 2 ];then
    until [ "$lckdwn_con" = y ] || [ "$lckdwn_con" = n ];do
        printf "VIRTUALBOX KERNEL MODULES DO NOT APPLY WITH LOCKDOWN. ARE YOU SURE YOU STILL WANT TO ENABLE LOCKDOWN?\n[y/n]: "
        read lckdwn_con
    done
    if [ "$lckdwn_con" = n ];then
        lckdwn=0
    fi
fi

until [ "$apparmr" = y ] || [ "$apparmr" = n ];do
    printf "Install apparmor for app sandboxing / Mandatory Access Control configuration?\n[y/n]: "
    read apparmr
done

if ! swapon -s | grep Size;then
    until [ "$swap" -ge 0 ] >/dev/null 2>&1;do
        printf "Swapfile size in GiB. Swap at least equal to RAM for hibernation. Put '0' for no swapfile.\nSize of swapfile in GiB: "
        read swap
    done
    if [ "$swap" -gt 0 ];then
        if [ "$btrfs" = y ];then
            printf "What would you like your swap subvolume to be called?: "
            read swapvol
            until [ "$swapvolconf" = y ] || [ "$swapvolconf" = n ];do
                printf "Are you sure you want to call your swap subvolume \"%s\"?\n[y/n]: " "$swapvol"
                read swapvolconf
            done
            if [ "$swapvolconf" = n ];then
                until [ "$swapvolconf" = y ];do
                    printf "What would you like your swap subvolume to be called?: "
                    read swapvol
                    unset swapvolconf
                    until [ "$swapvolconf" = y ] || [ "$swapvolconf" = n ];do
                        printf "Are you sure you want to call your swap subvolume \"%s\"?\n[y/n]: " "$swapvol"
                        read swapvolconf
                    done
            done
            fi
        fi
        if [ "$swap" -ge $(($(grep MemTotal /proc/meminfo|cut -d: -f2|cut -dk -f1)/1024/1024)) ] && [ "$lckdwn" = 0 ];then
            until [ "$res" = y ] || [ "$res" = n ];do
                printf "Enable suspend to & resume from disk support? [y/n]: "
                read res
            done
        fi
    fi
fi
if [ "$btrfs" = y ];then
    until [ "$snap" = y ] || [ "$snap" = n ];do
        printf "Install snapper for automated subvolume snapshots?\n[y/n]: "
        read snap
    done
    if [ "$snap" = y ];then
        printf "Additional changes to snapshot configs must be done manually after install\n"
        sleep 3
        until [ "$snapac" = y ] || [ "$snapac" = n ];do
            printf "Install snap-pac for snapshots on each pacman [in/un]install?\n[y/n]: "
            read snapac
        done
        until [ "$grbtrfs" = y ] || [ "$grbtrfs" = n ];do
            printf "Install grub-btrfs to boot from snapshots?\n[y/n]: "
            read grbtrfs 
        done
        if [ "$grbtrfs" = y ] && [ "$snapac" = y ] && [ "$artix" = y ];then
            printf "Installing snap-pac-grub for automated grub snapshot boot entries\n"
        sleep 3
        fi
        if [ -d /.snapshots ];then
            printf "/.snapshots directory detected! Prevents snapper from installing! /.snapshots will be unmounted and removed until snapper recreates the directory & any fstab entries for /.snapshots will be removed!\n"
            sleep 5
            snap_dir=y
        fi
        if [ "$suas" = y ];then
            printf "alias sudo=doas\n" > ~/archix-setup/snapper_conf_gen.sh
        fi
        for submnt in $(findmnt -nt btrfs|cut -d\  -f1|sed 's/─//'|sed 's/├//'|sed 's/└//');do 
            subvol=$(findmnt -nt btrfs|grep "$submnt "|sed 's,.*subvol=/,,')
            unset snap_conf
            until [ "$snap_conf" = y ] || [ "$snap_conf" = n ];do
                printf "Create snapshot config for subvolume: \"%s\" (Mounted at %s)?\n[y/n]: " "$subvol" "$submnt"
                read snap_conf
            done
            if [ "$snap_conf" = y ];then
                printf "sudo snapper -c %s create-config %s\n\n" "$subvol" "$submnt" >> ~/archix-setup/snapper_conf_gen.sh
            fi
        done
    fi
fi
if ! lsblk | grep -q zram;then
    until [ "$zram" -ge 0 ] >/dev/null 2>&1;do
        printf "Would you like to use zram? (Compressed RAM; faster than standard swap) Please input the size in GiB of uncompressed data zram should have. 50% of real RAM is reccommended. Put 0 for no zram\nSize of zram in GiB: "
        read zram
    done
    if [ "$zram" -gt 0 ];then
        until [ "$zramc" = 1 ] || [ "$zramc" = 2 ];do
            printf "Please select the compression algorithm for zram. 1. LZ4, 2. ZSTD.\nLZ4 is faster, but less effective. ZSTD is slower, but more effective at compression\n1 OR 2: "
            read zramc
        done
        if [ "$zramc" = 1 ];then
            zramcomp=lz4;else
            zramcomp=zstd
        fi
    fi
fi

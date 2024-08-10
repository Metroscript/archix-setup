#Plymouth check & conf
if [ $ply == y ];then
    if [ $img == mkinit ];then
        sudo sed -i 's/udev/udev plymouth/g' /etc/mkinitcpio.conf
    fi
    if ! grep splash <<< $(cat $bootdir);then
        sudo sed -i 's/quiet/quiet splash/' $bootdir
    fi
    sudo sed -i 's/quiet/plymouth.nolog quiet/' $bootdir
    if ! [ $plytheme == bgrt ];then
        sudo sed -i -e 's/DialogVerticalAlignment=.382/DialogVerticalAlignment=.75/' -i -e 's/WatermarkVerticalAlignment=.96/WatermarkVerticalAlignment=.5/' /usr/share/plymouth/themes/spinner/spinner.plymouth
    fi
    if [ "$vr" == y ];then
        sudo mv /usr/share/plymouth/themes/spinner/watermark.png /usr/share/plymouth
    fi
    if [ $img == mkinit ];then
        if [ "$plytheme" == breeze ] || [ "$plytheme" == breeze-text ];then
            sudo pacman -Syu --needed --noconfirm breeze-plymouth
        fi
        sudo plymouth-set-default-theme $plytheme
    fi
fi

if [ $de == 1 ];then
    xdg-user-dirs-update
    mv ${repo}dotfiles/hypr-rice/* .config/
    curl -L https://raw.githubusercontent.com/KDE/plasma-workspace/master/menu/desktop/plasma-applications.menu -o $HOME/.config/menus/applications.menu
    bmpath=file:///home/$USER/
    echo -e '${bmpath}Documents Documents\n${bmpath}Music Music\n${bmpath}Pictures Pictures\n${bmpath}Videos Videos\n${bmpath}Downloads Downloads' > .config/gtk-3.0/bookmarks
    mv ${repo}dotfiles/thumbnailers .local/share/
    mv ${repo}dotfiles/set-as-background.nemo_action .local/share/nemo/actions
    cd .local/share/applications/
    echo -e '[Desktop Entry]\nName=Rofi-Calc\nExec=rofi -show calc -modi calc -no-show-match -no-sort -theme ~/.config/rofi/themes/arthur-dark.rasi\nTerminal=false\nX-MultipleArgs=false\nType=Application\nIcon=/usr/share/icons/breeze-dark/apps/48/kcalc.svg' > rofi-calc.desktop
    echo -e '[Desktop Entry]\nName=PowerMenu\nExec=wlogout\nTerminal=false\nX-MultipleArgs=false\nType=Application\nIcon=~/.config/wlogout/power.png' > powermenu.desktop
    chmod +x rofi-calc.desktop powermenu.desktop
    cd
    gsettings set org.cinnamon.desktop.privacy remember-recent-files false
    gsettings set org.cinnamon.desktop.default-applications.terminal exec $terminal
    #Prevent dbus errors with flatpaks
    sudo sed -i 's/Exec=Hyprland/Exec=dbus-run-session Hyprland/' /usr/share/wayland-sessions/hyprland.desktop
    hyprpm update
    hyprpm add https://github.com/hyprwm/hyprland-plugins
    if [ $games == y ];then
        hyprpm enable csgo-vulkan-fix
    fi
fi
if ! grep "autostart" <<< $(ls .config/);then
    mkdir $HOME/.config/autostart
fi
if [ "$artix" == y ] && ! [ $de == 1 ];then
    printf "[Desktop Entry]\nExec=/usr/bin/pkill -u \"\$USER\" -x pipewire\|wireplumber ; /usr/bin/pidwait -u \"\$USER\" -x pipewire\|wireplumber ; /usr/bin/pipewire & /usr/bin/pipewire-pulse & /usr/bin/sleep 1 ; /usr/bin/wireplumber &\nName=Pipewire\nType=Application\nX-KDE-AutostartScript=true" > ~/.config/autostart/pipewire.desktop
    #Not .config/autostart to fix OBS pipewire capture errors
    #mkdir -p ~/.config/plasma-workspace/env/
    #echo -e "#!/bin/sh\n/usr/bin/pkill -u \"\$USER\" -x pipewire\|wireplumber\n/usr/bin/pidwait -u \"\$USER\" -x pipewire\|wireplumber\n/usr/bin/pipewire &\n/usr/bin/pipewire-pulse &\n/usr/bin/sleep 1\n/usr/bin/wireplumber &" > ~/.config/plasma-workspace/env/pipewire.sh
fi
if [ $apparmr == y ];then
    printf "[Desktop Entry]\nType=Application\nName=Apparmor Notify\nComment=Notify User of Apparmor Denials\nTryExec=aa-notify\nExec=aa-notify -p -s 1 -w 60 -f /var/log/audit/audit.log\nStartupNotify=false\nNoDisplay=true" > $HOME/.config/autostart/apparmor-notify.desktop
fi
if [ $dm == sddm ];then
    if [ $de == 2 ];then
    printf "[Theme]\nCurrent=breeze\n" | sudo tee /etc/sddm.conf;else
    printf "[Theme]\nCurrent=archlinux-simplyblack\n" | sudo tee /etc/sddm.conf
    fi
fi

#Sysctl rules
if ! grep "sysctl.d" <<< $(ls /etc/);then
    sudo mkdir /etc/sysctl.d/
fi
printf "#Hide kernel pointers\nkernel.kptr_restrict=2\n\n#Restrict access to kernel log\nkernel.dmesg_restrict=1\n\n#Restrict kernel log output during boot\nkernel.printk=3 3 3 3\n\n#Restrict BPF & enable JIT hardening\nkernel.unprivileged_bpf_disabled=1\nnet.core.bpf_jit_harden=2\n\n#Restrict loading of TTY line disciplines\ndev.tty.ldisc_autoload=0\n\n#Mitigate use-after-free flaws\nvm.unprivileged_userfaultfd=0\n\n#Prevent loading of another kernel during runtime\nkernel.kexec_load_disabled=1\n\n#Restrict SysRq access to only through use of the secure attention key (Set to '0' to disable SysRq)\nkernel.sysrq=4\n\n#Restrict use of kernel performance events\nkernel.perf_event_paranoid=3" | sudo tee /etc/sysctl.d/99-kernel-security.conf
printf "#Protect against SYN flood attacks\nnet.ipv4.tcp_syncookies=1\n\n#Drop RST packets in time-wait state\nnet.ipv4.tcp_rfc1337=1\n\n#IP source validation\nnet.ipv4.conf.all.rp_filter=1\nnet.ipv4.conf.default.rp_filter=1\n\n#Disable TCP timestamps\nnet.ipv4.tcp_timestamps=0\n\n#Prevent source routing\nnet.ipv4.conf.all.accept_source_route=0\nnet.ipv4.conf.default.accept_source_route=0\nnet.ipv6.conf.all.accept_source_route=0\nnet.ipv6.conf.default.accept_source_route=0\n\n#IPv6 privacy extentions\nnet.ipv6.conf.all.use_tempaddr = 2\nnet.ipv6.conf.default.use_tempaddr = 2" | sudo tee /etc/sysctl.d/99-network.conf
printf "#Increase ASLR bit entropy\nvm.mmap_rnd_bits=32\nvm.mmap_rnd_compat_bits=16\n\n#Allow sym/hardlinks to be created only when destination is not world-writable or shares the same owner of the source\nfs.protected_symlinks=1\nfs.protected_hardlinks=1\n\n#Prevents access to files in world-writable directories by those who are not the owner\nfs.protected_fifos=2\nfs.protected_regular=2" | sudo tee /etc/sysctl.d/99-userspace.conf
printf "#Improve compatability by increasing memory map count\nvm.max_map_count=2147483642\nvm.swappiness=50" | sudo tee /etc/sysctl.d/99-ram.conf
if [ "$zram" -gt 0 ];then
    sudo sed -i '/vm.swappiness/d' /etc/sysctl.d/99-ram.conf
    printf "\n\n#Optimise zram performance\nvm.watermark_boost_factor = 0\nvm.watermark_scale_factor = 125\nvm.page-cluster = 0" | sudo tee -a /etc/sysctl.d/99-ram.conf
    if [ "$zramcomp" == lz4 ];then
        sudo sed -i 's/vm.page-cluster = 0/vm.page-cluster = 1' /etc/sysctl.d/99-ram.conf
    fi
fi
if [ $apparmr == y ];then
    sudo sed -i 's/quiet/lsm=landlock,lockdown,yama,integrity,apparmor,bpf audit=1 slab_nomerge init_on_alloc=1 init_on_free=1 page_alloc.shuffle=1 pti=on randomize_kstack_offset=on vsyscall=none debugfs=off random.trust_cpu=off quiet/' $bootdir
    #Apparmor audit settings
    sudo sed -i 's/#write-cache/write-cache/' /etc/apparmor/parser.conf
    sudo groupadd -r audit
    sudo gpasswd -a $USER audit
    sudo sed -i '/log_group/a log_group = audit' /etc/audit/auditd.conf;else
    sudo sed -i 's/quiet/slab_nomerge init_on_alloc=1 init_on_free=1 page_alloc.shuffle=1 pti=on randomize_kstack_offset=on vsyscall=none debugfs=off random.trust_cpu=off quiet/' $bootdir
fi
if ! grep loglevel <<< $(cat $bootdir);then
    sudo sed -i 's/quiet/loglevel=0 quiet/' $bootdir;else
    sudo sed -i 's/loglevel=./loglevel=0/' $bootdir
fi
if ! grep nowatchdog <<< $(cat $bootdir);then
    sudo sed -i 's/quiet/nowatchdog quiet/' $bootdir
fi
if [ $lckdwn -gt 0 ];then
    if [ $lckdwn == 1 ];then
        sudo sed -i 's/slab_nomerge/lockdown=integrity slab_nomerge/' $bootdir
    else
        sudo sed -i 's/slab_nomerge/lockdown=confidentiality slab_nomerge/' $bootdir
    fi
fi
sudo grub-mkconfig -o /boot/grub/grub.cfg
#Enable NetworkManager ipv6 privacy features
if grep -q networkmanager <<< $(pacman -Q) && ! grep 'ipv6.ip6-privacy=2' <<< $(cat /etc/NetworkManager/conf.d/*);then
    printf "[connection]\nipv6.ip6-privacy=2" | sudo tee /etc/NetworkManager/conf.d/ipv6-privacy-features.conf
fi
#set machine ID to generic whonix machine ID
if ! grep -q b08dfa6083e7567a1921a715000001fb <<< $(cat /etc/machine-id);then
    printf "b08dfa6083e7567a1921a715000001fb" | sudo tee /etc/machine-id
fi
#Add 5 second delay between failed password attempts
if ! grep -q pam_faildelay <<< $(cat /etc/pam.d/system-login);then
    printf "auth       optional   pam_faildelay.so   delay=5000000\n" | sudo tee -a /etc/pam.d/system-login
fi
#Restrict 'su' to :wheel
sudo sed -i 's/#auth           required        pam_wheel.so use_uid/auth            required        pam_wheel.so use_uid/' /etc/pam.d/su /etc/pam.d/su-l

if [ "$dotfs" == y ];then
    mv ${repo}dotfiles/config/* .config/
    if [ $terminal == alacritty ];then
        mv ${repo}dotfiles/alacritty .config/
    elif [ $terminal == kitty ];then
        mv ${repo}dotfiles/kitty .config/
    else
        mv ${repo}dotfiles/wezterm .config/
    fi
    #Install Thumbfast
    mkdir .config/mpv/scripts/
    cd .config/mpv/scripts/
    #Standard OSC
    wget 'https://raw.githubusercontent.com/po5/thumbfast/5fefc9b8e995cf5e663666aa10649af799e60186/player/lua/osc.lua'
    wget 'https://raw.githubusercontent.com/po5/thumbfast/master/thumbfast.lua'
    cd
    if [ $games == y ] && ! grep Games <<< $(ls);then
        mkdir Games
        sudo setcap 'CAP_SYS_NICE=eip' $(which gamescope)
    fi
    if [ "$rlx" == y ];then
        mkdir -p .var/app/org.vinegarhq.Vinegar/config/
        mv ${repo}dotfiles/vinegar .var/app/org.vinegarhq.Vinegar/config
    fi
    mv ${repo}dotfiles/bashrc .bashrc
    mv ${repo}dotfiles/inputrc .inputrc
fi
#Set Shell
if ! [ $shell == bash ];then
    chsh -s /bin/$shell
    if [ $shell == fish ];then
        fish -c 'set -U fish_greeting'
        if [ "$dotfs" == y ];then
            cp ${repo}dotfiles/config.fish ~/.config/fish/
        fi
    fi
fi
if [ "$virt" == 1 ] || [ "$virt" == 3 ];then
    sudo sed -i -e 's/#unix_sock_group = "libvirt"/unix_sock_group = "libvirt"/' -i -e 's/#unix_sock_ro_perms = "0777"/unix_sock_ro_perms = "0777"/' -i -e 's/#unix_sock_rw_perms = "0770"/unix_sock_rw_perms = "0770"/' /etc/libvirt/libvirtd.conf
    sudo sed -i 's/#group.*/group = "libvirt"/' /etc/libvirt/qemu.conf
    sudo sed -i 's/#firewall_backend = "nftables"/firewall_backend = "iptables"/' /etc/libvirt/network.conf
    sudo gpasswd -a $USER libvirt
fi
if ! grep localtime <<< $(ls /etc/);then
    sudo ln -sf /usr/share/zoneinfo/$tz /etc/localtime
    sudo hwclock --systohc
fi

#Configure NTP Servers
sudo sed -i '/cloudflare/d' /etc/ntpd.conf
sudo sed -i 's/servers 2.arch.pool.ntp.org/servers 0.arch.pool.ntp.org/' /etc/ntpd.conf
sudo sed -i -z 's/servers 0.arch.pool.ntp.org/servers 0.arch.pool.ntp.org\nservers 1.arch.pool.ntp.org\nservers 2.arch.pool.ntp.org\nservers 3.arch.pool.ntp.org/' /etc/ntpd.conf

# Configure earlyoom
if ! [ "$artix" == y ];then
    sudo sed -i s,EARLYOOM_ARGS=".*",EARLYOOM_ARGS="-n -m 5 -s 5 -r 60 --ignore-root-user --avoid '(^|/)(init|Xorg|Xwayland|systemd)'", /etc/default/earlyoom
elif [ "$init" == dinit ];then
    sudo sed -i s,EARLYOOM_ARGS=".*",EARLYOOM_ARGS="-n -m 5 -s 5 -r 60 --ignore-root-user --avoid '(^|/)(init|Xorg|Xwayland|dinit)'", /etc/dinit.d/config/earlyoom.conf
else
    sudo sed -i s,EARLYOOM_ARGS=".*",EARLYOOM_ARGS="-n -m 5 -s 5 -r 60 --ignore-root-user --avoid '(^|/)(init|Xorg|Xwayland|$init)'", /etc/default/earlyoom
fi

#Enable Firewall settings
sudo ufw enable
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow http
sudo ufw allow https
sudo ufw allow dns
sudo ufw allow mdns
sudo ufw allow 631
sudo ufw allow qbittorrent

# Install snap-pac (done late to reduce snapshot count)
if [ "$snapac" == y ];then
    export SNAP_PAC_SKIP=y
    sudo pacman -S --noconfirm --needed snap-pac
    if [ "$grbtrfs" == y ] && ! [ "$init" == dinit ];then
        paru -S snap-pac-grub
    fi
fi

# Regenerate the initramfs in case it has been updated
if [ $img == mkinit ];then
    sudo mkinitcpio -P
fi

# ClamAV setup
sudo touch /var/log/clamav/freshclam.log

#Enable init services
if [ "$apparmr" == y ];then
    APPARMOR=" apparmor auditd"
fi
if [ "$virt" == 1 ] || [ "$virt" == 3 ];then
    QEMU=" libvirtd virtlogd"
fi
if [ "$LAPTOP" == 1 ];then
    TLP=" tlp"
fi

SERVICES="ufw $dm $cron earlyoom$APPARMOR$QEMU$TLP"
if [ "$suas" == y ];then
        ESCALATE=doas;else
        ESCALATE=sudo
fi
if [ "$artix" != y ];then
    SERVICES="openntpd cups clamav-freshclam$SERVICES"
    sudo systemctl disable systemd-timesyncd
    sudo systemctl enable $SERVICES
else
    SERVICES="ntpd cupsd freshclam$SERVICES"
    for SERVICE in $SERVICES;do
        if [ $init == dinit ];then
            INITSTART="$ESCALATE ln -s /etc/dinit.d/$SERVICE /etc/dinit.d/boot.d/"
        elif [ $init == runit ];then
            INITSTART="$ESCALATE ln -s /etc/runit/sv/$SERVICE /run/runit/service/"
        elif [ $init == openrc ];then
            INITSTART="$ESCALATE rc-update add $SERVICE default"
        elif [ $init == s6 ];then
            INITSTART="$ESCALATE touch /etc/s6/adminsv/default/contents.d/$SERVICE"
        fi
        $INITSTART
    done
fi

if [ "$grbtrfs" == y ];then
    if [ "$init" == dinit ];then
        printf "type            = process\nenv-file        = /etc/default/grub-btrfs/config\ncommand         = /usr/bin/grub-btrfsd --syslog /.snapshots\nsmooth-recovery = true" | sudo tee /etc/dinit.d/grub-btrfsd
        sudo dinitctl enable grub-btrfsd
    fi
    sudo systemctl enable grub-btrfsd
fi

if [ "$init" == s6 ];then
    sudo s6-db-reload
fi

if [ "$virt" == 1 ] || [ "$virt" == 3 ];then
    if [ "$artix" != y ];then
        sudo systemctl start libvirtd.service virtlogd.socket
    else
        if [ $init == dinit ];then
            sudo dinitctl start libvirtd
            sudo dinitctl start virtlogd
        elif [ $init == runit ];then
            sudo sv up libvirtd
            sudo sv up virtlogd
        elif [ $init == openrc ];then
            sudo rc-service libvirtd start
            sudo rc-service virtlogd start
        elif [ $init == s6 ];then
            sudo s6-rc -u change libvirtd
            sudo s6-rc -u change virtlogd
        fi
    fi
    sudo virsh net-autostart default
fi
#if ! [ "$artix" == y ];then
#    sudo systemctl disable systemd-timesyncd
#    sudo systemctl enable openntpd cups ufw $dm $cron earlyoom freshclam
#    if [ $apparmr == y ];then
#        sudo systemctl enable apparmor auditd
#    fi
#    if [ "$LAPTOP" == 1 ];then
#        sudo systemctl enable tlp
#    fi
#    if [ "$virt" == 1 ] || [ "$virt" == 3 ];then
#        sudo systemctl enable --now libvirtd.service virtlogd.socket
#        sudo virsh net-autostart default
#    fi
#    if [ "$grbtrfs" == y ];then
#        sudo systemctl enable grub-btrfsd
#    fi
#elif [ $init == dinit ]; then
#    sudo dinitctl enable ntpd
#    sudo dinitctl enable ufw
#    sudo dinitctl enable cupsd
##    sudo dinitctl enable $cron
#    if [ "$virt" == 1 ] || [ "$virt" == 3 ];then
#        sudo dinitctl enable libvirtd
#        sudo dinitctl enable virtlogd
#        sudo virsh net-autostart default
#    fi
#    sudo dinitctl enable apparmor
#    if [ $apparmr == y ];then
#        sudo dinitctl enable auditd
#    fi
#    sudo dinitctl enable
#    sudo dinitctl enable earlyoom
#    sudo dinitctl enable power-profiles-daemon
#    sudo dinitctl enable freshclam
#    if [ "$grbtrfs" == y ];then
#        sudo dinitctl enable grub-btrfsd
#    fi
#    sudo ln -s /etc/dinit.d/$dm /etc/dinit.d/boot.d/
#elif [ $init == runit ]; then
#    sudo ln -s /etc/runit/sv/ntpd /run/runit/service
#    sudo ln -s /etc/runit/sv/cupsd /run/runit/service
#    sudo ln -s /etc/runit/sv/$dm /run/runit/service
#    sudo ln -s /etc/runit/sv/$cron /run/runit/service
#    sudo ln -s /etc/runit/sv/apparmor /run/runit/service
#    if [ $apparmr == y ];then
#       sudo ln -s /etc/runit/sv/auditd /run/runit/service
#    fi
#    sudo ln -s /etc/runit/sv/ufw /run/runit/service
#    sudo ln -s /etc/runit/sv/rngd /run/runit/service
#    sudo ln -s /etc/runit/sv/power-profiles-daemon /run/runit/service
#    sudo ln -s /etc/runit/sv/earlyoom /run/runit/service
#    sudo ln -s /etc/runit/sv/freshclam /run/runit/service
#    if [ "$virt" == 1 ] || [ "$virt" == 3 ];then
#        sudo ln -s /etc/runit/sv/libvirtd /run/runit/service
#        sudo ln -s /etc/runit/sv/virtlogd /run/runit/service
#        sudo virsh net-autostart default
#    fi
#elif [ $init == openrc ]; then
#    sudo rc-update add ntpd boot
#    sudo rc-update add cupsd boot
#    sudo rc-update add $dm boot
#    sudo rc-update add rngd default
#    sudo rc-update add ufw default
#    sudo rc-update add power-profiles-daemon default
#    sudo rc-update add apparmor default
#    if [ $apparmr == y ];then
#        sudo rc-update add auditd default
#    fi
#    sudo rc-update add $cron default
#    sudo rc-update add earlyoom default
#    sudo rc-update add freshclam default
#    if [ "$virt" == 1 ] || [ "$virt" == 3 ];then
#        sudo rc-update add libvirtd default
#        sudo rc-update add virtlogd default
#        sudo virsh net-autostart default
#    fi
#elif [ $init == s6 ];then
#    sudo touch /etc/s6/adminsv/default/contents.d/ntpd
#    sudo touch /etc/s6/adminsv/default/contents.d/ufw
#    sudo touch /etc/s6/adminsv/default/contents.d/$dm
#    sudo touch /etc/s6/adminsv/default/contents.d/rngd
#    sudo touch /etc/s6/adminsv/default/contents.d/cupsd
#    sudo touch /etc/s6/adminsv/default/contents.d/$cron
#    sudo touch /etc/s6/adminsv/default/contents.d/apparmor
#    if [ $apparmr == y ];then
#        sudo touch /etc/s6/adminsv/default/contents.d/auditd
#    fi
#    sudo touch /etc/s6/adminsv/default/contents.d/power-profiles-daemon
#    sudo touch /etc/s6/adminsv/default/contents.d/earlyoom
#    sudo touch /etc/s6/adminsv/default/contents.d/freshclam
#    if [ "$virt" == 1 ] || [ "$virt" == 3 ];then
#        sudo touch /etc/s6/adminsv/default/contents.d/libvirtd
#        sudo touch /etc/s6/adminsv/default/contents.d/virtlogd
#        sudo virsh net-autostart default
#    fi
#    sudo s6-db-reload
#fi

rm -rf ${repo}
if [ $bin == y ];then
    rm -rf paru-bin/;else
    rm -rf paru/
fi
if [ "$artix" == y ];then
    loginctl reboot;else
    reboot
fi

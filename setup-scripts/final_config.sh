#Plymouth check & conf
if [ $ply == y ];then
    if [ $img == mkinit ];then
        sudo sed -i 's/udev/udev plymouth/g' /etc/mkinitcpio.conf
    fi
    if ! rg splash <<< $(cat $bootdir);then
        sudo sed -i 's/quiet/quiet splash/' $bootdir
    fi
    sudo sed -i 's/splash/splash plymouth.nolog/' $bootdir
    sudo sed -i -e 's/DialogVerticalAlignment=.382/DialogVerticalAlignment=.75/' -i -e 's/WatermarkVerticalAlignment=.96/WatermarkVerticalAlignment=.5/' /usr/share/plymouth/themes/spinner/spinner.plymouth
    if [ $img == mkinit ];then
        if [ $de == 2 ];then
            sudo plymouth-set-default-theme -R breeze;else
            sudo plymouth-set-default-theme -R spinner
        fi
        ###########################################
        ###### OTHER INITRAMFS GEN SUPPORT ########
        ###########################################;else
        #if [ $de == 2 ];then
        #    sudo sed -i 's/Theme=.*/Theme=breeze/' /etc/plymouth/plymouthd.conf;else
        #    sudo sed -i 's/Theme=.*/Theme=spinner/' /etc/plymouth/plymouthd.conf
        #fi
        #if [ $img == dracut ];then
        #    sudo dracut-rebuild #;else
        #    #sudo booster build
        #fi
    fi
fi

#Final Configuration
usr=$(whoami)
if [ $de == 1 ];then
    if ! rg Desktop <<< $(ls);then
        mkdir Desktop
    fi
    if ! rg Documents <<< $(ls);then
        mkdir Documents
    fi
    if ! rg Music <<< $(ls);then
        mkdir Music
    fi
    if ! rg Pictures <<< $(ls);then
        mkdir Pictures
    fi
    if ! rg Videos <<< $(ls);then
        mkdir Videos
    fi
    if ! rg Downloads <<< $(ls);then
        mkdir Downloads
    fi
    mv ${repo}dotfiles/hypr-rice/* .config/
    bmpath=file:///home/$usr/
    echo -e '${bmpath}Documents Documents\n${bmpath}Music Music\n${bmpath}Pictures Pictures\n${bmpath}Videos Videos\n${bmpath}Downloads Downloads' > .config/gtk-3.0/bookmarks
    mv ${repo}dotfiles/thumbnailers .local/share/
    mv ${repo}dotfiles/set-as-background.nemo_action .local/share/nemo/actions
    cd .local/share/applications/
    echo -e '[Desktop Entry]\nName=Rofi-Calc\nExec=rofi -show calc -modi calc -no-show-match -no-sort -theme ~/.config/rofi/themes/arthur-dark.rasi\nTerminal=false\nX-MultipleArgs=false\nType=Application\nIcon=/usr/share/icons/breeze-dark/apps/48/kcalc.svg' > rofi-calc.desktop
    echo -e '[Desktop Entry]\nName=PowerMenu\nExec=wlogout\nTerminal=false\nX-MultipleArgs=false\nType=Application\nIcon=~/.config/wlogout/power.png' > powermenu.desktop
    chmod +x rofi-calc.desktop powermenu.desktop
    cd
    gsettings set org.cinnamon.desktop.privacy remember-recent-files false
    gsettings set org.cinnamon.desktop.default-applications.terminal exec alacritty
fi
if [ "$artix" == y ] && ! [ $de == 1 ];then
    if ! rg "autostart" <<< $(ls .config/);then
        mkdir .config/autostart
    fi
    echo -e "[Desktop Entry]\nExec=/usr/bin/pipewire & /usr/bin/pipewire-pulse & /usr/bin/wireplumber\nName=pipewire\nPath=\nType=Application\nX-KDE-AutostartScript=true" > .config/autostart/pipewire.desktop
    echo -e "[Desktop Entry]\nType=Application\nName=Apparmor Notify\nComment=Notify User of Apparmor Denials\nTryExec=aa-notify\nExec=aa-notify -p -s 1 -w 60 -f /var/log/audit/audit.log\nStartupNotify=false\nNoDisplay=true" > .config/autostart/apparmor-notify.desktop
fi
if [ $dm == sddm ];then
    if [ $de == 2 ];then
    sudo sh -c "echo -e '[Theme]\nCurrent=breeze' > /etc/sddm.conf";else
    sudo sh -c "echo -e '[Theme]\nCurrent=archlinux-simplyblack' > /etc/sddm.conf"
    fi
fi
########################################
############# HARDENING ################
########################################
if ! rg "sysctl.d" <<< $(ls /etc/);then
    sudo mkdir /etc/sysctl.d/
fi
sudo sh -c "echo -e 'kernel.kptr_restrict=2\nkernel.dmesg_restrict=1\nkernel.printk=3 3 3 3\nkernel.yama.ptrace_scope=2\nkernel.unpriviledged_bpf_disabled=1\nnet.core.bpf_jit_harden=2\ndev.tty.ldisc_autoload=0\nvm.unprivileged_userfaultfd=0\nkernel.kexec_load_disabled=1\nkernel.sysrq=4\nkernel.perf_event_paranoid=3\nvm.mmap_rnd_bits=32\nvm.mmap_rnd_compat_bits=16' > /etc/sysctl.d/99-kernel-hardening.conf"
sudo sh -c "echo -e 'net.ipv4.tcp_syncookies=1\nnet.ipv4.tcp_rfc1337=1\nnet.ipv4.conf.all.rp_filter=1\nnet.ipv4.conf.default.rp_filter=1\nnet.ipv4.tcp_timestamps=0' > /etc/sysctl.d/99-network-security.conf"
sudo sh -c "echo -e 'net.ipv6.conf.all.use_tempaddr = 2\nnet.ipv6.conf.default.use_tempaddr = 2' > /etc/sysctl.d/99-ipv6-privacy.conf"
sudo sh -c "echo -e 'fs.protected_symlinks=1\nfs.protected_hardlinks=1\nfs.protected_fios=2\nfs.protected_regular=2' > /etc/sysctl.d/99-userspace.conf"
sudo sh -c "echo -e 'vm.max_map_count=2147483642\nvm.swappiness=50' > /etc/sysctl.d/99-map-count-swappiness.conf"
sudo sed -i "s/quiet/lsm=landlock,lockdown,yama,integrity,apparmor,bpf audit=1 slab_nomerge init_on_alloc=1 init_on_free=1 page_alloc.shuffle=1 pti=on randomize_kstack_offset=on vsyscall=none debugfs=off quiet/" $bootdir
if ! rg loglevel <<< $(cat $bootdir);then
    sudo sed -i 's/quiet/loglevel=0 quiet/' $bootdir;else
    sudo sed -i 's/loglevel=./loglevel=0/' $bootdir
fi
sudo grub-mkconfig -o /boot/grub/grub.cfg
#Enable NetworkManager ipv6 privacy features
if rg networkmanager <<< $(pacman -Q) && ! rg 'ipv6.ip6-privacy=2' <<< $(cat /etc/NetworkManager/conf.d/*);then
    sudo sh -c "echo -e '[connection]\nipv6.ip6-privacy=2' > /etc/NetworkManager/conf.d/99-ipv6-privacy.conf"
fi
#set machine ID to generic whonix machine ID
if ! rg b08dfa6083e7567a1921a715000001fb <<< $(cat /etc/machine-id);then
    sudo sh -c "echo b08dfa6083e7567a1921a715000001fb > /etc/machine-id ; echo b08dfa6083e7567a1921a715000001fb /var/lib/dbus/machine-id"
fi
#Add 5 second delay between failed password attempts
if ! rg pam_faildelay <<< $(cat /etc/pam.d/system-login);then
    sudo sh -c "echo 'auth       optional   pam_faildelay.so   delay=5000000' >> /etc/pam.d/system-login"
fi
#Restrict 'su' to :wheel
sudo sed -i 's/#auth           required        pam_wheel.so use_uid/auth            required        pam_wheel.so use_uid/' /etc/pam.d/su /etc/pam.d/su-l
#Prevent ssh gaining root
sudo sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
#Apparmor audit settings
sudo sed -i 's/#write-cache/write-cache/' /etc/apparmor/parser.conf
sudo groupadd -r audit
sudo gpasswd -a $usr audit
sudo sed -i '/log_group/a log_group = audit/' /etc/audit/auditd.conf 

if [ $kignore == y ];then
    sudo sed -i 's/#IgnorePkg   =/IgnorePkg   =linux-firmware/' /etc/pacman.conf
######################################################################################################
############################### NEEDS WORKING ON!!! (bashrc editing) #################################
######################################################################################################
    if rg 'local/linux ' <<< $(pacman -Qs);then
        sudo sed -i 's/IgnorePkg   =/IgnorePkg   =linux linux-headers /' /etc/pacman.conf
    fi
    if rg linux-lts <<< $(pacman -Q);then
        sudo sed -i 's/IgnorePkg   =/IgnorePkg   =linux-lts linux-lts-headers /' /etc/pacman.conf
    fi
    if rg linux-zen <<< $(pacman -Q);then
        sudo sed -i 's/IgnorePkg   =/IgnorePkg   =linux-zen linux-zen-headers /' /etc/pacman.conf
    fi
    if rg linux-hardened <<< $(pacman -Q);then
        sudo sed -i 's/IgnorePkg   =/IgnorePkg   =linux-hardened linux-hardened-headers /' /etc/pacman.conf
    fi
fi
######################################################################################################
######################################## END OF PROBLEM AREA #########################################
######################################################################################################
if ! rg .config <<< $(sudo ls -a /root/);then
    sudo mkdir /root/.config/
fi
sudo cp -r ${repo}dotfiles/config/nvim /root/.config/
sudo mv ${repo}dotfiles/root/* /root/.config/
mv ${repo}dotfiles/config/* .config/
if [ $gayms == y ];then
    if ! rg Games <<< $(ls);then
        mkdir Games
    fi
    if ! rg "retroarch" <<< $(ls .config);then
        mkdir .config/retroarch
    fi
    mv ${repo}dotfiles/retroarch.cfg .config/retroarch
fi
mv ${repo}dotfiles/bashrc .bashrc
mv ${repo}dotfiles/inputrc .inputrc
sudo sed -i -e 's/#unix_sock_group = "libvirt"/unix_sock_group = "libvirt"/' -i -e 's/#unix_sock_ro_perms = "0777"/unix_sock_ro_perms = "0777"/' -i -e 's/#unix_sock_rw_perms = "0770"/unix_sock_rw_perms = "0770"/' /etc/libvirt/libvirtd.conf
sudo usermod -aG libvirt $usr
if ! rg localtime <<< $(ls /etc/);then
    sudo ln -sf /usr/share/zoneinfo/$tz /etc/localtime
    sudo hwclock --systohc
fi
#Enable Firewall settings
sudo ufw limit 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 631/tcp
sudo ufw allow 53/tcp
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable

#Enable init services
if ! [ "$artix" == y ];then
    sudo systemctl enable --now systemd-timesyncd cups ufw $dm cronie libvirtd apparmor auditd pkgfile-update.timer
elif [ $init == dinit ]; then
    sudo dinitctl enable ntpd
    sudo dinitctl enable ufw
    sudo dinitctl enable cupsd
    sudo dinitctl enable cronie
    sudo dinitctl enable libvirtd
    sudo dinitctl enable apparmor
    sudo dinitctl enable auditd
    sudo ln -s /etc/dinit.d/$dm /etc/dinit.d/boot.d/
elif [ $init == runit ]; then
    sudo ln -s /etc/runit/sv/ntpd /run/runit/service
    sudo ln -s /etc/runit/sv/cupsd /run/runit/service
    sudo ln -s /etc/runit/sv/$dm /run/runit/service
    sudo ln -s /etc/runit/sv/cronie /run/runit/service
    sudo ln -s /etc/runit/sv/apparmor /run/runit/service
    sudo ln -s /etc/runit/sv/auditd /run/runit/service
    sudo ln -s /etc/runit/sv/ufw /run/runit/service
elif [ $init == openrc ]; then
    sudo rc-update add ntpd boot
    sudo rc-update add cupsd boot
    sudo rc-update add $dm boot
    sudo rc-update add ufw default
    sudo rc-update add apparmor default
    sudo rc-update add auditd default
    sudo rc-update add cronie default
    sudo rc-update add libvirtd default
elif [ $init == s6 ];then
    sudo touch /etc/s6/adminsv/default/contents.d/ntpd
    sudo touch /etc/s6/adminsv/default/contents.d/ufw
    sudo touch /etc/s6/adminsv/default/contents.d/$dm
    sudo touch /etc/s6/adminsv/default/contents.d/cupsd
    sudo touch /etc/s6/adminsv/default/contents.d/cronie
    sudo touch /etc/s6/adminsv/default/contents.d/apparmor
    sudo touch /etc/s6/adminsv/default/contents.d/auditd
    sudo s6-db-reload
fi

rm -rf ${repo}
if [ $bin == y ];then
    rm -rf paru-bin/;else
    rm -rf paru/
fi
if [ "$artix" == y ];then
    loginctl reboot;else
    reboot
fi

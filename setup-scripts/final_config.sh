#Plymouth check & conf
if rg plymouth <<< $(pacman -Q);then
    sudo sed -i 's/udev/udev plymouth/g' /etc/mkinitcpio.conf
    sudo sed -i 's/splash/splash plymouth.nolog/' $bootdir
    sudo sed -i -e 's/DialogVerticalAlignment=.382/DialogVerticalAlignment=.75/' -i -e 's/WatermarkVerticalAlignment=.96/WatermarkVerticalAlignment=.5/' /usr/share/plymouth/themes/spinner/spinner.plymouth
    if [ $de == 2 ];then
        sudo plymouth-set-default-theme -R breeze;else
        sudo plymouth-set-default-theme -R spinner
    fi
fi

#Final Configuration
if [ $de == 1 ];then
    mv ${repo}dotfiles/hypr-rice/* .config/
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
if [ $artix == y ] && [ $de == 2 ];then
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
if ! rg "sysctl.d" <<< $(ls /etc/);then
    sudo mkdir /etc/sysctl.d/
fi
sudo sh -c "echo -e 'kernel.kptr_restrict=2\nkernel.dmesg_restrict=1\nkernel.printk=3 3 3 3\nkernel.yama.ptrace_scope=2\nkernel.unpriviledged_bpf_disabled=1\nnet.core.bpf_jit_harden=2\ndev.tty.ldisc_autoload=0\nvm.unprivileged_userfaultfd=0\nkernel.kexec_load_disabled=1\nkernel.sysrq=4\nkernel.perf_event_paranoid=3\nvm.mmap_rnd_bits=32\nvm.mmap_rnd_compat_bits=16' > /etc/sysctl.d/99-kernel-hardening.conf"
sudo sh -c "echo -e 'net.ipv4.tcp_syncookies=1\nnet.ipv4.tcp_rfc1337=1\nnet.ipv4.conf.all.rp_filter=1\nnet.ipv4.conf.default.rp_filter=1' > /etc/sysctl.d/99-network-security.conf"
sudo sh -c "echo -e 'net.ipv6.conf.all.use_tempaddr = 2\nnet.ipv6.conf.default.use_tempaddr = 2' > /etc/sysctl.d/99-ipv6-privacy.conf"
sudo sh -c "echo -e 'fs.protected_symlinks=1\nfs.protected_hardlinks=1\nfs.protected_fios=2\nfs.protected_regular=2' > /etc/sysctl.d/99-userspace.conf"
sudo sh -c "echo 'vm.max_map_count=2147483642' > /etc/sysctl.d/99-map-count.conf"
#sudo sed -i 's/quiet/spectre_v2=on spec_store_bypass_disable=on l1tf=full,force mds=full tsx=off tsx_async_abort=full kvm.nx_huge_pages=force l1d_flush=on mmio_stale_data=full 
sudo sed -i 's/quiet/lsm=landlock,lockdown,yama,integrity,apparmor,bpf audit=1 slab_nomerge init_on_alloc=1 init_on_free=1 page_alloc.shuffle=1 pti=on randomize_kstack_offset=on vsyscall=none debugfs=off loglevel=0 quiet/' $bootdir
if [ $artix == y ] || [ $grub == y ];then
    sudo grub-mkconfig -o /boot/grub/grub.cfg
fi
sudo sed -i 's/#write-cache/write-cache/' /etc/apparmor/parser.conf
sudo groupadd -r audit
usr=$(whoami)
sudo gpasswd -a $usr audit
sudo sed -i '/log_group/a log_group = audit/' /etc/audit/auditd.conf 

#SystemD Boot Kernel Fallbacks
if [ $artix == n ] || [ "$grub" == n ];then
    cd /boot/loader/entries
    sudo cp arch.conf arch-fallback.conf
    sudo sed -i -e 's/Arch Linux/Arch Linux Fallback/' -i -e 's/initramfs-linux/initramfs-linux-fallback/' arch-fallback.conf
    kernel=$(pacman -Q)
    if rg linux-lts <<< $kernel;then
        sudo cp arch.conf lts.conf
        sudo sed -i -e 's/Arch Linux/Arch Linux-LTS/' -i -e 's/vmlinuz-linux/vmlinuz-linux-lts/' -i -e 's/initramfs-linux/initramfs-linux-lts/' lts.conf
        sudo cp lts.conf lts-fallback.conf
        sudo sed -i -e 's/Arch Linux/Arch Linux-LTS Fallback/' -i -e 's/initramfs-linux-lts/initramfs-linux-lts-fallback/' lts-fallback.conf
    fi
    if rg linux-zen <<< $kernel;then
        sudo cp arch.conf zen.conf
        sudo sed -i -e 's/Arch Linux/Arch Linux-Zen/' -i -e 's/vmlinuz-linux/vmlinuz-linux-zen/' -i -e 's/initramfs-linux/initramfs-linux-zen/' zen.conf
        sudo cp zen.conf zen-fallback.conf
        sudo sed -i -e 's/Arch Linux/Arch Linux-Zen Fallback/' -i -e 's/initramfs-linux-zen/initramfs-linux-zen-fallback/' zen-fallback.conf
    fi
    if rg linux-hardened <<< $kernel;then
        sudo cp arch.conf hardened.conf
        sudo sed -i -e 's/Arch Linux/Arch Linux-Hardened/' -i -e 's/vmlinuz-linux/vmlinuz-linux-hardened/' -i -e 's/initramfs-linux/initramfs-linux-hardened/' hardened.conf
        sudo cp hardened.conf hardened-fallback.conf
        sudo sed -i -e 's/Arch Linux/Arch Linux-Hardened Fallback/' -i -e 's/initramfs-linux-hardened/initramfs-linux-hardened-fallback/' hardened-fallback.conf
    fi
    cd
fi

sudo sed -i 's/#IgnorePkg   =/IgnorePkg   =linux-firmware/' /etc/pacman.conf
######################################################################################################
############################### NEEDS WORKING ON!!! (bashrc editing) #################################
######################################################################################################
if rg linux <<< $(pacman -Q linux-headers | sed 's/-headers//');then
    sudo sed -i 's/IgnorePkg    =/IgnorePkg   =linux linux-headers /' /etc/pacman.conf
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
######################################################################################################
######################################## END OF PROBLEM AREA #########################################
######################################################################################################
if ! rg .config <<< $(sudo ls -a /root/);then
    sudo mkdir /root/.config/
fi
sudo cp -r ${repo}dotfiles/nvim /root/.config/
sudo mv ${repo}dotfiles/root/* /root/.config/
mv ${repo}dotfiles/config/* .config/
if [ $gayms == y ];then
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
if [ $artix == n ];then
    sudo systemctl enable --now systemd-timesyncd cups $dm cronie libvirtd apparmor auditd pkgfile-update.timer
elif [ $init == dinit ]; then
    sudo dinitctl enable ntpd
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
elif [ $init == openrc ]; then
    sudo rc-update add ntpd boot
    sudo rc-update add cupsd boot
    sudo rc-update add $dm boot
    sudo rc-update add apparmor default
    sudo rc-update add auditd default
    sudo rc-update add cronie default
    sudo rc-update add libvirtd default
elif [ $init == s6 ];then
    sudo touch /etc/s6/adminsv/default/contents.d/ntpd
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
if [ $artix == y ];then
    loginctl reboot;else
    reboot
fi

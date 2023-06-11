#Plymouth check & conf
if grep -E plymouth <<< $(pacman -Q plymouth);then
    sudo sed -i 's/udev/udev plymouth/g' /etc/mkinitcpio.conf
    sudo sed -i 's/splash/splash plymouth.nolog/' $bootdir
    if [ $artix == y ] || [ $grub == y ];then
        sudo grub-mkconfig -o /boot/grub/grub.cfg
    fi
    sudo sed -i -e 's/DialogVerticalAlignment=.382/DialogVerticalAlignment=.75/' -i -e 's/WatermarkVerticalAlignment=.96/WatermarkVerticalAlignment=.5/' /usr/share/plymouth/themes/spinner/spinner.plymouth
    #sudo plymouth-set-default-theme -R breeze-text
    sudo plymouth-set-default-theme -R spinner
fi

#SystemD Boot Kernel Fallbacks
if [ $artix == n ] || [ $grub == n ];then
    cd /boot/loader/entries
    sudo cp arch.conf arch-fallback.conf
    sudo sed -i -e 's/Arch Linux/Arch Linux Fallback/' -i -e 's/initramfs-linux/initramfs-linux-fallback/' arch-fallback.conf
    kernel=$(pacman -Q | grep linux)
    if grep -E linux-lts <<< $kernel;then
        sudo cp arch.conf lts.conf
        sudo sed -i -e 's/Arch Linux/Arch Linux-LTS/' -i -e 's/vmlinuz-linux/vmlinuz-linux-lts/' -i -e 's/initramfs-linux/initramfs-linux-lts/' lts.conf
        sudo cp lts.conf lts-fallback.conf
        sudo sed -i -e 's/Arch Linux/Arch Linux-LTS Fallback/' -i -e 's/initramfs-linux-lts/initramfs-linux-lts-fallback/' lts-fallback.conf
    fi
    if grep -E linux-zen <<< $kernel;then
        sudo cp arch.conf zen.conf
        sudo sed -i -e 's/Arch Linux/Arch Linux-Zen/' -i -e 's/vmlinuz-linux/vmlinuz-linux-zen/' -i -e 's/initramfs-linux/initramfs-linux-zen/' zen.conf
        sudo cp zen.conf zen-fallback.conf
        sudo sed -i -e 's/Arch Linux/Arch Linux-Zen Fallback/' -i -e 's/initramfs-linux-zen/initramfs-linux-zen-fallback/' zen-fallback.conf
    fi
    if grep -E linux-hardened <<< $kernel;then
        sudo cp arch.conf hardened.conf
        sudo sed -i -e 's/Arch Linux/Arch Linux-Hardened/' -i -e 's/vmlinuz-linux/vmlinuz-linux-hardened/' -i -e 's/initramfs-linux/initramfs-linux-hardened/' hardened.conf
        sudo cp hardened.conf hardened-fallback.conf
        sudo sed -i -e 's/Arch Linux/Arch Linux-Hardened Fallback/' -i -e 's/initramfs-linux-hardened/initramfs-linux-hardened-fallback/' hardened-fallback.conf
    fi
    cd
fi

#Final Configuration
if [ $de == 1 ];then
    mv ${repo}dotfiles/hypr-rice/* .config/
    mv ${repo}dotfiles/thumbnailers .local/share/
    mv ${repo}dotfiles/set-as-background.nemo_action .local/share/nemo/actions
    gsettings set org.cinnamon.desktop.privacy remember-recent-files false
    gsettings set org.cinnamon.desktop.default-applications.terminal exec alacritty
fi
if [ $dm == sddm ];then
    if [ $de == 2 ];then
    echo -e "[Theme]\nCurrent=breeze" > sddm.conf;else
    echo -e "[Theme]\nCurrent=archlinux-simplyblack" > sddm.conf
    fi
    sudo chown root:root sddm.conf
    sudo mv sddm.conf /etc/
fi
if ! grep -E "sysctl.d" <<< $(ls /etc/);then
    sudo mkdir /etc/sysctl.d/
fi
echo "vm.max_map_count=2147483642" > 90-override.conf
sudo chown root:root 90-override.conf
sudo mv 90-override.conf /etc/sysctl.d/
sudo sed -i 's/#IgnorePkg   =/IgnorePkg   =linux-lts linux-lts-headers linux linux-headers linux-firmware/' /etc/pacman.conf
######################################################################################################
############################### NEEDS WORKING ON!!! (bashrc editing) #################################
######################################################################################################
#if grep -E linux-lts <<< $kernel;then
#    sudo sed -i 's/IgnorePkg   =/IgnorePkg   =linux-lts linux-lts-headers ' /etc/pacman.conf
#fi
#if grep -E linux-zen <<< $kernel;then
#    sudo sed -i 's/IgnorePkg   =/IgnorePkg   =linux-zen linux-zen-headers ' /etc/pacman.conf
#fi
#if grep -E linux-hardened <<< $kernel;then
#    sudo sed -i 's/IgnorePkg   =/IgnorePkg   =linux-hardened linux-hardened-headers ' /etc/pacman.conf
#fi
######################################################################################################
######################################## END OF PROBLEM AREA #########################################
######################################################################################################
mv ${repo}dotfiles/config/* .config/
if [ $gayms == y ];then
    if ! grep -E "retroarch" <<< $(ls .config);then
        mkdir .config/retroarch
    fi
    mv ${repo}dotfiles/retroarch.cfg .config/retroarch
fi
mv ${repo}dotfiles/bashrc .bashrc
mv ${repo}dotfiles/inputrc .inputrc
sudo sed -i -e 's/#unix_sock_group = "libvirt"/unix_sock_group = "libvirt"/' -i -e 's/#unix_sock_ro_perms = "0777"/unix_sock_ro_perms = "0777"/' -i -e 's/#unix_sock_rw_perms = "0770"/unix_sock_rw_perms = "0770"/' /etc/libvirt/libvirtd.conf
vir=$(whoami)
sudo usermod -aG libvirt $vir
if [ $artix == n ]; then
    #############################################
    ###### ADD FEATURE FOR TIMEZONE SELECT ######
    #############################################
    sudo systemctl enable systemd-timesyncd cups $dm pkgfile-update.timer
    systemctl --user --now enable wireplumber.service pipewire.service pipewire-pulse.service
elif [ $init == dinit ]; then
    sudo dinitctl enable ntpd
    sudo dinitctl enable cupsd
    sudo dinitctl enable $dm
    sudo dinitctl enable libvirtd
elif [ $init == runit ]; then
    sudo ln -s /etc/runit/sv/ntpd /run/runit/service
    sudo ln -s /etc/runit/sv/cupsd /run/runit/service
    sudo ln -s /etc/runit/sv/$dm /run/runit/service
elif [ $init == openrc ]; then
    sudo rc-update add ntpd boot
    sudo rc-update add cupsd boot
    sudo rc-update add $dm boot
    sudo rc-update add libvirtd default
elif [ $init == s6 ];then
    sudo touch /etc/s6/adminsv/default/contents.d/ntpd
    sudo touch /etc/s6/adminsv/default/contents.d/$dm
    sudo touch /etc/s6/adminsv/default/contents.d/cupsd
    sudo s6-db-reload
fi
sudo pkgfile --update
#if [ $doch == y ];then
#    doasconf > doas.conf
#    sudo chown root:root doas.conf
#    sudo mv doas.conf /etc/
#fi
rm -rf ${repo}
if [ $bin == y ];then
    rm -rf paru-bin/;else
    rm -rf paru/
fi
if [ $artix == y ];then
    loginctl reboot;else
    reboot
fi

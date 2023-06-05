#Plymouth check & conf
if grep -E plymouth <<< $(pacman -Q plymouth);then
    sudo sed -i 's/udev/udev plymouth/g' /etc/mkinitcpio.conf
    sudo mkinitcpio -P
    sudo sed -i 's/splash/splash plymouth.nolog/' $bootdir
    if [ $artix == y ] || [ $grub == y ];then
        sudo grub-mkconfig -o /boot/grub/grub.cfg
    fi
    sudo sed -i -e 's/DialogVerticalAlignment=.382/DialogVerticalAlignment=.75/' -i -e 's/WatermarkVerticalAlignment=.96/WatermarkVerticalAlignment=.5/' /usr/share/plymouth/themes/spinner/spinner.plymouth
    sudo plymouth-set-default-theme -R breeze-text
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
gsettings set org.cinnamon.desktop.privacy remember-recent-files false
gsettings set org.cinnamon.desktop.default-applications.terminal exec alacritty
sudo echo -e "[Theme]\nCurrent=archlinux-simplyblack" > /etc/sddm.conf
sudo echo "vm.max_map_count=2147483642" > etc/sysctl.d/90-override.conf
sudo sed -i 's/#IgnorePkg   =/IgnorePkg   =linux linux-headers linux-firmware/' /etc/pacman.conf
######################################################################################################
############################### NEEDS WORKING ON!!! (bashrc editing) #################################
######################################################################################################
if grep -E linux-lts <<< $kernel;then
    sudo sed -i 's/IgnorePkg   =/IgnorePkg   =linux-lts linux-lts-headers ' /etc/pacman.conf
fi
if grep -E linux-zen <<< $kernel;then
    sudo sed -i 's/IgnorePkg   =/IgnorePkg   =linux-zen linux-zen-headers ' /etc/pacman.conf
fi
if grep -E linux-hardened <<< $kernel;then
    sudo sed -i 's/IgnorePkg   =/IgnorePkg   =linux-hardened linux-hardened-headers ' /etc/pacman.conf
fi
######################################################################################################
######################################## END OF PROBLEM AREA #########################################
######################################################################################################
mv ${repo}/dotfiles/config/* .config/
mv ${repo}/dotfiles/retroarch.cfg .config/retroarch
mv ${repo}/dotfiles/bashrc .bashrc
mv ${repo}/dotfiles/inputrc .inputrc
mv ${repo}/dotfiles/thumbnailers .local/share/
mv ${repo}/dotfiles/set-as-background.nemo_action .local/share/nemo/actions
if [ $artix == n ]; then
    #############################################
    ###### ADD FEATURE FOR TIMEZONE SELECT ######
    #############################################
    sudo systemctl enable systemd-timesyncd cups sddm pkgfile-update.timer
    systemctl --user --now enable wireplumber.service pipewire.service pipewire-pulse.service
elif [ $init == dinit ]; then
    sudo dinitctl enable ntpd
    sudo dinitctl enable cupsd
    sudo dinitctl enable sddm
elif [ $init == runit ]; then
    sudo ln -s /etc/runit/sv/ntpd /run/runit/service
    sudo ln -s /etc/runit/sv/cupsd /run/runit/service
    sudo ln -s /etc/runit/sv/sddm /run/runit/service
elif [ $init == openrc ]; then
    sudo rc-update add ntpd boot
    sudo rc-update add cupsd boot
    sudo rc-update add sddm boot
elif [ $init == s6 ];then
    sudo touch /etc/s6/adminsv/default/contents.d/ntpd
    sudo touch /etc/s6/adminsv/default/contents.d/sddm
    sudo touch /etc/s6/adminsv/default/contents.d/cupsd
    sudo s6-db-reload
fi
sudo pkgfile --update
if [ $doch == y ];then
    doasconf > doas.conf
    sudo chown -c root:root $doas.conf
    sudo chmod -c 0400 doas.conf
    sudo mv doas.conf /etc/
fi
rm -rf grapejuice-git/ ${repo}/ paru/
if [ $artix == y ]; then
    sed -i 's/#exec-once/exec-once/' ~/.config/hypr/hyprland.conf
    loginctl reboot
else
    reboot
fi
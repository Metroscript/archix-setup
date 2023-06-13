#CPU Ucode
if grep -E "AuthenticAMD" <<< $(lscpu) && ! grep -E "amd-ucode" <<< $(pacman -Q);then
   sudo pacman -S --needed --noconfirm amd-ucode
   if [ $artix == y ] || [ $grub == y ];then
   	sudo grub-mkconfig -o /boot/grub/grub.cfg;else
   	sudo sed -i '/vmlinuz/a initrd /amd-ucode.img' /boot/loader/entries/arch.conf
   fi
elif grep -E "GenuineIntel" <<< $(lscpu) && ! grep -E "intel-ucode" <<< $(pacman -Q);then
    sudo pacman -S --needed --noconfirm intel-ucode
    if [ $artix == y ] || [ $grub == y ];then
        sudo grub-mkconfig -o /boot/grub/grub.cfg;else
    	sudo sed -i '/vmlinuz/a initrd /intel-ucode.img' /boot/loader/entries/arch.conf
    fi
fi
	#Graphics drivers
    #######################################
    ##### NVIDIA DRIVERS MAY NOT WORK #####
    #######################################
# AMD DRIVERS #
sudo pacman -S --noconfirm --needed xf86-video-amdgpu vulkan-{radeon,icd-loader} mesa lib{va-mesa-driver,32-{libva-mesa-driver,mesa,vulkan-{radeon,icd-loader}}}
#gpu=$(lspci)
#if lspci | grep 'VGA' | grep -E "Radeon|AMD";then
#   sudo pacman -S --noconfirm --needed xf86-video-amdgpu vulkan-{radeon,icd-loader} mesa lib{va-mesa-driver,32-{libva-mesa-driver,mesa,vulkan-{radeon,icd-loader}}}
#elif grep -E "NVIDIA|GeForce" <<< $gpu;then
#   sudo pacman -S --noconfirm --needed nvidia{,-utils} lib32-{nvidia-utils,vulkan-icd-loader} vulkan-icd-loader
#   nvidia-xconfig
#elif grep -E "Integrated Graphics Controller" <<< $gpu || grep -E "Intel Corporation UHD" <<< $gpu;then
#     sudo pacman -S --noconfirm --needed xf86-video-intel vulkan-{intel,icd-loader} mesa lib{va-{intel-driver,utils},vdpau-va-gl,32-{vulkan-{intel,icd-loader},mesa,libva-intel-driver}}
#fi
sudo pacman -Syu --needed --noconfirm vkd3d lib32-vkd3d

#Basic packages
if [ $kerinst -gt 0 ];then
    if [ $kerinst == 1 ];then
        sudo pacman -Syu --needed --noconfirm linux{,-headers}
    elif [ $kerinst == 2 ];then
        sudo pacman -Syu --needed --noconfirm linux-lts{,-headers}
    elif [ $kerinst == 3 ];then
        sudo pacman -Syu --needed --noconfirm linux-hardened{,-headers};else
        sudo pacman -Syu --needed --noconfirm linux-zen{,-headers}
    fi
fi
sudo pacman -Syu --needed --noconfirm pipewire{,-{audio,jack,pulse,alsa,v4l2}} wireplumber man-db wayland xorg-xwayland smartmontools v4l2loopback-dkms pkgfile gst-plugin-pipewire gnu-free-fonts noto-fonts ttf-{jetbrains-mono-nerd,ubuntu-nerd,noto-nerd} cups{,-pk-helper,-pdf} gutenprint foomatic-db-{engine,ppds,gutenprint-ppds} libsecret python-{mutagen,pysmbc} yt-dlp ffmpeg atomicparsley firewalld fuse neofetch arj binutils bzip2 cpio gzip l{hasa,rzip,z{4,ip,op}} p7zip tar un{rar,zip,arj,ace} xz zip zstd squashfs-tools ripgrep fd bat lsd fortune-mod ponysay mesa jre{-openjdk,11-openjdk,8-openjdk} libreoffice-fresh{,-en-gb} hunspell{,-en_au} coin-or-mp beanshell mariadb-libs postgresql-libs pstoedit sane gimp mythes-en lib{paper,wpg,pulse,mythes,32-{gnutls,libpulse,alsa-{lib,plugins},pipewire{,-jack,-v4l2},mesa}} keepassxc gst-{libav,plugins-{base,good}} phonon-qt5-gstreamer imagemagick djvulibre ghostscript lib{heif,jxl,raw,rsvg,webp,wmf,xml2,zip} ocl-icd open{exr,jpeg2} wget jq qemu-full virt-{manager,viewer} dnsmasq vde2 bridge-utils openbsd-netcat plymouth

    #Games, etc
if [ $gayms == y ];then
    sudo pacman -Syu --needed --noconfirm wine{,-gecko,-mono} lutris steam retroarch{,-assets-{glui,ozone,xmb}} gamemode lib{32-gamemode,retro-{dolphin,pcsx2,citra,melonds,duckstation}}
fi

	#AUR
if [ $suas == y ];then
    sudo sed -i 's,#PACMAN_AUTH=(),PACMAN_AUTH=(/bin/doas),' /etc/makepkg.conf
fi

if [ $bin == y ];then
    git clone https://aur.archlinux.org/paru-bin.git
    cd paru-bin;else
    git clone https://aur.archlinux.org/paru.git
    cd paru
fi
makepkg -si --noconfirm
cd
if ! rg .config <<< $(ls -a);then
    mkdir -p .config/paru/;else
    mkdir .config/paru/
fi
cp /etc/paru.conf .config/paru/
sed -i -e 's/#SudoLoop/SudoLoop/' -i -e 's/#Clean/Clean/' -i -e 's/#UpgradeMenu/UpgradeMenu/' -i -e 's/#News/News/' .config/paru/paru.conf
if [ $suas == y ];then
    sed -i -e 's/SudoLoop/SudoLoop = true/' -i -e 's/#\[bin\]/\[bin\]/' -i -e 's,#Sudo = doas,Sudo = /bin/doas,' .config/paru/paru.conf
fi

if [ $bin == y ];then
    if [ $de == 1 ];then
        paru -S sddm-git archlinux-themes-sddm
    fi
    if [ $gayms == y ];then
        if [ $rlx == y ];then
            paru -S grapejuice-git
        fi
        if [ $min == y ];then
            paru -S prismlauncher-bin
        fi
        if [ $waydroid == y ];then
            paru -S waydroid
        fi
    fi
    if [ $artix == y ];then
        paru -S downgrade
        sudo pacman -S --needed --noconfirm librewolf timeshift;else
        paru -S downgrade librewolf-bin timeshift-bin
    fi
else
    if [ $de == 1 ];then
        paru -S sddm-git archlinux-themes-sddm
    fi
    if [ $gayms == y ];then
        if [ $rlx == y ];then
            paru -S grapejuice-git
        fi
        if [ $min == y ];then
            paru -S prismlauncher
        fi
        if [ $waydroid == y ];then
            paru -S waydroid
        fi
    fi
    if [ $artix == y ];then
        paru -S downgrade
        sudo pacman -S --needed --noconfirm librewolf timeshift;else
        paru -S librewolf timeshift downgrade
    fi
fi

#Artix Init Services
if [ $artix == y ]; then
    sudo pacman -S --needed --noconfirm ${dm}-$init cups-$init openntpd-$init firewalld-$init power-profiles-daemon-$init avahi-$init libvirt-$init
fi

#Hyprland 
if [ $de == 1 ];then
sudo pacman -Syu --needed --noconfirm alacritty obs-studio btop simple-scan mpv gnome-font-viewer kdenlive bigsh0t dvgrab mediainfo noise-suppression-for-voice open{cv,timelineio} recordmydesktop rhythmbox lollypop krita okular deluge-gtk
sudo pacman -Syu --needed --noconfirm wl-clipboard cliphist qt{5{ct,-wayland},6{ct,-wayland}} pavucontrol nemo{,-{fileroller,share}} catdoc odt2txt poppler libgsf gvfs-{mtp,afc,nfs,smb} ffmpegthumbnailer polkit-gnome imv calcurse gamescope brightnessctl udiskie gammastep swayidle hyprland xdg-desktop-portal-hyprland breeze-{icons,gtk}
paru -S --needed wlogout rofi-lbonn-wayland-git waybar-hyprland-git hyprpicker-git swww nwg-look swaync wlr-randr grimblast swaylock-effects-git psuinfo
sudo pacman -Syu --needed --noconfirm rofi-calc
elif [ $de == 2 ];then
    sudo pacman -Syu --needed --noconfirm plasma{,-wayland-session} kde-applications
fi
#Flatpak
sudo pacman -Syu --needed --noconfirm flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

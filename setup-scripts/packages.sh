#CPU Ucode
if grep -E "AuthenticAMD" <<< $(lscpu);then
   sudo pacman -S --needed --noconfirm amd-ucode
   if [ $artix == y ] || [ $grub == y ];then
   	sudo grub-mkconfig -o /boot/grub/grub.cfg
   else
   	sudo sed -i '/vmlinuz/a initrd /amd-ucode.img' /boot/loader/entries/arch.conf
   fi
else
    sudo pacman -S --needed --noconfirm intel-ucode
    if [ $artix == y ] || [ $grub == y ];then
        sudo grub-mkconfig -o /boot/grub/grub.cfg
    else
    	sudo sed -i '/vmlinuz/a initrd /intel-ucode.img' /boot/loader/entries/arch.conf
    fi
fi
	#Graphics drivers
gpu=$(lspci)
if grep -E "NVIDIA|GeForce" <<< $gpu;then
   sudo pacman -S --noconfirm --needed nvidia{,-utils} lib32-{nvidia-utils,vulkan-icd-loader} vulkan-icd-loader
   nvidia-xconfig
elif lspci | grep 'VGA' | grep -E "Radeon|AMD";then
   sudo pacman -S --noconfirm --needed xf86-video-amdgpu vulkan-{radeon,icd-loader} lib{va-mesa-driver,32-{libva-mesa-driver,mesa,vulkan-{radeon,icd-loader}}}
elif grep -E "Integrated Graphics Controller" <<< $gpu || grep -E "Intel Corporation UHD" <<< $gpu;then
     sudo pacman -S --noconfirm --needed xf86-video-intel vulkan-{intel,icd-loader} lib{va-{intel-driver,utils},vdpau-va-gl,32-{vulkan-{intel,icd-loader},mesa,libva-intel-driver}}
fi
sudo pacman -Syu --needed --noconfirm vkd3d lib32-vkd3d

    #Basic packages
   #Make dirs
#mkdir
sudo pacman -Syu --needed --noconfirm linux-{headers,lts{,-headers}} pipewire{,-{audio,jack,pulse,alsa,v4l2}} wireplumber man-db alacritty wayland xorg-xwayland smartmontools v4l2loopback-dkms pkgfile gst-plugin-pipewire obs-studio gnu-free-fonts noto-fonts ttf-{jetbrains-mono-nerd,hack-nerd,ubuntu-nerd,noto-nerd} btop cups{,-pk-helper,-pdf} gutenprint foomatic-db-{engine,ppds,gutenprint-ppds} libsecret python-{mutagen,pysmbc} simple-scan yt-dlp ffmpeg atomicparsley firewalld fuse neofetch arj binutils bzip2 cpio gzip l{hasa,rzip,z{4,ip,op}} p7zip tar un{rar,zip,arj,ace} xz zip zstd squashfs-tools mpv fd bat lf lsd fortune-mod ponysay jre{-openjdk,11-openjdk,8-openjdk} rust libreoffice-fresh{,-en-gb} hunspell{,-en_au} coin-or-mp beanshell mariadb-libs postgresql-libs pstoedit sane gimp gparted gnome-{font-viewer,calculator} mythes-en lib{paper,wpg,pulse,mythes,32-{gnutls,libpulse,alsa-{lib,plugins},pipewire{,-jack,-v4l2},mesa}} keepassxc kdenlive bigsh0t dvgrab mediainfo noise-suppression-for-voice open{cv,timelineio} recordmydesktop rhythmbox lollypop gst-{libav,plugins-{base,good}} cmus gnome-boxes krita okular apparmor deluge-gtk phonon-qt5-gstreamer imagemagick djvulibre ghostscript lib{heif,jxl,raw,rsvg,webp,wmf,xml2,zip} ocl-icd open{exr,jpeg2} materia-gtk-theme wget jq

    #Games, etc
sudo pacman -Syu --needed --noconfirm wine{,-gecko,-mono} lutris steam plymouth breeze-plymouth retroarch{,-assets{glui,ozone,xmb}} gamemode lib{32-gamemode,retro-{dolphin,pcsx2,citra,melonds,duckstation}}

	#AUR
git clone --depth=1 https://aur.archlinux.org/grapejuice-git.git
cd grapejuice-git
bat PKGBUILD
makepkg -si --noconfirm
cd
git clone https://aur.archlinux.org/paru.git
cd paru
bat PKGBUILD
makepkg -si --noconfirm
cd
mkdir .config/paru
cp /etc/paru.conf .config/paru
sed -i -e 's/#Clean/Clean/' -i -e 's/#News/News/' .config/paru/paru.conf
if [ $suas == y ]; then
    sed -i -e 's/#[bin]/[bin]/' -i -e 's\#Sudo = doas\Sudo = /bin/doas\' .config/paru/paru.conf
fi
if [ $bin == y ]; then
    if [ $artix == y ]; then
    	paru -S downgrade prismlauncher-bin sddm-git archlinux-themes-sddm
	    sudo pacman -S librewolf timeshift
    else
    	paru -S librewolf-bin timeshift-bin downgrade prismlauncher-bin sddm-git archlinux-sddm-themes
    fi
elif [ $artix == y ];then
    sudo pacman -S librewolf timeshift
    paru -S downgrade prismlauncher sddm-git archlinux-themes-sddm
else
    paru -S librewolf timeshift downgrade prismlauncher sddm-git archlinux-themes-sddm
fi

#Artix Exclusive packages
if [ $artix == y ]; then
    sudo pacman -S sddm-$init cups-$init openntpd-$init firewalld-$init power-profiles-daemon-$init avahi-$init
fi

if [ $de == 1 ]; then
    #Hyprland 
    sudo pacman -Syu --needed --noconfirm wl-clipboard cliphist qt{5{ct,-wayland},6{ct,-wayland}} pavucontrol nemo{,-{fileroller,share}} catdoc odt2txt poppler libgsf gvfs-{mtp,afc,nfs,smb} ffmpegthumbnailer polkit-gnome imv calcurse gamescope brightnessctl udiskie gammastep swayidle hyprland xdg-desktop-portal-hyprland breeze-{icons,gtk}
    paru -S --needed rofi-lbonn-wayland-git waybar-hyprland-git hyprpicker-git swww nwg-look swaync wlr-randr grimblast swaylock-effects-git
    sudo pacman -S --needed --noconfirm rofi-calc
elif [ $de == 2 ]; then
    #KDE Plasma
    sudo pacman -Syu --needed --noconfirm packagekit-qt5 plasma-{wayland-session,nm,desktop,pa,firewall,disks,thunderbolt,vault,systemmonitor} k{gamma5,infocenter,screen{,locker},menuedit,wayland-integration,pipewire,de{graphics-thumbnailers,plasma-addons,-gtk-config}} powerdevil discover sddm-kcm dolphin ark spectacle xdg-desktop-portal-kde flatpak-kcm plymouth-kcm ffmpegthumbs gwenview qt5-imageformats
fi

#Flatpak
sudo pacman -Syu --needed --noconfirm flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
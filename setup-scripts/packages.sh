#CPU Ucode
if grep -E "AuthenticAMD" <<< $(lscpu) && ! grep -E "amd-ucode" <<< $(pacman -Q);then
   sudo pacman -S --needed --noconfirm amd-ucode
   sudo sed -i 's/quiet/amd_iommu=on quiet/' $bootdir
elif grep -E "GenuineIntel" <<< $(lscpu) && ! grep -E "intel-ucode" <<< $(pacman -Q);then
    sudo pacman -S --needed --noconfirm intel-ucode
    sudo sed -i 's/quiet/intel_iommu=on quiet/' $bootdir
fi
sudo sed -i 's/quiet/efi=disable_early_pci_dma quiet/' $bootdir
#Graphics drivers
    #######################################
    ##### NVIDIA DRIVERS MAY NOT WORK #####
    #######################################
gpu=$(lspci | grep VGA)
if grep -E "Radeon|AMD|ATI" <<< $gpu;then
   sudo pacman -Syu --noconfirm --needed vulkan-{radeon,icd-loader} mesa{,-vdpau} lib{va-mesa-driver,32-{libva-mesa-driver,mesa{,-vdpau},vulkan-{radeon,icd-loader}}}
#elif grep -E "NVIDIA|GeForce" <<< $gpu;then
#   sudo pacman -S --noconfirm --needed nvidia{,-utils} lib32-{nvidia-utils,vulkan-icd-loader} vulkan-icd-loader
#   nvidia-xconfig
elif grep -E "Intel Corporation|UHD" <<< $gpu;then
     sudo pacman -Syu --noconfirm --needed vulkan-{intel,icd-loader} mesa lib{va-{intel-driver,utils},vdpau-va-gl,32-{vulkan-{intel,icd-loader},mesa,libva-intel-driver}} intel-media-driver
fi
sudo pacman -Syu --needed --noconfirm vkd3d lib32-vkd3d

#Basic packages
sudo pacman -Syu --needed --noconfirm pipewire{,-{audio,jack,pulse,alsa,v4l2}} wireplumber man-db wayland xorg-xwayland smartmontools strace v4l2loopback-dkms gst-plugin-pipewire gnu-free-fonts noto-fonts ttf-{dejavu,liberation,hack-nerd,ubuntu-font-family} cups{,-pk-helper,-pdf} gutenprint net-tools asp power-profiles-daemon gparted foomatic-db-{engine,ppds,gutenprint-ppds} libsecret python-{mutagen,pysmbc} yt-dlp ffmpeg atomicparsley ufw fuse neofetch arj binutils bzip2 cpio gzip l{hasa,rzip,z{4,ip,op}} p7zip tar un{archiver,rar,zip,arj,ace} xz zip zstd squashfs-tools ripgrep fd bat lsd fortune-mod ponysay libreoffice-still{,-en-gb} hunspell{,-en_{au,gb,us}} hyphen-en mythes-en coin-or-mp beanshell mariadb-libs postgresql-libs pstoedit sane gimp lib{paper,wpg,pulse,mythes,32-{gnutls,libpulse,alsa-{lib,plugins},pipewire{,-jack,-v4l2}}} keepassxc gst-{libav,plugins-{base,good}} phonon-qt5-gstreamer imagemagick djvulibre ghostscript lib{heif,jxl,raw,rsvg,webp,wmf,xml2,zip} ocl-icd open{exr,jpeg2} wget jq qemu-full edk2-ovmf virt-{manager,viewer} dnsmasq vde2 bridge-utils openbsd-netcat nvme-cli apparmor audit python-{notify2,psutil} noise-suppression-for-voice wl-clipboard rng-tools alacritty obs-studio btop mpv kdenlive bigsh0t dvgrab mediainfo open{cv,timelineio} recordmydesktop rhythmbox lollypop krita qbittorrent blender libdecor

if [ $mtdi == y ];then
    sudo pacman -S --noconfirm --needed lbzip2 pigz
fi
if [ $ply == y ];then
    sudo pacman -S --noconfirm --needed plymouth
fi
    #Games, etc
if [ $gayms == y ];then
    sudo pacman -Syu --needed --noconfirm wine{,-gecko,-mono} lutris steam retroarch{,-assets-{glui,ozone,xmb}} gamemode lib{32-gamemode,retro-{dolphin,pcsx2,citra,melonds,duckstation}}
fi

#Flatpak
if grep "linux-hardened" <<< $(pacman -Q);then
   sudo pacman -Syu --needed --noconfirm flatpak bubblewrap-suid;else
   sudo pacman -Syu --needed --noconfirm flatpak bubblewrap
fi
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

#AUR
if [ "$suas" == y ];then
    sudo sed -i 's,#PACMAN_AUTH=(),PACMAN_AUTH=(/bin/doas),' /etc/makepkg.conf
fi
if [ $opt == y ];then
    sudo sed -i -e 's/#MAKEFLAGS.*/MAKEFLAGS="-j\$(nproc)"/' -i -e 's/(xz/(xz --threads=0/' -i -e 's/(zstd/(zstd --threads=0/' -i -e 's/-march=x86-64 -mtune=generic/-march=native/' -i -e 's/#RUSTFLAGS.*/RUSTFLAGS="-C opt-level=3 -C target-cpu=native"/' /etc/makepkg.conf
    if [ $mtdi == y ];then
        sudo sed -i -e 's/(bzip2/(lbzip2/' -i -e 's/(gzip/(pigz/' /etc/makepkg.conf
    fi
fi

if [ $bin == y ];then
    git clone https://aur.archlinux.org/paru-bin.git
    cd paru-bin;else
    git clone https://aur.archlinux.org/paru.git
    cd paru
fi
makepkg -sic --noconfirm
cd
if ! grep .config <<< $(ls -a);then
    mkdir -p .config/paru/;else
    mkdir .config/paru/
fi
cp /etc/paru.conf .config/paru/
sed -i -e 's/#SudoLoop/SudoLoop/' -i -e 's/#Clean/Clean/' -i -e 's/#UpgradeMenu/UpgradeMenu/' -i -e 's/#News/News/' .config/paru/paru.conf
if [ "$suas" == y ];then
    sed -i -e 's/SudoLoop/SudoLoop = true/' -i -e 's/#\[bin\]/\[bin\]/' -i -e 's,#Sudo = doas,Sudo = /bin/doas,' .config/paru/paru.conf
fi

if [ $de == 1 ];then
    paru -S sddm-git archlinux-themes-sddm
fi
if [ $mkfirm == y ];then
    paru -S mkinitcpio-firmware
fi
if [ "$rlx" == y ];then
    paru -S grapejuice-git
fi
if [ "$waydroid" == y ];then
    paru -S waydroid
fi
if [ $makemkv == y ];then
    paru -S makemkv
fi
if [ $rgb == y ];then
    paru -S openrgb
fi
if [ $bin == y ];then
    if [ "$min" == y ];then
        paru -S prismlauncher-bin jre{-openjdk,11-openjdk,8-openjdk}
    fi
    if [ "$artix" == y ];then
        sudo pacman -S --needed --noconfirm librewolf
        paru -S psuinfo;else
        paru -S librewolf-bin psuinfo
    fi
else
    if [ "$min" == y ];then
        paru -S prismlauncher jre{-openjdk,17-openjdk,11-openjdk,8-openjdk}
    fi
    if [ "$artix" == y ];then
        sudo pacman -S --needed --noconfirm librewolf
        paru -S psuinfo;else
        paru -S librewolf psuinfo
    fi
fi

if ! [ $cron == fcron ];then
    if [ "$artix" == y ];then
        sudo pacman -S timeshift;else
        paru -S timeshift
    fi
fi

#Artix Init Services
if [ "$artix" == y ];then
    sudo pacman -S --needed --noconfirm ${dm}-$init ${init}-system cups-$init openntpd-$init ufw-$init power-profiles-daemon-$init avahi-$init libvirt-$init apparmor-$init audit-$init rng-tools-$init
    if [ $cron == fcron ];then
       sudo pacman -Rns --noconfirm cronie-$init
       sudo pacman -S --noconfirm fcron-$init
    fi;else
    sudo pacman -S --needed --noconfirm $cron
fi

if grep btrfs <<< $(lsblk -oFSTYPE);then
   sudo pacman -Syu --needed --noconfirm grub-btrfs btrfs-progs
fi

#Hyprland 
if [ $de == 1 ];then
sudo pacman -Syu --needed --noconfirm cliphist qt{5{ct,-wayland},6{ct,-wayland}} pavucontrol nemo{,-{fileroller,share}} catdoc odt2txt poppler libgsf gvfs-{mtp,afc,nfs,smb} ffmpegthumbnailer polkit-gnome imv calcurse gamescope brightnessctl udiskie gammastep swayidle hyprland xdg-desktop-portal-hyprland papirus-icon-theme breeze-{icons,gtk} mako simple-scan gnome-font-viewer okular ttf-noto-nerd
paru -S --needed wlogout rofi-lbonn-wayland-git waybar-hyprland-git hyprpicker-git swww nwg-look wlr-randr grimblast swaylock-effects-git
sudo pacman -Syu --needed --noconfirm rofi-calc
elif [ $de == 2 ];then
    sudo pacman -Syu --needed --noconfirm plasma-{meta,wayland-session} cryfs flatpak-kcm plymouth-kcm fwupd packagekit-qt5 xdg-desktop-portal-{kde,gtk} gwenview kimageformats qt5-imageformats dolphin{,-plugins} ffmpegthumbs kde{-{inotify-survey,cli-tools},graphics-thumbnailers,network-filesharing} kio-{admin,fuse,extras} purpose icoutils libappimage openexr perl taglib kmousetool kontrast colord-kde kcolorchooser kruler okular spectacle svgpart kcron ark filelight kate kbackup kcalc kcharselect kclock kdialog keditbookmarks kweather markdownpart print-manager skanpage maliit-keyboard
fi

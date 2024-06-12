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
gpu=$(lspci|grep VGA)
if grep -E "Radeon|AMD|ATI" <<< $gpu && grep -E "Intel Corporation|UHD" <<< $gpu;then
    sudo pacman -Syu --noconfirm --needed vulkan-{radeon,intel,icd-loader} mesa{,-vdpau} opencl-rusticl-mesa libva-{mesa,vdpau}-driver intel-media-driver
    if [ $games == y ];then
        sudo pacman -S --needed --noconfirm lib32-vulkan-{radeon,intel}
    fi
    echo -e 'RUSTICL_ENABLE=radeonsi,iris\nRADV_PERFTEST=video_decode\nANV_VIDEO_DECODE=1' | sudo tee -a /etc/environment
elif grep -E "Radeon|AMD|ATI" <<< $gpu;then
   sudo pacman -Syu --noconfirm --needed vulkan-{radeon,icd-loader} mesa{,-vdpau} opencl-rusticl-mesa libva-{mesa,vdpau}-driver
   if [ $games == y ];then
       sudo pacman -S --needed --noconfirm lib32-vulkan-radeon
   fi
   echo -e 'RUSTICL_ENABLE=radeonsi\nRADV_PERFTEST=video_decode' | sudo tee -a /etc/environment
elif grep -E "Intel Corporation|UHD" <<< $gpu;then
     sudo pacman -Syu --noconfirm --needed vulkan-{intel,icd-loader} mesa opencl-rusticl-mesa libva-{{intel-driver,utils},vdpau-driver} intel-media-driver
     if [ $games == y ];then
         sudo pacman -S --needed --noconfirm lib32-vulkan-intel
     fi
     echo -e 'RUSTICL_ENABLE=iris\nANV_VIDEO_DECODE=1' | sudo tee -a /etc/environment
fi

#Basic packages
sudo pacman -Syu --needed --noconfirm pipewire{,-{audio,jack,pulse,alsa,v4l2}} wireplumber man-db wayland xorg-xwayland smartmontools strace v4l2loopback-dkms gst-plugin-pipewire gnu-free-fonts noto-fonts ttf-{dejavu,liberation,hack-nerd,ubuntu-font-family} bash-language-server cups{,-pk-helper,-pdf} gutenprint net-tools power-profiles-daemon gparted foomatic-db-{engine,ppds,gutenprint-ppds} libsecret python-{mutagen,pysmbc} yt-dlp ffmpeg atomicparsley ufw fuse fastfetch arj binutils bzip2 cpio gzip l{hasa,rzip,z{4,ip,op}} p7zip tar un{archiver,rar,zip,arj,ace} xz zip zstd squashfs-tools ripgrep fd bat lsd fortune-mod ponysay hunspell{,-en_{au,gb,us}} libpulse keepassxc gst-{libav,plugins-{base,good}} imagemagick djvulibre ghostscript lib{heif,jxl,raw,rsvg,webp,wmf,xml2,zip} ocl-icd open{exr,jpeg2} wget jq nvme-cli apparmor audit python-{notify2,psutil} noise-suppression-for-voice wl-clipboard rng-tools opensc btop mpv lollypop qbittorrent nvtop $shell openntpd libressl earlyoom $terminal clamav
if [ $terminal == kitty ];then
    sudo pacman -S --needed --noconfirm python-pygments
fi
if [ $multitools == y ];then
    sudo pacman -S --needed --noconfirm obs-studio kdenlive movit bigsh0t dvgrab mediainfo open{cv,timelineio} recordmydesktop
fi
if [ $graphitools == y ];then
    sudo pacman -S --needed --noconfirm gimp blender libdecor
fi
if [ $office == y ];then
    sudo pacman -S --needed --noconfirm libreoffice-fresh{,-en-gb} hyphen-en mythes-en coin-or-mp beanshell mariadb-libs postgresql-libs pstoedit lib{paper,wpg,mythes}
fi
if [ "$virt" == 1 ] || [ "$virt" == 3 ];then
    sudo pacman -S --needed --noconfirm qemu-full edk2-ovmf virt-{manager,viewer} dnsmasq vde2 bridge-utils openbsd-netcat
fi
if [ "$virt" == 2 ] || [ "$virt" == 3 ];then
    sudo pacman -S --needed --noconfirm virtualbox{,-{host-dkms,guest-iso}}
fi
if [ $mtdi == y ];then
    sudo pacman -S --noconfirm --needed lbzip2 pigz
fi
if [ $ply == y ];then
    sudo pacman -S --noconfirm --needed plymouth
fi
#Flatpak
if grep "linux-hardened" <<< $(pacman -Q);then
   sudo pacman -Syu --needed --noconfirm flatpak bubblewrap-suid;else
   sudo pacman -Syu --needed --noconfirm flatpak bubblewrap
fi
if [ $fver == y ];then
    flatpak remote-add --if-not-exists --subset=verified flathub https://flathub.org/repo/flathub.flatpakrepo;else
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

#Games, etc
if [ $games == y ];then
    sudo pacman -Syu --needed --noconfirm wine{,-{gecko,mono}} lutris steam game{scope,mode} lib32-gst-plugins-base vkd3d
    flatpak install -y com.heroicgameslauncher.hgl org.freedesktop.Platform.VulkanLayer.gamescope/x86_64/23.08
fi
if [ "$melonds" == y ];then
    flatpak install -y net.kuribo64.melonDS
fi
if [ "$citra" == y ];then
    flatpak install -y org.citra_emu.citra
fi
if [ "$dolphin" == y ];then
    sudo pacman -S --needed --noconfirm dolphin-emu
fi
if [ "$cemu" == y ];then
    flatpak install -y info.cemu.Cemu
fi
if [ "$switch" == y ];then
    flatpak install -y org.ryujinx.Ryujinx
fi
if [ "$duckstation" == y ];then
    flatpak install -y org.duckstation.DuckStation
fi
if [ "$pcsx2" == y ];then
    flatpak install -y net.pcsx2.PCSX2
fi
if [ "$ppsspp" == y ];then
    flatpak install -y org.ppsspp.PPSSPP
fi
if [ "$rlx" == y ];then
    flatpak install -y org.vinegarhq.Vinegar
fi

if [ "$min" == y ];then
    flatpak install -y org.prismlauncher.PrismLauncher
fi
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
sed -i -e 's/#Clean/Clean/' -i -e 's/#UpgradeMenu/UpgradeMenu/' -i -e 's/#News/News/' .config/paru/paru.conf
if [ "$suas" == y ];then
    sed -i -e 's/#\[bin\]/\[bin\]/' -i -e 's,#Sudo = doas,Sudo = /bin/doas,' .config/paru/paru.conf
fi

if [ $de == 1 ];then
    paru -S archlinux-themes-sddm
fi
if [ "$mkfirm" == y ];then
    paru -S mkinitcpio-firmware
fi
if [ "$makemkv" == y ];then
    paru -S makemkv
    echo "sg" | sudo tee /etc/modules-load.d/sg.conf
fi
#if [ "$32gperf" == y ];then
#    paru -S lib32-gperftools
#fi
if [ "$artix" == y ];then
    sudo pacman -S --needed --noconfirm librewolf;else
    paru -S librewolf-bin
fi

if ! [ $cron == fcron ];then
    if [ "$artix" == y ];then
        sudo pacman -S timeshift;else
        paru -S timeshift
    fi
fi
#Artix Init Services
if [ "$artix" == y ];then
    sudo pacman -S --needed --noconfirm ${dm}-$init ${init}-system cups-$init openntpd-$init ufw-$init power-profiles-daemon-$init avahi-$init apparmor-$init audit-$init rng-tools-$init earlyoom-$init clamav-$init
    if [ "$virt" == 1 ] || [ "$virt" == 3 ];then
       sudo pacman -S libvirt-$init
    fi
    if [ $cron == fcron ];then
       sudo pacman -Rns --noconfirm cronie-$init
       sudo pacman -S --noconfirm fcron-$init;else
       sudo pacman -S --needed --noconfirm $cron
    fi
fi

#Hyprland 
if [ $de == 1 ];then
    sudo pacman -Syu --needed --noconfirm rofi-wayland waybar wlr-randr nwg-look cliphist qt6-wayland pavucontrol nemo{,-{fileroller,share}} catdoc odt2txt poppler libgsf gvfs-{mtp,afc,nfs,smb} ffmpegthumbnailer polkit-kde-agent imv calcurse brightnessctl udiskie wlsunset hypr{land,idle,lock} xdg-desktop-portal-hyprland papirus-icon-theme breeze-{icons,gtk} mako simple-scan gnome-font-viewer okular ttf-noto-nerd
    paru -S --needed wlogout hyprpicker swww qt6ct-kde
    flatpak install -y com.github.tchx84.Flatseal
sudo pacman -Syu --needed --noconfirm rofi-calc
elif [ $de == 2 ];then
    sudo pacman -Syu --needed --noconfirm plasma-meta cryfs flatpak-kcm fwupd packagekit-qt6 xdg-desktop-portal-{kde,gtk} gwenview kimageformats qt6-imageformats dolphin{,-plugins} ffmpegthumbs kde{-{inotify-survey,cli-tools},graphics-thumbnailers,network-filesharing} kio-{admin,fuse,extras} purpose icoutils libappimage openexr perl taglib kmousetool colord-kde kcolorchooser okular ebook-tools spectacle svgpart kcron ark filelight kate kcalc kcharselect kclock kdialog keditbookmarks kweather markdownpart print-manager skanpage tesseract-data-eng maliit-keyboard breeze5
    if [ $ply == y ];then
        sudo pacman -S --noconfirm plymouth-kcm
    fi
fi

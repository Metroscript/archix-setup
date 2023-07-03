# Archix-setup
A setup script with some personal dotfiles to aid you in installing Arch and/or Artix Linux!

# What does the script do?
The script is designed to install Arch/Artix Linux with my custom Hyprland rice, though it also supports KDE-Plasma for testing purposes.
Along with installing software, it includes support for installing a swapfile if you lack swap & adding resume-from-disk/hibernate support, Plus some - to my knowledge; unintrusive security features which should have minimum compatability issues, aside from possible issues with slow hardware as vm.max_map_count is set to the 64 bit integer limit - same a Fedora.

It should be noted that in order for this script to work: you have the 'quiet' kernel parameter enabled, are not using Systemd-Boot (If using Arch), are using mkinitcpio for initramfs generation (Support for others may come later) and have, until you boot into your GUI: Unrestricted sudo/doas privileges (Mainly used for pacman, sed, echoing settings to files, and obtaining disk UUIDs).

# What does install specifically?
__System:__
Pipewire (With noise-suppression-for-voice)
cronie
man-db
wayland + xwayland
cups (With gutenprint & foomatic drivers)
ufw
fuse
ripgrep
fd
bat
lsd
flatpak
apparmor + audit
wl-clipboard
haveged

__Other non-GUI related software:__
yt-dlp
libreoffice
gimp
keepassxc
virt-manager

__Hyprland:__
sddm-git
archlinux-themes-sddm
alacritty
osb
btop
mpv
kdenlive
rhythmbox (Podcast grabber)
lollypop
krita
okular
deluge
blender
cliphist
qt5/6ct
pavucontrol
nemo
polkit-gnome
imv
calcurse
gamescope
brightnessctl
udiskie
gammastep
swayidle
hyprland + desktop portal (duh)
mako
breeze icons & theme
wlogout
rofi + calc mode
waybar
hyprpicker
swww
nwg-look
wlr-randr
grimblast
swaylock-effects
psuinfo

__Optional:__
Steam/Wine
gamemode
Retroarch (Emulation: Includes cores for dolphin, pcsx2, citra, melonds & duckstation)
Prismlauncher
Waydroid
Plymouth
MakeMKV
OpenRGB

__AUR helper:__
paru

__KEEP IN MIND:__ 
GPU driver detection and support is sketchy at best for NVIDIA cards (I guess you'd know that if you're using Linux, heh?), so maybe offer some suggestions or just fix the problems yourself.
I am not familiar with init systems other than openrc & dinit so services for them may need fixing.

# Summary
This script was designed to support the "final installation process" of Arch and/or Artix Linux providing some hardening & personal dotfiles mainly for use in the Hyprland Window Compositor supporting optional installation of game & emulation support through the help of the paru AUR helper. 

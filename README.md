# Archix-setup

A setup script with some personal dotfiles to aid you in installing Arch and/or Artix Linux with the Hyprland Window Compositor or KDE Plasma!

# What does the script do?

The script is designed to install Arch/Artix Linux with my custom Hyprland rice though, I do not use it much any more, but the rice should still function as intended.
Along with installing software, it includes support for installing a swapfile or zram if you lack swap & adding resume-from-disk/hibernate support, Plus some - to my knowledge; unintrusive security features which should have minimum compatability issues, aside from possible issues with slow hardware as vm.max_map_count is set to the 64 bit integer limit -3; same as Fedora.

It should be noted that in order for this script to work: you have the 'quiet' kernel parameter enabled (May change later. I may add quiet with the script if it's not detected), are not using Systemd-Boot (If using Arch), are using mkinitcpio for initramfs generation (Support for others may come later) and have, until you boot into your GUI: Unrestricted sudo/doas privileges (Mainly used for pacman, sed, echoing settings to files, and obtaining disk UUIDs).

# Hardening the system... how?

The script sets multiple sysctl.d parameters, most of which are what you'd find built in to the linux-hardened kernel, activating apparmor & audit that, once rules are made; restricts an apps access what it needs & alerting you if apparmor stops an app from doing sometihing, along with enabling some other kernel parameters that manage memory, enabling ipv6 privacy extentions if networkmanager is installed, changing the machine-id so that it's generic, adding a delay when passwords fail, locking 'su' use to :wheel only, preventing root in ssh & installing the ufw firewall which you can configure to your liking later.


# What does install specifically?

__System:__
Pipewire (With noise-suppression-for-voice),
cronie OR fcron,
man-db,
wayland + xwayland,
cups (With gutenprint & foomatic drivers),
ufw,
fuse,
ripgrep,
fd,
bat,
lsd,
flatpak,
apparmor + audit,
wl-clipboard,
rng-tools (TRNG entropy generation tool).

__Other non-GUI related software:__
yt-dlp,
libreoffice,
gimp,
keepassxc,

__Hyprland:__
sddm-git,
archlinux-themes-sddm,
alacritty,
obs,
btop,
mpv,
kdenlive,
rhythmbox (Podcast grabber),
lollypop,
krita,
okular,
deluge,
blender,
cliphist,
qt5/6ct,
pavucontrol,
nemo,
polkit-gnome,
imv,
calcurse,
gamescope,
brightnessctl,
udiskie,
gammastep,
swayidle,
hyprland + desktop portal (duh),
mako,
breeze icons & theme,
wlogout,
rofi + calc mode,
waybar,
hyprpicker,
swww,
nwg-look,
wlr-randr,
grimblast,
swaylock-effects,
psuinfo.

__Optional:__
Steam/WINE,
gamemode,
Emulation:
    Dolphin,
    PCSX2
    CEMU
    Citra,
    (Some of these will be installed with flatpak)
prismlauncher,
waydroid, 
plymouth,
makeMKV,
virtualbox
virt-manager
openRGB.

__AUR helper:__
paru

__KEEP IN MIND:__
This script does not check or do driver installation for Nvidia cards. You'll have to do that manually before or after using this script.
I am not familiar with init systems other than openrc & dinit so services for s6 or runit may need some changing in their runlevels.

# Summary

This script was designed to support the "final installation process" of Arch and/or Artix Linux providing some hardening & personal dotfiles mainly for use in the Hyprland Window Compositor supporting optional installation of game & emulation support through the help of the paru AUR helper. 

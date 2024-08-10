# Archix-setup

A setup script with some dotfiles to aid you in installing Arch and/or Artix Linux with the Hyprland Window Compositor or KDE Plasma!

## What does the script do?

The script is designed to install Arch/Artix Linux with the KDE Plasma DE or Hyperland WM with my Hyprland rice which I, admittedly, do not use any more, but the rice should still function as intended.
Along with installing software, it includes support for installing a swapfile or zram if you lack swap & adding resume-from-disk/hibernate support, plus some security parameters which should have minimum compatability issues, such as setting vm.max_map_count is set to the 64 bit integer limit -3; same as Fedora.

## Script Requirements
Before using this script, ensure that the arch installation you are planning to use this script with is: Using mkinitcpio for initramfs generation and have sudo/doas privileges.

This script also assumes that the user is not using an Nvidia GPU & that the cloned repo is in $HOME

## Hardening the system... how?

The script sets multiple sysctl.d parameters which are in line with the defaults of the linux-hardened kernel, installing & activating apparmor & audit if requested. Along with this, the NetworkManager IPv6 privacy extentions are enabled if applicable, a delay is set once passwords fail 3 subsequent times, 'su' use is locked to :wheel only & the ufw firewall is installed and enabled with some default rules which you can configure to your liking later.

Apparmor if installed, can be configured with "rules" to restrict an app's access to various files and actions through Madatory Access Control. aa-notify is configured to start on launch of both KDE Plasma and Hyprland which notifies you of any attempts of an app to infringe on the rules you've set.

There is also an option to enable a kernel lockdown setting of your choice during installation.

These modifications aren't perfect or necessarily significant to system security as a whole, but are nice to have and better than nothing.


## What's installed? (Not including dependencies)

### System:
__Video Drivers:__
All Mesa & Vulkan Radeon/Intel drivers depending on detected GPUs

__Sound:__
Pipewire (with all modules & gst plugins), wireplumber & noise-suppression-for-voice,

__Cron:__
cronie OR fcron,

__Display Manager:__
SDDM

__Terminal:__
Alacritty, Kitty OR Wezterm

__Utilities:__
man-db, ripgrep, fd, bat, lsd, smartmontools, btop, nvtop, fastfetch, clamAV

__AUR helper:__
paru

__Other:__
cups (With gutenprint & foomatic drivers), ufw, fuse, flatpak, apparmor + audit, wl-clipboard, TLP (If detected platform is a laptop or notebook)

### Desktop:
__Utilities:__
MPV, yt-dlp, KeepassXC, Qbittorrent, Lollypop, gparted, okular

__KDE Plasma:__
gwenview, dolphin, kcolorchooser, spectacle, ark, filelight, kat, kcalc, kcharselect, kclock, kweather, print-manager, scan-page

__Hyprland:__
rofi-wayland, waybar, nwg-look, cliphist, pavucontrol, nemo, polkit-kde-agent, imv, calcurse, udiskie, wlsunset, hypridle, hyprlock, xdg-desktop-portal-hyprland, mako, simple-scan, swww, gnome-font-viewer, flatseal, archlinux-themes-sddm

### Optional:
__Games:__
Steam/WINE, gamemode, Dolphin, PCSX2, CEMU, Citra, prismlauncher (Some of these will be installed with flatpak)

__Multimedia:__
OBS-Studio, Kdenlive

__Graphics:__
GIMP, Blender

__Office:__
Libreoffice

__Virtualisation:__
virtualbox, Virt-Manager (QEMU)

__Make:__
lbzip2, pigz (Multithreaded alternatives for bzip2 & gzip for faster make decompression)

__Snapshots:__
Snapper, snap-pac, GRUB-BTRFS (Option only given if root partition is BTRFS)

__Other:__
waydroid, plymouth, makeMKV

## KEEP IN MIND:
Init systems other than dinit or runit may not have services configured properly, but it shouldn't impact booting; Change to your liking after completion.

# Summary

This script was designed to support the "final installation process" (That-is, installing all packages after first boot) of Arch and/or Artix Linux, providing some hardening & dotfiles which can be used for the Hyprland Window Compositor or KDE Plasma Desktop Environment; supporting optional installation of game, office, multimedia, graphics & snapshot support. All aided through the help of the paru AUR helper.

# archix-setup
A setup script with some personal dotfiles to aid you in installing Arch and/or Artix Linux!

This script is designed to simplify the "final install process" of Arch, that being: Installing a GUI among other things.

The script is quite simple in terms of installs (Only supporting 2 GUI's), but it comes with some default configuration options for both Hyprland & Plasma, along with including some nice and; to my knowledge, unintrusive security features (aside from the NetworkManager MAC randomisation, that's not fun) which should have minimum compatability issues. Though, if you are having issues with some apps, try changing the value of the unprivileged userns setting in the kernel-hardening file in sysctl.d.

It should be noted that this script assumes that: You have no current loglevel kernel parameter (one will be added & I do not know if having 2 causes problems), you've the 'quiet' kernel parameter, you have the standard linux kernel installed (Especially if you are using systemd boot) & you are fine with paru as an AUR helper.

KEEP IN MIND: gpu driver detection and support is sketchy at best for NVIDIA cards (I guess you'd know that if you're using Linux, heh?), so maybe offer some suggestions or just fix the problems yourself.

To summarise:
This script was designed to support the "final installation process" of Arch and/or Artix Linux providing some hardening & personal dotfiles mainly for use in the Hyprland Window Compositor. 

#SET EDITOR#
if grep -E neovim <<< $(pacman -Q neovim);then
    alias vim='nvim'
elif grep -E nano <<< $(pacman -Q nano);then
    alias vim='nano'
fi

if grep -E "Artix" <<< $(cat /etc/issue);then
    artix=y
    sed -i -e 's/#exec-once/exec-once/' -i -e '/--systemd/d' -i -e '/systemctl/d' ${repo}dotfiles/hypr-rice/hypr/hyprland.conf
    sed -i -e 's/action" : "reboot/action" : "loginctl reboot/' -i -e 's/poweroff/loginctl poweroff/' -i -e 's/action" : "suspend/action" : "loginctl suspend/' ${repo}dotfiles/hypr-rice/wlogout/layout
    if grep -E openrc <<< $(pacman -Q openrc);then
        init=openrc
    elif grep -E runit <<< $(pacman -Q runit);then
        init=runit
    elif grep -E s6-base <<< $(pacman -Q s6-base);then
        init=s6
    elif grep -E dinit <<< $(pacman -Q dinit);then
        init=dinit
    fi;else
    artix=n
    if grep -E grub <<< $(pacman -Q grub);then
        grub=y;else
        grub=n
    fi
fi

if grep -E opendoas <<< $(pacman -Q opendoas);then
    suas=y
    alias sudo='doas'
    sed -i "/stuff/a alias sudo='doas'" ${repo}dotfiles/bashrc
    echo -e "SudoLoop is enabled on paru, when tweaking doas.conf, put 'permit persist :wheel as root cmd true' so SudoLoop works\nYou should make any changes & run 'chmod 0400 /etc/doas.conf' as root after install"
    sleep 5
    ###################################################
    ######### MORE PERMS FOR INIT COMMANDS? ###########
    ###################################################
#    doasconf() {
#        if [ $artix == y ];then
#            if [ $init == dinit ];then
#                echo -e "permit persist :wheel as root cmd pacman\npermit nopass :wheel as root cmd pacman args -Syu\npermit nopass :wheel as root cmd pacman args -Sc\npermit persist :wheel as root cmd downgrade\npermit persist :wheel as root cmd sensors-detect\npermit nopass :wheel as root cmd smartctl\npermit persist :wheel as root cmd reflector\npermit persist :wheel as root cmd dinit\npermit persist :wheel as root cmd dinitcheck\npermit persist :wheel as root cmd dinitctl"
#           elif [ $init == runit ];then
#                echo -e "permit persist :wheel as root cmd pacman\npermit nopass :wheel as root cmd pacman args -Syu\npermit nopass :wheel as root cmd pacman args -Sc\npermit persist :wheel as root cmd downgrade\npermit persist :wheel as root cmd sensors-detect\npermit nopass :wheel as root cmd smartctl\npermit persist :wheel as root cmd reflector\npermit persist :wheel as root cmd sv"
#            elif [ $init == openrc ];then
#                echo -e "permit persist :wheel as root cmd pacman\npermit nopass :wheel as root cmd pacman args -Syu\npermit nopass :wheel as root cmd pacman args -Sc\npermit persist :wheel as root cmd downgrade\npermit persist :wheel as root cmd sensors-detect\npermit nopass :wheel as root cmd smartctl\npermit persist :wheel as root cmd reflector\npermit persist :wheel as root cmd openrc\npermit persist :wheel as root cmd rc-update\npermit persist :wheel as root cmd rc-update\npermit persist :wheel as root cmd rc-status"
#            elif [ $init == s6 ];then
#                echo -e "permit persist :wheel as root cmd pacman\npermit nopass :wheel as root cmd pacman args -Syu\npermit nopass :wheel as root cmd pacman args -Sc\npermit persist :wheel as root cmd downgrade\npermit persist :wheel as root cmd sensors-detect\npermit nopass :wheel as root cmd smartctl\npermit persist :wheel as root cmd reflector\npermit persist :wheel as root cmd s6-db-reload\n permit persist :wheel as root cmd s6-rc"
#            fi
#        else
#            echo -e "permit persist :wheel as root cmd pacman\npermit nopass :wheel as root cmd pacman args -Syu\npermit nopass :wheel as root cmd pacman args -Sc\npermit persist :wheel as root cmd downgrade\npermit persist :wheel as root cmd sensors-detect\npermit nopass :wheel as root cmd smartctl\npermit persist :wheel as root cmd reflector\npermit persist :wheel as root cmd systemctl"
#        fi
#    }
    ###################################################
    ############### END OF PROBLEM AREA ###############
    ###################################################
#    echo "----------------------------------------------------------------"
#    doasconf
#    echo "----------------------------------------------------------------"
#    printf "Use a custom (More secure) doas.conf? This is what it'll look like ^^^^^^^ [y/n]: "
#    read doch
#    until [ $doch == y ] || [ $doch == n ];do
#    echo "Sorry, please try again."
#    doasconf
#    printf "Use a custom (More secure) doas.conf? This is what it'll look like ^^^^^^^ [y/n]: "
#    read doch
#    done;else
    suas=n
fi

#############################################################################
################## HAVE SOMETHING OTHER THAN KDE OR HYPRLAND WORK ###########
#############################################################################
echo "Which DE/WM would you like to install? 1.Hyprland, 2.KDE Plasma or 3.Gnome (doesn't install properly)"
# 4.Cinnamon 5.MATE" #or 6.A WM?"
printf "[1/2/3]: "
read de
until [ $de == 1 ] || [ $de == 2 ] || [ $de == 3 ];do
    # [ $de == 4 ] || [ $de == 5 ];do #|| [ $de == 6 ];do
    echo "Please try again. Which DE/WM would you like to install? 1.Hyprland, 2.KDE Plasma, 3.Gnome (doesn't install properly)"
    #4.Cinnamon, 5.MATE"#or 6.A WM?"
    printf "[1/2/3]: "
    read de
done
if [ $de == 1 ] || [ $de == 2 ];then
    dm=sddm
elif [ $de == 3 ];then
    dm=gdm
fi
############################################################################
####################### END OF PROBLEM AREA ################################
############################################################################
############################################################################
######################## ADD WM SUPPORT ####################################
############################################################################
#if [ $de == 7 ];then
#    echo "Would you like a 1.Wayland or 2.X11 based WM?"
#    printf "[1/2]: "
#    read wmtype
#    until [ $wmtype == 1 ] || [ $wmtype == 2 ];do
#        echo "Sorry, please try again. Would you like a 1.Wayland or 2.X11 based WM?"
#        printf "[1/2]: "
#        read wmtype
#    done
#    if [ $wmtype == 1 ];then
#        echo "Would you like 1.Hyprland, 2.Sway, 3.River, 4.Wayfire, 5.DWL?"
#        printf "[1/2/3/4/5]: "
#        read wm
#        until [ $wm == 1 ] || [ $wm == 2 ] || [ $wm == 3 ] || [ $wm == 4 ] || [ $wm == 5 ];do
#            echo "Sorry, please try again. Would you like 1.Hyprland, 2.Sway, 3.River, 4.Wayfire, 5.DWL?"
#            printf "[1/2/3/4/5]: "
#            read wm
#        done
#    elif [ $wmtype == 2 ];then
#        echo "Would you like 1.AwesomeWM, 2.DWM, 3.i3, or 4.BSPWM?"
#        printf "[1/2/3/4]: "
#        read xwm
#        until [ $xwm == 1 ] || [ $xwm == 2 ] || [ $xwm == 3 ] || [ $xwm == 4 ];do
#            echo "Sorry, please try again. Would you like 1.AwesomeWM, 2.DWM, 3.i3, or 4.BSPWM?"
#           printf "[1/2/3/4]: "
#           read xwm
#        done
#    fi
#fi
    ############################################################################
    ###################### END OF PROBLEM AREA ##################################
    #############################################################################

printf "Use precompiled AUR binaries where availiable? [y/n]: "
read bin
until [ $bin == y ] || [ $bin == n ];do
  echo "Sorry, please try again."
  printf "Use precompiled binaries where availiable? [y/n]: "
  read bin
done

printf "Install Emulation & Steam/WINE support? [y/n]: "
read gayms
until [ $gayms == y ] || [ $gayms == n ];do
    echo "Sorry, please try again"
    printf "Install Emulation & Steam/WINE support? [y/n]: "
    read gayms
done
if [ $gayms == y ];then
    printf "Install Grapejuice? (A WINE wrapper for Roblox) [y/n]: "
    read rlx
    until [ $rlx == y ] || [ $rlx == n ];do
        echo "Sorry, please try again"
        printf "Install Grapejuice? (A WINE wrapper for Roblox) [y/n]: "
        read rlx
    done
    printf "Install Prismlauncher? (A custom Minecraft launcher with mod support) [y/n]: "
    read min
    until [ $min == y ] || [ $min == n ];do
        echo "Sorry, please try again."
        printf "Install Prismlauncher? (A custom Minecraft launcher with mod support) [y/n]: "
        read min
    done
    if [ $de == 1 ] || [ $de == 2 ] || [ $de == 3 ];then
        printf "Install WayDroid? (An Android emulator that exclusively runs on Wayland) [y/n]: "
        read waydroid
        until [ $waydroid == y ] || [ $waydroid == n ];do
            echo "Sorry, please try again."
            printf "Install WayDroid? (An Android emulator that exclusively runs on Wayland) [y/n]: "
            read waydroid
    done
    fi
fi

echo "Swapfile size. 2048Mib is usually a good choice. Put '0' for no swapfile."
printf "Size of swapfile in Mib: "
read swap
until [ $swap -ge 0 ];do
    echo "Sorry, please try again."
    echo "Swapfile size. 2048Mib is usually a good choice. Put '0' for no swapfile."
    printf "Size of swapfile in Mib: "
    read swap
done

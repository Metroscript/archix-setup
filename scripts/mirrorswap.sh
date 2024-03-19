#Repo config + doas base-devel packages
if [ "$artix" == y ];then
    sudo sed -i -z -e 's,\[galaxy\]\nInclude = /etc/pacman.d/mirrorlist,\[galaxy\]\nInclude = /etc/pacman.d/mirrorlist\n\n\[universe\]\nServer = https://universe.artixlinux.org/$arch\nServer = https://mirror1.artixlinux.org/universe/$arch\nServer = https://mirror.pascalpuffke.de/artix-universe/$arch\nServer = https://mirrors.qontinuum.space/artixlinux-universe/$arch\nServer = https://mirror1.cl.netactuate.com/artix/universe/$arch\nServer = https://ftp.crifo.org/artix-universe/$arch\nServer = https://artix.sakamoto.pl/universe/$arch,' -i -z -e 's,\[lib32\]\n#Include = /etc/pacman.d/mirrorlist,\[lib32\]\n#Include = /etc/pacman.d/mirrorlist\n\n#Arch Repos\n\n#\[extra-testing\]\n#Include = /etc/pacman.d/mirrorlist-arch\n\n#\[extra\]\n#Include = /etc/pacman.d/mirrorlist-arch\n\n#\[multilib-testing\]\n#Include = /etc/pacman.d/mirrorlist-arch\n\n#\[multilib\]\n#Include = /etc/pacman.d/mirrorlist-arch,' /etc/pacman.conf
    sudo pacman -Syu --needed --noconfirm artix-archlinux-support
    sudo sed -i -e "/\[lib32\]/,/Include/"'s/^#//' -i -e "/\[extra\]/,/Include/"'s/^#//' /etc/pacman.conf
    sudo pacman-key --populate
fi
    sudo sed -i -e 's/#Color/Color/' -i -e '/Color/a ILoveCandy' -i -e 's/#Verbose/Verbose/' -i -e 's/#Parallel/Parallel/' -i -e "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
sudo pacman -Syu --needed --noconfirm base-devel
if [ "$suas" == y ];then
    sudo pacman -R --noconfirm base-devel
    sudo pacman -Rns --noconfirm sudo
fi
tz=$(curl https://ipapi.co/timezone)
if [ $reflect == y ];then
    sudo pacman -Syu --needed --noconfirm reflector rsync neovim
    country=$(curl https://ipapi.co/timezone | cut -d/ -f1)
    if [ "$artix" == y ];then
        sudo mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.pacnew
        rankmirrors /etc/pacman.d/mirrorlist.pacnew | sudo tee /etc/pacman.d/mirrorlist
        sudo reflector --save /etc/pacman.d/mirrorlist-arch --sort rate -c $country -p https;else
        sudo reflector --save /etc/pacman.d/mirrorlist --sort rate -c $country -p https
    fi
    echo 'Server = https://geo.mirror.pkgbuild.com/$repo/os/$arch' | sudo tee -a /etc/pacman.d/mirrorlist
    sudo nvim /etc/pacman.d/mirrorlist
fi
sudo pacman -Syu --noconfirm --needed pacman-contrib pkgfile
sudo pkgfile -uz "zstd -T0 -19"

if [ "$btrfs" == y ];then
   sudo pacman -Syu --needed --noconfirm grub-btrfs inotify-tools btrfs-progs
    if [ "$snap" == y ];then
        if [ "$snap_dir" == y ];then
            sudo umount /.snapshots
            sudo rm -rf /.snapshots
            sudo sed -i '/.snapshots/d' /etc/fstab
        fi
        sudo pacman -S --needed --noconfirm snapper
        sh ~/archix-setup/snapper_conf_gen.sh
        if [ $img == mkinit ];then
            sudo sed -i 's/fsck/fsck grub-btrfs-overlayfs/g' /etc/mkinitcpio.conf
            sudo mkinitcpio -P
        fi
    fi
fi

#Make Swapfile
if [ "$swap" -gt 0 ];then
    if [ "$btrfs" == y ];then
        cd /
        sudo btrfs subvolume create ${swapvol}
        sudo btrfs filesystem mkswapfile --size ${swap}G --uuid clear ${swapvol}/swapfile
        sudo swapon ${swapvol}/swapfile
        sudo cp /etc/fstab /etc/fstab.bak
        echo '/${swapvol}/swapfile none swap defaults 0 0' | sudo tee -a /etc/fstab
        cd;else
        sudo dd if=/dev/zero of=/.swapfile bs=1M count=$((${swap}*1024)) status=progress
        sudo chmod 600 /.swapfile
        sudo mkswap -U clear /.swapfile
        sudo cp /etc/fstab /etc/fstab.bak
        echo '/.swapfile none swap defaults 0 0' | sudo tee -a /etc/fstab
        sudo mount -a
        sudo swapon -a
    fi
    if [ $res == y ];then
        sudo sed -i "s.quiet.resume=$(cat /etc/fstab | grep '/ ' | cut -d/ -f1 | awk '{$1=$1};1') resume_offset=$(if [ "$btrfs" == y ];then sudo btrfs inspect-internal map-swapfile -r /${swapvol}/swapfile;else sudo filefrag -v /.swapfile | awk '$1=="0:" {print substr($4, 1, length($4)-2)}';fi) quiet." $bootdir
    fi
        if [ $img == mkinit ];then
            sudo sed -i 's/filesystems/filesystems resume/' /etc/mkinitcpio.conf
            sudo mkinitcpio -P
        ###############################################
        ####### OTHER INITRAMFS GEN SUPPORT ###########
        ###############################################
        #elif [ $img == dracut ];then
        #    sudo sh -c 'echo add_dracutmodules+=\" resume \" > /etc/dracut.conf.d/resume.conf'
        #    sudo dracut-rebuild #;else
            #BOOSTER STUFF HERE
            #sudo booster build
        fi
        if ! grep 'sleep.conf.d' <<< $(ls $sdir);then
            sudo mkdir ${sdir}sleep.conf.d
        fi
        echo -e '[Sleep]\nHibernateDelaySec=60min\nHibernateMode=shutdown' | sudo tee ${sdir}sleep.conf.d/99-Hibernate-Mode-and-Delay.conf
        if [ $de == 1 ];then
            sed -i "s/ctl suspend/ctl suspend-then-hibernate \|\| $(if [ "$artix" == y ];then echo loginctl;else echo systemctl;fi) suspend/" ${repo}dotfiles/hypr-rice/wlogout/layout
        fi
fi

if [ "$zram" -gt 0 ];then
    echo 'zram' | sudo tee /etc/modules-load.d/zram.conf
    echo 'options zram num_devices=1' | sudo tee /etc/modprobe.d/zram.conf
    echo ACTION==\"add\", KERNEL==\"zram0\", ATTR{comp_algorithm}=\"${zramcomp}\", ATTR{disksize}=\"${zram}G\", RUN=\"/usr/bin/mkswap -U clear /dev/zram0\" | sudo tee /etc/udev/rules.d/99-zram.rules
    sudo sed -i 's;quiet;zswap.enabled=0 quiet;' /etc/default/grub
    echo '/dev/zram0 none swap defaults,pri=100 0 0' | sudo tee -a /etc/fstab
fi
if grep nvme <<< $(lsblk) && ! grep nvme_load <<< $(cat $bootdir);then
    sudo sed -i 's/quiet/nvme_load=YES quiet/' $bootdir
fi

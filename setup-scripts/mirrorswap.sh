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
sudo pacman -Syu --needed --noconfirm reflector rsync pacman-contrib pkgfile
tz=$(curl https://ipapi.co/timezone)
country=$(curl https://ipapi.co/timezone | cut -d/ -f1)
if [ "$artix" == y ];then
    sudo mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.pacnew
    sudo sh -c "rankmirrors /etc/pacman.d/mirrorlist.pacnew > /etc/pacman.d/mirrorlist"
    sudo reflector --save /etc/pacman.d/mirrorlist-arch --sort rate -c $country -p https;else
    sudo reflector --save /etc/pacman.d/mirrorlist --sort rate -c $country -p https
fi
sudo pacman -Sy
sudo pkgfile -uz "zstd --ultra -22 -T0"

#Make Swapfile
if [ $swap -gt 0 ];then
    sudo dd if=/dev/zero of=/swapfile bs=1M count=$swap status=progress
    sudo chmod 600 /swapfile
    sudo mkswap -U clear /swapfile
    sudo cp /etc/fstab /etc/fstab.bak
    sudo echo '/swapfile none swap defaults 0 0' | sudo tee -a /etc/fstab
    sudo mount -a
    sudo swapon -a
    if [ $res == y ];then
        sudo sed -i "s;quiet;resume=$(sudo lsblk -oUUID,MOUNTPOINT -P -M | grep \"/\" | cut -d\  -f1 | sed 's/\"//g') resume_offset=$(sudo filefrag -v /swapfile | awk '$1=="0:" {print substr($4, 1, length($4)-2)}') quiet;" $bootdir
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
        sudo sh -c "echo '\[Sleep\]\nHibernateDelaySec=60min' > ${sdir}sleep.conf.d/99-Hibernate-Sec.conf"
        sudo sh -c "echo -e '\[Sleep\]\nHibernateMode=shutdown' > ${sdir}sleep.conf.d/99-Hibernate-Mode.conf"
        if [ $de == 1 ];then
            sed -i "s/ctl suspend/ctl suspend-then-hibernate \|\| $(if [ "$artix" == y ];then echo loginctl;else echo systemctl;fi) suspend/" ${repo}dotfiles/hypr-rice/wlogout/layout
        fi
    fi
fi
if grep nvme <<< $(lsblk) && ! grep nvme_load <<< $(cat $bootdir);then
    sudo sed -i 's/quiet/nvme_load=YES quiet/' $bootdir
fi

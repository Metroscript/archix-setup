if [ $artix == y ];then
    sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.pacnew
    sudo rankmirrors /etc/pacman.d/mirrorlist.pacnew > /etc/pacman.d/mirrorlist
    countr=$(cat /etc/timezone)
    #####################################
    ### ADD SUPPORT FOR MORE COUNTRIES ##
    #####################################
    if grep -E "Australia" <<< ${countr};then
        country=Australia
    elif grep -E "Canada" <<< ${countr};then
        country=Canada
    elif grep -E "France" <<< ${countr};then
        country=France
    elif grep -E "Germany" <<< ${countr};then
        country=Germany
    elif grep -E "US" <<< ${countr};then
        country=US
    elif grep -E "Mexico" <<< ${countr};then
        country=Mexico
    elif grep -E "Chile" <<< ${countr};then
        country=Chile
    elif grep -E "Japan" <<< ${countr};then
        country=Japan
    elif grep -E "China" <<< ${countr};then
        country=China
    elif grep -E "America" <<< ${countr};then
        country=America
    fi
    ###################################
    ######## END OF PROBLEM AREA ######
    ###################################
    sudo reflector --save /etc/pacman.d/mirrorlist-arch --sort rate -c ${country} -p https,rsync;else
    sudo reflector --save /etc/pacman.d/mirrorlist --sort rate -c ${country} -p https,rsync
fi

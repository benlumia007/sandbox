#!/bin/bash

# noroot
#
# noroot allows provision scripts to be run as the default user "vagrant" rather than the root
# since provision scripts are run with root privileges.
noroot() {
    sudo -EH -u "vagrant" "$@";
}

if [[ ! -f /etc/apt/trusted.gpg.d/git-core_ubuntu_ppa.gpg ]]; then
    add-apt-repository ppa:git-core/ppa -y
fi

if [[ ! -f /etc/apt/trusted.gpg.d/ondrej_ubuntu_php.gpg ]]; then
    add-apt-repository ppa:ondrej/php -y
fi

if [[ ! -f /usr/sbin/nginx ]]; then
    apt-get install nginx -y
fi

if [[ ! -f /etc/init.d/mysql ]]; then
    apt-get install mysql-server -y
    sleep 5
    wget https://gist.githubusercontent.com/benlumia007/7757887af3c5e79744e283cf5eddd8e0/raw/57bfbab11a84b99cad4a85fa2ff555ee4ab8811f/.my.cnf
    chmod 0775 .my.cnf
    mysql -uroot -proot -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH 'mysql_native_password' BY 'root';"
    mysql -uroot -proot -e "FLUSH PRIVILEGES;"
fi

exit 1

# xdebug
#
# when you run this script, while the xdebug is set to true, it will then enable xdebug, with
# no configs, this is something that you as a user needs to be configure the way you want it
# to work. xdebug is set to false by default.
if [[ -f "/etc/php/7.4/mods-available/xdebug.ini" ]]; then
    /srv/config/bin/xdebug
fi

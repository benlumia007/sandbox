#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# MySQL Configuration
if [[ ! -f "/var/log/mysql/slow.log" ]]; then
    echo "copy /srv/config/mysql/my.cnf   /etc/mysql/my.cnf"
    cp "/srv/config/mysql/my.cnf" "/etc/mysql/my.cnf"
else
    echo "my.cnf has been copied and configured."
fi

if [[ ! -f "/etc/php/7.2/mods-available/php-custom.ini" ]]; then
    echo "copy /srv/config/php/php-custom.ini   /etc/php/7.2/mods-available/php-custom.ini"
    cp "/srv/config/php/php-custom.ini" "/etc/php/7.2/mods-available/php-custom.ini"
    phpenmod php-custom
else
    echo "php-custom.ini has been configured and enabled."
fi

if [[ ! -f "/lib/systemd/system/mailcatcher.service" ]]; then
    echo "copy /srv/config/mailcatcher/mailcatcher.service   /lib/systemd/system/mailcatcher.service"
    cp "/srv/config/mailcatcher/mailcatcher.service" "/lib/systemd/system/mailcatcher.service"
    echo "starting mailcatcher at startup"
    systemctl enable mailcatcher
    systemctl start mailcatcher
else
    echo "mailcatcher.service has already been configured."
fi

if [[ ! -f "/etc/php/7.2/mods-available/mailcatcher.ini" ]]; then
    echo "copy /srv/config/mailcatcher/mailcatcher.ini   /etc/php/7.2/mods-available/mailcatcher.ini"
    cp "/srv/config/mailcatcher/mailcatcher.ini" "/etc/php/7.2/mods-available/mailcatcher.ini"
    echo "php module mailcatcher enabled"
    phpenmod mailcatcher
    echo "restarting apache server"
    service apache2 restart
fi

a2enmod ssl headers rewrite
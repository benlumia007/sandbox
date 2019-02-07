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
#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

noroot() {
  sudo -EH -u "vagrant" "$@";
}

# MySQL Configuration
if [[ ! -f "/srv/log/mysql/slow.log" ]]; then
    echo "copy /srv/config/mysql/my.cnf   /etc/mysql/my.cnf"
    cp "/srv/config/mysql/my.cnf" "/etc/mysql/my.cnf"
    echo "restarting mysql server"
    service mysql restart
    mkdir -p "/srv/log/mysql"
    touch "/srv/log/mysql/slow.log"
else
    echo "my.cnf has been copied and configured."
fi

if [[ ! -f "/etc/php/7.2/mods-available/php-custom.ini" ]]; then
    echo "copy /srv/config/php/php-custom.ini   /etc/php/7.2/mods-available/php-custom.ini"
    cp "/srv/config/php/php-custom.ini" "/etc/php/7.2/mods-available/php-custom.ini"
    phpenmod php-custom
    mkdir -p "/srv/log/php"
    touch "/srv/log/php/php_errors.log"
    echo "restarting apache server"
    service apache2 restart
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

if [[ ! -d "/vagrant/certificates/ca" ]]; then
    noroot mkdir -p "/vagrant/certificates/ca"
    noroot openssl genrsa -out "/vagrant/certificates/ca/ca.key" 4096
    noroot openssl req -x509 -new -nodes -key "/vagrant/certificates/ca/ca.key" -sha256 -days 3650 -out "/vagrant/certificates/ca/ca.crt" -subj "/CN=Sandbox Internal CA"
    a2enmod ssl headers rewrite
else
    echo "a root certificate of ca has been generated."
fi
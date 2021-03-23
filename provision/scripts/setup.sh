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

if [[ ! -f /usr/bin/zip ]]; then
    apt-get install \
        curl \
        gettext \
        g++ \
        git \
        git-lfs \
        git-svn \
        graphviz \
        imagemagick \
        make \
        memcached \
        ngrep \
        ntp \
        python3-pip \
        subversion \
        unzip \
        zip \
        -y;
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

if [[ ! -f /usr/bin/php7.4 ]]; then
    apt-get install \
        php-imagick \
        php-memcache \
        php-memcached \
        php-pear \
        php-ssh2 \
        php-yaml \
        php7.4-bcmath \
        php7.4-cli \
        php7.4-common \
        php7.4-curl \
        php7.4-dev \
        php7.4-fpm \
        php7.4-gd \
        php7.4-imap \
        php7.4-json \
        php7.4-mbstring \
        php7.4-mysql \
        php7.4-soap \
        php7.4-sqlite3 \
        php7.4-xml \
        php7.4-zip \
        -y
fi

if [[ ! -f /usr/local/bin/shyaml ]]; then
    sudo -H pip3 install shyaml
fi

if [[ ! -f /usr/bin/npm ]]; then
    curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash -
    apt-get install nodejs -y
fi

if [[ ! -f /usr/local/bin/composer ]]; then
    noroot wget -q https://getcomposer.org/download/2.0.4/composer.phar
    noroot chmod +x composer.phar
    mv composer.phar /usr/local/bin/composer
fi

if [[ ! -f /usr/local/bin/mailhog ]]; then
    curl --silent -L -o /usr/local/bin/mailhog https://github.com/mailhog/MailHog/releases/download/v1.0.1/MailHog_linux_amd64
    chmod +x /usr/local/bin/mailhog

    curl --silent -L -o /usr/local/bin/mhsendmail https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_amd64
    chmod +x /usr/local/bin/mhsendmail

    wget -q -P /lib/systemd/system https://gist.githubusercontent.com/benlumia007/4648124b5ccc8b7b5b64c0a78104c4f0/raw/f514ebc2aac1ad975ebb9c556436e2a7b0f523c2/mailhog.service
    systemctl enable mailhog
    systemctl start mailhog

    wget -q -P /etc/php/7.4/mods-available https://gist.githubusercontent.com/benlumia007/5d13c52bd300a9234077978c075c4ff3/raw/c0d46366d62d6894f876993c21e2f416b252e596/mailhog.ini
    phpenmod mailhog
    systemctl restart nginx
fi

if [[ ! -f /etc/php/7.4/mods-available ]]; then
    wget -q -P /etc/php/7.4/mods-available https://gist.githubusercontent.com/benlumia007/11eb65c4241b9efb2af337ca69c7f037/raw/bfeadd6335e85b5ba5ab05985623cd13ce45e033/php-custom.ini
    phpenmod php-custom
    systemctl restart nginx
fi

if [[ ! -f /usr/local/bin/wp ]]; then
    noroot curl -s -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    noroot chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
fi

# xdebug
#
# when you run this script, while the xdebug is set to true, it will then enable xdebug, with
# no configs, this is something that you as a user needs to be configure the way you want it
# to work. xdebug is set to false by default.
# if [[ -f "/etc/php/7.4/mods-available/xdebug.ini" ]]; then
#    /srv/config/bin/xdebug
# fi

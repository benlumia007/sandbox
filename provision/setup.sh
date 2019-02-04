#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# Check for updates
apt-get update
apt-get upgrade -y

apt_install=(
    software-properties-common

    # Install LAMP Stack
    apache2
    mysql-server
    php7.2

    # Install Additional PHP Modules
    php7.2-cli
    php7.2-common
    php7.2-curl
    php7.2-dev
    php7.2-gd
    php7.2-intl
    php7.2-mbstring
    php7.2-mysql
    php7.2-sqlite3
    php7.2-xml

    # Install ruby and sqlite3-dev
    libsqlite3-dev
    ruby-dev

    # Useful tools
    curl
    dos2unix
    git
    make
    python-pip
    subversion
    unzip
    zip
)

# Install required packages
echo "Installing apt-get packages..."
if ! apt-get -y -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confnew install --fix-missing --fix-broken ${apt_install[@]}; then
    apt-get clean
return 1
fi

# Install Mailcatcher
echo "Installing Mailcatcher"
gem install mailcatcher

# Install Shyaml
echo "Installing Shyaml"
pip install shyaml

# MySQL Configuration
if [[ ! -f /home/vagrant/.my.cnf ]]; then
    echo "Copying /srv/config/mysql/.my.cnf     /home/vagrant/.my.cnf"
    cp "/srv/config/mysql/.my.cnf" "/home/vagrant/.my.cnf"

    chmod 0755 /home/vagrant/.my.cnf

    mysql -u root -proot -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH 'mysql_native_password' BY 'root';"
    mysql -u root -proot -e "FLUSH PRIVILEGES;"
else
    echo ".my.cnf is already been configured"
fi
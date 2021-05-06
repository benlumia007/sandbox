#!/bin/bash

noroot() {
    sudo -EH -u "vagrant" "$@";
}

# Add Git Repository for Latest Version.
sudo add-apt-repository ppa:git-core/ppa -y;

# Add NPM/Nodejs
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -

# Update the package list
sudo apt-get update -y;

# Upgrade all installed packages including kernel and kernel header
sudo apt-get upgrade -y;

sudo apt-get install php-imagick php-memcache php-memcached php-pear php-ssh2 php-yaml -y;

sudo apt-get install php7.4-bcmath php7.4-cli php7.4-common php7.4-curl php7.4-dev php7.4-gd php7.4-imagick php7.4-imap php7.4-json php7.4-mbstring php7.4-mysql php7.4-soap php7.4-sqlite3 php7.4-xml php7.4-zip -y;

sudo apt-get install apache2 -y
sudo apt-get install mysql-server -y

sudo apt-get install libapache2-mod-php7.4 curl gettext g++ git git-lfs git-svn graphviz imagemagick make memcached ngrep nodejs ntp python3-pip subversion unzip zip -y;
sudo -H pip3 install shyaml;

sudo wget https://gist.githubusercontent.com/benlumia007/7757887af3c5e79744e283cf5eddd8e0/raw/57bfbab11a84b99cad4a85fa2ff555ee4ab8811f/.my.cnf;
sudo chmod 0775 .my.cnf;

sudo mysql -uroot -proot -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH 'mysql_native_password' BY 'root';";
sudo mysql -uroot -proot -e "FLUSH PRIVILEGES;";

cd /etc/mysql;
sudo rm mysql.cnf;
sudo wget https://gist.githubusercontent.com/benlumia007/4cf33e9adf7b296e796ff4071e377864/raw/ed03788a444e215c2186bca1f94f3fb749a627e6/mysql.cnf;
sudo systemctl restart mysql;

cd /var/log/mysql;
sudo chgrp adm slow.log;

sudo curl --silent -L -o /usr/local/bin/mailhog https://github.com/mailhog/MailHog/releases/download/v1.0.1/MailHog_linux_amd64
sudo chmod +x /usr/local/bin/mailhog
sudo curl --silent -L -o /usr/local/bin/mhsendmail https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_amd64
sudo chmod +x /usr/local/bin/mhsendmail

cd /lib/systemd/system
sudo wget https://gist.githubusercontent.com/benlumia007/4648124b5ccc8b7b5b64c0a78104c4f0/raw/f514ebc2aac1ad975ebb9c556436e2a7b0f523c2/mailhog.service
sudo systemctl enable mailhog
sudo systemctl start mailhog

cd /etc/php/7.4/mods-available
sudo wget https://gist.githubusercontent.com/benlumia007/5d13c52bd300a9234077978c075c4ff3/raw/c0d46366d62d6894f876993c21e2f416b252e596/mailhog.ini
sudo phpenmod mailhog
sudo systemctl restart apache2

wget https://getcomposer.org/download/2.0.4/composer.phar
chmod +x composer.phar
mv composer.phar /usr/local/bin/composer

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

a2enmod ssl rewrite

#!/bin/bash

noroot() {
    sudo -EH -u "vagrant" "$@";
}

if [[ ! -d "/srv/www/dashboard/public_html/phpmyadmin" ]]; then
    echo "creating folder phpmyadmin"
    mkdir -p "/srv/www/dashboard/public_html/phpmyadmin"
    cd "/srv/www/dashboard/public_html/phpmyadmin"
    echo "extracting phpMyAdmin-4.8.5-all-languages"
    wget https://files.phpmyadmin.net/phpMyAdmin/4.8.5/phpMyAdmin-4.8.5-all-languages.zip -O phpmyadmin.zip
    unzip phpmyadmin.zip -d "/srv/www/dashboard/public_html/phpmyadmin"
    mv phpMyAdmin-4.8.5-all-languages/* "/srv/www/dashboard/public_html/phpmyadmin"
    rm -rf phpMyAdmin-4.8.5-all-languages
    rm phpmyadmin.zip
else
    echo "phpmyadmin already installed."
fi
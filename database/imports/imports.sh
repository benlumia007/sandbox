#!/bin/bash

sandbox_config=/vagrant/sandbox-custom.yml

db_restores=`cat ${sandbox_config} | shyaml get-value options.db_restores 2> /dev/null`

get_sites() {
    local value=`cat ${sandbox_config} | shyaml keys sites 2> /dev/null`
    echo ${value:-$@}
}

noroot() {
    sudo -EH -u "vagrant" "$@";
}

if [[ $db_restores != "False" ]]; then
    for domain in `get_sites`
    do 
        sql=*.sql
        cd "/srv/database/backups"

        for data in $sql
        do
            noroot mysql -u root -e "CREATE DATABASE IF NOT EXISTS $domain"
            noroot mysql -u root -e "GRANT ALL PRIVILEGES ON $domain.* TO 'wp'@'localhost';"
            noroot mysql -u root "$domain" < "$data"
            echo "restored $domain success"
        done
    done
fi
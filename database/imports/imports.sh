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

if [[ $db_restores == "False"  ]]; then
    echo "skipping database importing..."
    exit;
fi

cd /srv/database/backups/

count=`ls -1 *.sql 2>/dev/null | wc -l`

if [[ $count != 0 ]]; then
    for file in $( ls *.sql )
    do
        domain=${file%%.sql}

        database=`noroot mysql -u root --skip-column-names -e "SHOW TABLES FROM $domain"`
		if [ "" == "$database" ]
		then
            noroot mysql -u root -e "CREATE DATABASE IF NOT EXISTS $domain"

			noroot mysql -u root $domain < $domain.sql
		else
			echo "$domain has been imported successfully."
		fi

    done
fi
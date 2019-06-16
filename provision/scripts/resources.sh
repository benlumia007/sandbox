#!/usr/bin/env bash

# variables
#
# name = name of the resource that's been used.
# dir = where the resources going to be downloaded to.
name=$2
dir="/srv/provision/resources/${name}"

date=`cat /vagrant/provisioning_at`
folder="/var/log/provision/${date}/resources/${2}"
file="${folder}/${2}.log"
mkdir -p ${folder}
touch ${file}
exec > >(tee -a "${file}" )
exec 2> >(tee -a "${file}" >&2 )

# noroot
#
# noroot allows provision scripts to be run as the default user "vagrant" rather than the root
# since provision scripts are run with root privileges.
noroot() {
    sudo -EH -u "vagrant" "$@";
}

# resources.sh
#
# This will run and provision phpMyAdmin and TLS-CA for use. Please note that TLS-CA is recommended
# and should be installed locally before accessing the dashboard or any sites will be generated.
if [[ false != ${name} ]]; then
    if [[ ! -d "${dir}" ]]; then
        noroot mkdir -p "${dir}"
        noroot cp "/srv/config/resources/${name}/provision" "${dir}"
        ${dir}/provision
    else
    if [[ -d "/srv/provision/resources/phpmyadmin" ]]; then
        echo ""
    fi

    if [[ "/srv/provision/resources/tls-ca" ]]; then
        ${dir}/provision
    fi
    fi
fi



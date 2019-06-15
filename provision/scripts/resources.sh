#!/usr/bin/env bash

# variables
#
# name = name of the resource that's been used.
# dir = where the resources going to be downloaded to.
name=$2
dir="/srv/provision/resources/${name}"

# noroot
#
# noroot allows provision scripts to be run as the default user "vagrant" rather than the root
# since provision scripts are run with root privileges.
noroot() {
    sudo -EH -u "vagrant" "$@";
}

# resources.sh
#
# this will download a specific repo ( https://github.com/sandbox-resources ) and runs a provision
# script for each feature that's been added.
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
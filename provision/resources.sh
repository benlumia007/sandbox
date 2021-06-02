#!/usr/bin/env bash

# variables
#
# name = name of the resource that's been used.
# repo = name of the repo's name that is been used.
# branch = master
# dir = where the resources going to be downloaded to.
name=$1
repo=$2
branch=${3}
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
if [[ false != "${name}" && false != "${repo}" ]]; then
  if [[ ! -d ${dir}/.git ]]; then
    noroot git clone ${repo} --branch ${branch} ${dir} -q
  else
    cd ${dir}
    noroot git pull origin ${branch} -q
  fi
fi

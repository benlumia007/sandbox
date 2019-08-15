#!/bin/bash

# Sandbox ( sites.sh )
#
# @package    Sandbox
# @copyright  Copyright (C) 2019. Benjamin Lu
# @license    GNU General Public License v2 or later ( https://www.gnu.org/licenses/gpl-2.0.html )
# @author     Benjamin Lu ( https://github.com/benlumia007 )

# Variables
#
# Default variables to create sites and directories and some other stuff that gets created along the way.
domain=$1
repo=$2
branch=$3
vm_dir=$4
provision=$5

# /vagrant/sandbox-custom.yml
#
# this allows you to grab information that are needed and use shyaml to read only,since
# shyaml is not writeable but read only.
sandbox_config="/srv/config/sandbox-custom.yml"

# noroot
#
# noroot allows provision scripts to be run as the default user "vagrant" rather than the root
# since provision scripts are run with root privileges.
noroot() {
    sudo -EH -u "vagrant" "$@";
}

# get_config_value
#
# this should get the sites.site and outputs it out so that it can be read and continue to
# insall the site's information.
get_config_value() {
    local value=`cat ${sandbox_config} | shyaml get-value sites.${domain}.custom.${1} 2> /dev/null`
    echo ${value:-$@}
}

# Downloading WordPress
#
# All WordPress installation gets downloaded from GitHub.
if [[ false != "${repo}" ]]; then
  if [[ ! -d ${vm_dir}/provision/.git ]]; then
    noroot git clone ${repo} --branch ${branch} ${vm_dir}/provision -q
  else
    cd ${vm_dir}/provision
    noroot git pull origin ${branch} -q
  fi
fi

# If ${vm_dir} exists, then run setup.sh
if [[ -d ${vm_dir} ]]; then
    if [[ -f ${vm_dir}/provision/setup.sh ]]; then
      cd ${vm_dir}/provision && source setup.sh
    fi
fi
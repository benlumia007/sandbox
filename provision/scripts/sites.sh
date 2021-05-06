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

# /srv/.global/custom.yml
#
# this allows you to grab information that are needed and use shyaml to read only,since
# shyaml is not writeable but read only.
get_config_file="/srv/.global/custom.yml"

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
    local value=`cat ${get_config_file} | shyaml get-value sites.${domain}.custom.${1} 2> /dev/null`
    echo ${value:-$@}
}

# This should create the basic .conf file for a specific site when it is doing a provision.
if [[ ! -f /etc/apache2/sites-available/${domain}.conf ]]; then
  echo "Copying apache2.conf    /etc/apache2/sites-available/${domain}.conf"
  cp "/srv/config/apache/apache.conf" "/etc/apache2/sites-available/${domain}.conf"
  sed -i -e "s/{{DOMAIN}}/${DOMIN}/g" "/etc/apache2/sites-available/${domain}.conf"
  echo "enable ${domain}"
  a2ensite ${domain}.conf
  echo "restarting apache server"
  service apache2 restart
fi

if [[ ! -d ${vm_dir}/public_html ]]; then
    mkdir -p ${vm_dir}/public_html
fi

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

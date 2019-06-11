#!/bin/bash

# variables
#
# default variables to create sites and directories and some other stuff.
domain=$1
escaped=`echo ${domain} | sed 's/\./\\\\./g'`
repo=$2
branch=$3
vm_dir=$4
provision=$5

date=`cat /vagrant/provisioning_at`
folder="/var/log/provision/${date}/sites/${domain}"
file="${folder}/${domain}.log"
mkdir -p ${folder}
touch ${file}
exec > >(tee -a "${file}" )
exec 2> >(tee -a "${file}" >&2 )

# /vagrant/sandbox-custom.yml
#
# this allows you to grab information that are needed and use shyaml to read only,since
# shyaml is not writeable but read only.
sandbox_config="/vagrant/sandbox-custom.yml"

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
    local value=`cat ${sandbox_config} | shyaml get-value sites.${escaped}.custom.${1} 2> /dev/null`
    echo ${value:-$@}
}

# downloads repository from github.
#
# this will download the sandbox-custom-site and installs WordPress and it's dependencies.
if [[ false != "${repo}" ]]; then
  if [[ ! -d ${vm_dir}/provision/.git ]]; then
    echo "downloading ${domain}.test, please see ${repo}"
    noroot git clone ${repo} --branch ${branch} ${vm_dir}/provision -q
  else
    echo "updating ${domain}.test..."
    cd ${vm_dir}/provision
    noroot git pull origin ${branch} -q
  fi
else
  echo "The site: '${domain}.test' does not have a site template, assuming provision/setup.sh"
  if [[ ! -d ${vm_dir} ]]; then
    echo "Error: The '${domain}.test' has no folder."
  fi
fi

if [[ -d ${vm_dir} ]]; then
    if [[ -f ${vm_dir}/provision/setup.sh ]]; then
      cd ${vm_dir}/provision && source setup.sh
    fi
fi
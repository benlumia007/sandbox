#!/bin/bash

DOMAIN=$1
SITE_ESCAPED=`echo ${SITE} | sed 's/\./\\\\./g'`
REPO=$2
BRANCH=$3
VM_DIR=$4
SKIP_PROVISIONING=$5
PATH_TO_SITE=${VM_DIR}
SITE_NAME=${SITE}

SANDBOX_CONFIG=/vagrant/sandbox-custom.yml

noroot() {
    sudo -EH -u "vagrant" "$@";
}

# Takes 2 values, a key to fetch a value for, and an optional default value
# e.g. echo `get_config_value 'key' 'defaultvalue'`
get_config_value() {
    local value=`cat ${SANDBOX_CONFIG} | shyaml get-value sites.${SITE_ESCAPED}.custom.${1} 2> /dev/null`
    echo ${value:-$2}
}

if [[ false != "${REPO}" ]]; then
  # Clone or pull the site repository
  if [[ ! -d ${VM_DIR}/provision/.git ]]; then
    echo -e "\nDownloading ${DOMAIN}, see ${REPO}"
    noroot git clone --recursive --branch ${BRANCH} ${REPO} ${VM_DIR}/provision -q
  else
    echo -e "\nUpdating ${DOMAIN}..."
    cd ${VM_DIR}/provision
    noroot git reset origin/${BRANCH} --hard -q
    noroot git pull origin ${BRANCH} -q
    noroot git checkout ${BRANCH} -q
  fi
else
  echo "The site: '${DOMAIN}' does not have a site template, assuming provision/setup.sh"
  if [[ ! -d ${VM_DIR} ]]; then
    echo "Error: The '${DOMAN}' has no folder."
  fi
fi

if [[ -d ${VM_DIR} ]]; then
    if [[ -f ${VM_DIR}/provision/setup.sh ]]; then
      cd ${VM_DIR}/provision && source setup.sh
    fi
fi
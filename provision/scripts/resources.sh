#!/usr/bin/env bash

# variables
#
# name = name of the resource that's been used.
# repo = name of the repo's name that is been used.
# branch = master
# dir = where the resources going to be downloaded to.
name=$1
repo=$2
branch=${3:-master}
dir="/vagrant/provision/resources/${name}"

noroot() {
  sudo -EH -u "vagrant" "$@";
}

if [[ false != "${name}" && false != "${repo}" ]]; then
  if [[ ! -d ${dir}/.git ]]; then
    echo -e "downloading ${name} resources, see ${repo}"
    noroot git clone ${repo} --branch ${branch} ${dir} -q
    cd ${dir}/
    noroot git checkout ${branch} -q
  else
    echo -e "Updating ${name} resources..."
    cd ${dir}
    noroot git pull origin ${branch} -q
    noroot git checkout ${branch} -q
  fi
fi
exit 0
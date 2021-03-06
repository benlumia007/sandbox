#!/usr/bin/env bash
repo=$1
branch=${2:-master}
vm_dir=${3}
dir="${vm_dir}/public_html"

# noroot
#
# noroot allows provision scripts to be run as the default user "vagrant" rather than the root
# since provision scripts are run with root privileges.
noroot() {
    sudo -EH -u "vagrant" "$@";
}

# dashboard
#
# this will install a dashboard specifically under the following directory so that it can be
# served as a site.
if [[ ! -d "/etc/apache2/sites-available/dashboard.conf" ]]; then
  cp "/srv/config/apache/apache.conf" "/etc/apache2/sites-available/dashboard.conf"
  sed -i -e "s/{{DOMAIN}}/dashboard/g" "/etc/apache2/sites-available/dashboard.conf"
  a2ensite "dashboard.conf" > /dev/null 2>&1
fi

if [[ false != "dashboard" && false != "${repo}" ]]; then
  if [[ ! -d ${dir}/.git ]]; then
    git clone ${repo} --branch ${branch} ${dir} -q
    cd ${dir}
    git checkout ${branch} -q
  else
    cd ${dir}
    git pull origin ${branch} -q
  fi
fi
exit 0

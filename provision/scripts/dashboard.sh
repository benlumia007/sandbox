#!/usr/bin/env bash
repo=$1
branch=${2:-master}
dir="/srv/www/dashboard/public_html"

date=`cat /vagrant/provisioning_at`
folder="/var/log/provision/${date}/dashboard"
file="${folder}/dashboard.log"
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

# dashboard
#
# this will install a dashboard specifically under the following directory so that it can be
# served as a site. 
if [[ ! -d ${dir} ]]; then
  echo "copying apache2.conf    /etc/apache2/sites-available/dashboard.conf"
  cp "/srv/config/apache/apache.conf" "/etc/apache2/sites-available/dashboard.conf"
  sed -i -e "s/{{DOMAIN}}/dashboard/g" "/etc/apache2/sites-available/dashboard.conf"
  a2ensite "dashboard.conf" -q
fi

if [[ false != "dashboard" && false != "${repo}" ]]; then
  if [[ ! -d ${dir}/.git ]]; then
    echo "downloading dashboard.test, please see ${repo}"
    git clone ${repo} --branch ${branch} ${dir} -q
    cd ${dir}
    git checkout ${branch} -q
  else
    echo "updating dashboard.test..."
    cd ${dir}
    git pull origin ${branch} -q
  fi
fi
exit 0
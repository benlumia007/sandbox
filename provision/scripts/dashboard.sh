#!/usr/bin/env bash
repo=$1
branch=${2:-master}
dir="/srv/www/dashboard/public_html"

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
  cp "/srv/config/nginx/nginx.conf" "/etc/nginx/conf.d/dashboard.conf"
  sed -i -e "s/{{DOMAIN}}/dashboard/g" "/etc/nginx/conf.d/dashboard.conf"
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
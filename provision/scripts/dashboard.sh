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
  if [[ ! -d "/vagrant/certificates/dashboard" ]]; then
      mkdir -p "/vagrant/certificates/dashboard"
      cp "/srv/config/certificates/domain.ext" "/vagrant/certificates/dashboard/dashboard.ext"
      sed -i -e "s/{{DOMAIN}}/dashboard/g" "/vagrant/certificates/dashboard/dashboard.ext"
      noroot openssl genrsa -out "/vagrant/certificates/dashboard/dashboard.key" 4096
      noroot openssl req -new -key "/vagrant/certificates/dashboard/dashboard.key" -out "/vagrant/certificates/dashboard/dashboard.csr" -subj "/CN=dashboard"
      noroot openssl x509 -req -in "/vagrant/certificates/dashboard/dashboard.csr" -CA "/vagrant/certificates/ca/ca.crt" -CAkey "/vagrant/certificates/ca/ca.key" -CAcreateserial -out "/vagrant/certificates/dashboard/dashboard.crt" -days 3650 -sha256 -extfile "/vagrant/certificates/dashboard/dashboard.ext"
  fi

  echo "Copying apache2.conf    /etc/apache2/sites-available/dashboard.conf"
  cp "/srv/config/apache/apache.conf" "/etc/apache2/sites-available/dashboard.conf"
  sed -i -e "s/{{DOMAIN}}/dashboard/g" "/etc/apache2/sites-available/dashboard.conf"
  echo "enable dashboard"
  a2ensite "dashboard.conf"
fi

if [[ false != "dashboard" && false != "${repo}" ]]; then
  if [[ ! -d ${dir}/.git ]]; then
    echo -e "downloading dashboard, see ${repo}"
    git clone ${repo} --branch ${branch} ${dir} -q
    cd ${dir}
    git checkout ${branch} -q
  else
    echo -e "updating dashboard..."
    cd ${dir}
    git pull origin ${branch} -q
    git checkout ${branch} -q
  fi
fi
exit 0
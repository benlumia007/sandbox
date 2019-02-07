#!/usr/bin/env bash
REPO=$1
BRANCH=${2:-master}
DIR="/srv/www/dashboard/public_html"

noroot() {
  sudo -EH -u "vagrant" "$@";
}

if [[ ! -d ${DIR} ]]; then
  if [[ ! -d "/vagrant/certificates/dashboard" ]]; then
      mkdir -p "/vagrant/certificates/dashboard"
      cp "/srv/config/certificates/domain.ext" "/vagrant/certificates/dashboard/dashboard.ext"
      sed -i -e "s/{{DOMAIN}}/dashboard/g" "/vagrant/certificates/dashboard/dashboard.ext"
      noroot openssl genrsa -out "/vagrant/certificates/dashboard/dashboard.key" 4096
      noroot openssl req -new -key "/vagrant/certificates/dashboard/dashboard.key" -out "/vagrant/certificates/dashboard/dashboard.csr" -subj "/CN=dashboard"
      noroot openssl x509 -req -in "/vagrant/certificates/dashboard/dashboard.csr" -CA "/vagrant/certificates/ca/ca.crt" -CAkey "/vagrant/certificates/ca/ca.key" -CAcreateserial -out "/vagrant/certificates/dashboard/dashboard.crt" -days 3650 -sha256 -extfile "/vagrant/certificates/dashboard/dashboard.ext"
      sed -i '/certificate/s/^#//g' "/etc/apache2/sites-available/dashboard.conf"
  fi

  echo "Copying apache2.conf    /etc/apache2/sites-available/dashboard.conf"
  cp "/srv/config/apache/apache.conf" "/etc/apache2/sites-available/dashboard.conf"
  sed -i -e "s/{{DOMAIN}}/dashboard/g" "/etc/apache2/sites-available/dashboard.conf"
  echo "enable dashboard"
  a2ensite "dashboard.conf"
  echo "restarting apache server"
  service apache2 restart
fi

if [[ false != "dashboard" && false != "${REPO}" ]]; then
  # Clone or pull the resources repository
  if [[ ! -d ${DIR}/.git ]]; then
    echo -e "\nDownloading dashboard, see ${REPO}"
    git clone ${REPO} --branch ${BRANCH} ${DIR} -q
    cd ${DIR}
    git checkout ${BRANCH} -q
  else
    echo -e "\nUpdating dashboard..."
    cd ${DIR}
    git pull origin ${BRANCH} -q
    git checkout ${BRANCH} -q
  fi
fi
exit 0
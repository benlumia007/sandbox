#!/bin/bash

# noroot
#
# noroot allows provision scripts to be run as the default user "vagrant" rather than the root
# since provision scripts are run with root privileges.
noroot() {
    sudo -EH -u "vagrant" "$@";
}

# xdebug
#
# when you run this script, while the xdebug is set to true, it will then enable xdebug, with
# no configs, this is something that you as a user needs to be configure the way you want it
# to work. xdebug is set to false by default.
if [[ -f "/etc/php/7.4/mods-available/xdebug.ini" ]]; then
    /srv/config/bin/xdebug
fi

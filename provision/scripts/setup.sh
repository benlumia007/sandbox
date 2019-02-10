#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# /srv/database/backups
#
# database will be backup to this location when you vagrant halt or vagrant destroy, this
# allows you to be able to restore database if you do  vagrant destroy and kept all existing
# files and folders exactly the way it is or else it will fail, so be creative and be careful.
if [[ -d /srv/database/backups ]]; then
    /srv/config/bin/db_restores
fi

# xdebug
#
# when you run this script, while the xdebug is set to true, it will then enable xdebug, with
# no configs, this is something that you as a user needs to be configure the way you want it
# to work. xdebug is set to false by default.
if [[ -f "/etc/php/7.2/mods-available/xdebug.ini" ]]; then
    /srv/config/bin/xdebug
fi
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

if [[ -f "/etc/php/7.2/mods-available/xdebug.ini" ]]; then
    /srv/config/bin/xdebug
fi
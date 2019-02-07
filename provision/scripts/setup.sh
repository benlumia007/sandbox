#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# This will run if db_restore is set to true. 
if [[ -d /vagrant/database/backups ]]; then
    /vagrant/config/bin/db_restores
fi
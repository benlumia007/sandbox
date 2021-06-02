#!/bin/bash

# provision.sh
#
# this is where the utitilies comes in to play, when a feature is enabled then
# it find  specific core feature and use this to run  provision to install or 
# update a feature.
provisioner="/srv/provision/resources/${1}/${2}/provision.sh"
if [[ -f $provisioner ]]; then
    ${provisioner}
fi
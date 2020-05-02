# Vagrant for WordPress
Vagrant for WordPress is a web development platform that uses [Vagrant](https://vagrantup.com) and [VirtualBox](https://www.virtualbox.org) to focus on WordPress Development. 

## System Requirements
- Vagrant 2.2.7 or lower
- VirtualBox 6.1.6 or lower

## Software Included
Vagrant for WordPress is built with Ubuntu 18.04.4 LTS (Bionic) based VirtualBox Virtual Machine which contains all of the software needed within the Vagrant Box, so no need to install every single software and configurations, everything has been configured and ready to go. Software includes:

- [Nginx](https://www.nginx.com/)
- [MySQL Server](https://dev.mysql.com/downloads/mysql/)
- [PHP 7.2](http://www.php.net/downloads.php)
- [Composer](https://getcomposer.org/)
- [WP-Cli](https://wp-cli.org/)
- [MailHog](https://https://github.com/mailhog/MailHog/)

## How to Use Sandbox
Vagrant for WordPress requires VirtualBox and Vagrant.

To avoid any confusions with running vagrant up for the first time. Vagrantfile will duplicate sandbox-setup.yml to sandbox-custom.yml to avoid accidentally writing on the main file for sandbox-setup.yml. It will create a new site by default (sandbox.test)

If you wish to add more sites beforehand, then you will need to copy the sandbox-setup.yml manually and rename it to sandbox-custom.yml, add your sites and vagrant up.

## Licensing
This project Vagrant for WordPress is under GNU GPL, version 2.0 or higher.

2019-2020 (C) Benjamin Lu
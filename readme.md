# Sandbox
Sandbox is a web development platform that uses Vagrant and VirtualBox to focus on WordPress Development. 

## System Requirements
- Vagrant 2.2.1 or higher
- VirtualBox 6.0 or higher

## Software Included
Sandbox is built with Ubuntu 18.04 LTS (Bionic) based VirtualBox Virtual Machine which contains all of the software needed within the Vagrant Box, so no need to install every single software and configurations, everything has been configured and ready to go. Software includes:

- [Apache](https://www.apache.org/)
- [MySQL Server](https://dev.mysql.com/downloads/mysql/)
- [PHP 7.2](http://www.php.net/downloads.php)
- [Composer](https://getcomposer.org/)
- [WP-Cli](https://wp-cli.org/)
- [PHPCS](https://github.com/squizlabs/PHP_CodeSniffer)
- [Mailcatcher](https://mailcatcher.me/)

## How to Use Sandbox
Sandbox requires VirtualBox and Vagrant.

To avoid any confusions with running vagrant up for the first time. Vagrantfile will duplicate sandbox-setup.yml to sandbox-custom.yml to avoid accidentally writing on the main file for sandbox-setup.yml. It will create a new site by default (sandbox.test)

If you wish to add more sites beforehand, then you will need to copy the sandbox-setup.yml manually and rename it to sandbox-custom.yml, add your sites and vagrant up.

## Licensing
This project Sandbox is under GNU GPL, version 2.0 or higher.

2019 (C) Benjamin Lu
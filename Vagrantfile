# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'yaml'
require 'fileutils'

# All folders and projects will be at the main location of the folder that has been created
# automatically when vagrant init takes affect.
vagrant_dir = File.expand_path( File.dirname( __FILE__ ) )

# sandbox-setup.yml and sandbox-custom.yml
#
# By default, sandbox-setup.yml is the main file with all the configurations needed to create
# and modify a site and modify virtual machine if needed. When you run your first vagrant up,
# it will make a copy of sandbox-setup.yml and rename it to sandbox-custom.yml so that the
# sandbox-setup.yml remains on touch.
if File.file?( File.join( vagrant_dir, 'sandbox-custom.yml' ) ) == false then
  FileUtils.cp( File.join( vagrant_dir, 'sandbox-setup.yml' ), File.join( vagrant_dir, 'sandbox-custom.yml' ) )
end

# This will register sandbox-custom.yml as the default to be used to configured the entire
# vm. 
sandbox_config_file = File.join( vagrant_dir, 'sandbox-custom.yml' )
sandbox_config = YAML.load_file( sandbox_config_file )

# This section allows you to use the sandbox-custom.yml to register sites so that it can be
# install sites per each request.
if ! sandbox_config['sites'].kind_of? Hash then
  sandbox_config['sites'] = Hash.new
end

if ! sandbox_config['hosts'].kind_of? Hash then
  sandbox_config['hosts'] = Array.new
end

sandbox_config['sites'].each do | site, args |
  if args.kind_of? String then
    repo = args
    args = Hash.new
    args['repo'] = repo
  end

  if ! args.kind_of? Hash then
    args = Hash.new
  end

  defaults = Hash.new
  defaults['repo'] = false
  defaults['vm_dir'] = "/srv/www/#{site}"
  defaults['local_dir'] = File.join( vagrant_dir, 'sites', site )
  defaults['branch'] = 'master'
  defaults['skip_provisioning'] = false
  defaults['allow_customfile'] = false
  defaults['hosts'] = Array.new

  sandbox_config['sites'][site] = defaults.merge( args )

  if ! sandbox_config['sites'][site]['skip_provisioning'] then
    site_paths = Dir.glob( Array.new( 4 ) {|i| sandbox_config['sites'][site]['local_dir'] + '/*'*( i+1 ) + '/vvv-hosts' } )

    sandbox_config['sites'][site]['hosts'] += site_paths.map do | path |
      lines = File.readlines( path ).map( &:chomp )
      lines.grep( /\A[^#]/ )
    end.flatten

    sandbox_config['hosts'] += sandbox_config['sites'][site]['hosts']
  end
  sandbox_config['sites'][site].delete('hosts')
end

sandbox_config['hosts'] += ['dashboard.test']

# This section is mean to be used for utilties if any
if ! sandbox_config['resources'].kind_of? Hash then
  sandbox_config['resources'] = Hash.new
else
  sandbox_config['resources'].each do |name, args|
    if args.kind_of? String then
        repo = args
        args = Hash.new
        args['repo'] = repo
        args['branch'] = 'master'

        sandbox_config['resources'][name] = args
    end
  end
end

if ! sandbox_config['resources'].key?('core')
  sandbox_config['resources']['core'] = Hash.new
  sandbox_config['resources']['core']['repo'] = 'https://github.com/benlumia007/sandbox-resources.git'
  sandbox_config['resources']['core']['branch'] = 'master'
end

if ! sandbox_config['utilities'].kind_of? Hash then
  sandbox_config['utilities'] = Hash.new
end

# This section is meant to be used for sandbox-custom.yml and register vm_config.
if ! sandbox_config['vm_config'].kind_of? Hash then
  sandbox_config['vm_config'] = Hash.new
end

defaults = Hash.new
defaults['memory'] = 2048
defaults['cores'] = 2
defaults['private_network_ip'] = '172.141.145.100'

sandbox_config['vm_config'] = defaults.merge( sandbox_config['vm_config'] )

sandbox_config['hosts'] = sandbox_config['hosts'].uniq

if ! sandbox_config['dashboard']
  sandbox_config['dashboard'] = Hash.new
end

dashboard_defaults = Hash.new
dashboard_defaults['repo'] = 'https://github.com/benlumia007/sandbox-dashboard.git'
dashboard_defaults['branch'] = 'master'
sandbox_config['dashboard'] = dashboard_defaults.merge(sandbox_config['dashboard'])

# All Vagrant configuration is done below. The "2" in Vagrant.configure configures the 
# configuration version (we support older styles for backwards compatibility). Please don't
# change it unless you know what you're doing.
Vagrant.configure( "2" ) do | config |
  # The most common configuration options are documented and commented below. For a complete
  # reference, please see the online documentation at https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for boxes at 
  # https://vagrantcloud.com/search.
  config.vm.box = "benlumia007/sandbox"
  config.vm.box_version = "0.0.1"
  config.vm.base_mac = "0800273C9A89"

  # xdebug
  #
  # setting forwarded port off by default
  # config.vm.network "forwarded_port", guest: 9000, host: 9000

  # You can customize the name that appears in the VirtualBox Graphic User Interface by
  # setting up the name property. By default, Vagrant sets it to the container folder of
  # the Vagrantfile plus a timestamp when the machine was created. By setting another name,
  # your Virtual Machine can be more easily identified.
  config.vm.provider "virtualbox" do | vm |
    vm.name = "sandbox"

    vm.customize ["modifyvm", :id, "--memory", sandbox_config['vm_config']['memory']]
    vm.customize ["modifyvm", :id, "--cpus", sandbox_config['vm_config']['cores']]
  end
  
  # Create a private network, which allows host-only access to the machine using a specific IP.
  config.vm.network :private_network, id: "sandbox_primary", ip: sandbox_config['vm_config']['private_network_ip']

  # /var/log/php
  #
  # 
  config.vm.synced_folder "log/php", "/var/log/php", :owner => 'vagrant', :mount_options => [ "dmode=777", "fmode=777"]

  # /var/log/mysql
  #
  #
  config.vm.synced_folder "log/mysql", "/var/log/mysql", :owner => 'mysql', :group => 'adm'

  # /srv/config
  #
  # This is where all the configuration files that are available to use to copy to the sandbox
  # vagrant box.
  config.vm.synced_folder "config", "/srv/config"

  # /srv/database
  #
  # database stores here
  config.vm.synced_folder "database", "/srv/database"

  # /srv/www
  #
  # This is the default folder that  holds all of the custom sites when you generate a new site using 
  # the sandbox-custom.yml.
  config.vm.synced_folder "sites", "/srv/www", :owner => "www-data", :mount_options => [ "dmode=775", "fmode=774" ]

  # This section when set, it will synced a folder that will use www-data as default.
  sandbox_config['sites'].each do | site, args |
    if args['local_dir'] != File.join( vagrant_dir, 'sites', site ) then
      config.vm.synced_folder args['local_dir'], args['vm_dir'], :owner => "www-data", :mount_options => [ "dmode=775", "fmode=774" ]
    end
  end

  # setup.sh or custom.sh
  #
  # By default, the Vagrantfile is set to use the setup.sh bash script which is located in
  # the provision directory. If custom.sh is detected when created manually, then it will
  # use custom.sh as a replacement.
  if File.exists?( File.join( vagrant_dir,'provision','custom.sh' ) ) then
    config.vm.provision "custom", type: "shell", path: File.join( "provision/scripts", "custom.sh" )
  else
    config.vm.provision "default", type: "shell", path: File.join( "provision/scripts", "setup.sh" )
  end

  # Add a provision script that allows site created when set in the sandbox-custom.yml
  sandbox_config['sites'].each do | site, args |
    if args['skip_provisioning'] === false then
      config.vm.provision "site-#{site}",
        type: "shell",
        path: File.join( "provision/scripts", "sites.sh" ),
        args: [
          site,
          args['repo'].to_s,
          args['branch'],
          args['vm_dir'],
          args['skip_provisioning'].to_s,
        ]
    end
  end

  # resources
  sandbox_config['resources'].each do | name, args |
    config.vm.provision "resources-#{name}",
      type: "shell",
      path: File.join( "provision/scripts", "resources.sh" ),
      args: [
          name,
          args['repo'].to_s,
          args['branch'],
      ]
  end

  sandbox_config['utilities'].each do | name, utilities |
    if ! utilities.kind_of? Array then
      utilities = Hash.new
    end
    utilities.each do | utility |
        config.vm.provision "resources-#{name}-#{utility}",
          type: "shell",
          path: File.join( "provision/scripts", "utility.sh" ),
          args: [
              name,
              utility
          ]
      end
  end

  # Provision the dashboard that appears when you visit vvv.test
  config.vm.provision "site-dashboard",
      type: "shell",
      path: File.join( "provision/scripts", "dashboard.sh" ),
      args: [
        sandbox_config['dashboard']['repo'],
        sandbox_config['dashboard']['branch']
      ]

  # This uses the vagrant-hostsupdater plugin and adds an entry to your /etc/hosts file on your host system.
  if defined?( VagrantPlugins::HostsUpdater )
    config.hostsupdater.aliases = sandbox_config['hosts']
    config.hostsupdater.remove_on_suspend = true
  end

  config.trigger.after :up do |trigger|
    trigger.name = "vagrant up"
    trigger.run_remote = { inline: "/vagrant/config/bin/vagrant_up" }
    trigger.on_error = :continue
  end

  config.trigger.after :reload do |trigger|
    trigger.name = "vagrant reload"
    trigger.run_remote = { inline: "/vagrant/config/bin/vagrant_up" }
    trigger.on_error = :continue
  end

  config.trigger.before :halt do |trigger|
    trigger.name = "vagrant halt"
    trigger.run_remote = { inline: "/vagrant/config/bin/vagrant_halt" }
    trigger.on_error = :continue
  end
  config.trigger.before :destroy do |trigger|
    trigger.name = "vagrant destroy"
    trigger.run_remote = { inline: "/vagrant/config/bin/vagrant_destroy" }
    trigger.on_error = :continue
  end
end
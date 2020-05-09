# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.require_version ">= 2.2.7"
require 'yaml'
require 'fileutils'

# All folders and projects will be at the main location of the folder that has been created automatically when vagrant init takes affect.
vagrant_dir = File.expand_path( File.dirname( __FILE__ ) )

if [ 'up', 'reload' ].include? ARGV[0] then
  splash = <<-HEREDOC

  Contributor:    benlumia007
  Version:        1.0.0

  Project:        https://github.com/benlumia007/sandbox
  Dashboard:      https://dashboard.test

  HEREDOC
  puts splash
end

# sandbox-setup.yml and sandbox-custom.yml
#
# By default, sandbox-setup.yml is the main file with all the configurations needed to create and modify a site and modify
# virtual machine if needed. When you run your first vagrant up, it will make a copy of sandbox-setup.yml and rename it to
# sandbox-custom.yml so that the sandbox-setup.yml remains on touch.
if File.file?( File.join( vagrant_dir, '/config/sandbox-custom.yml' ) ) == false then
  FileUtils.cp( File.join( vagrant_dir, '/config/sandbox-setup.yml' ), File.join( vagrant_dir, '/config/sandbox-custom.yml' ) )
end

# This will register sandbox-custom.yml as the default to be used to configured the entire vm.
sandbox_config_file = File.join( vagrant_dir, '/config/sandbox-custom.yml' )
sandbox_config = YAML.load_file( sandbox_config_file )

# This section allows you to use the sandbox-custom.yml to register sites so that it can be install sites per each request.
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
  defaults['provision'] = true
  defaults['hosts'] = Array.new

  sandbox_config['sites'][site] = defaults.merge( args )

  if sandbox_config['sites'][site]['provision'] then
    site_paths = Dir.glob( Array.new( 4 ) { | i | sandbox_config['sites'][site]['local_dir'] + '/*' * ( i+1 ) + 'readme.md' } )

    sandbox_config['sites'][site]['hosts'] += site_paths.map do | path |
      lines = File.readlines( path ).map( &:chomp )
      lines.grep( /\A[^#]/ )
    end.flatten

    sandbox_config['hosts'] += sandbox_config['sites'][site]['hosts']
  end
  sandbox_config['sites'][site].delete('hosts')
end

# dashboard.test
#
# This is the default dashboard, when enabled as you can see here, it will then generate a new site before the resources
# takes affect, this will then let you see what exactly have you added a site using the sandbox-custom.yml.
sandbox_config['hosts'] += ['dashboard.test']

# vm_config
#
# This section for vm_config has its default, memory, core and the private ip that is been use by default. the private ip
# is something that doesn't get change often, so leaving as it is will work just fine.
if ! sandbox_config['vm_config'].kind_of? Hash then
  sandbox_config['vm_config'] = Hash.new
end

defaults = Hash.new
defaults['memory'] = 2048
defaults['cores'] = 2
defaults['private_network_ip'] = '192.141.145.100'

sandbox_config['vm_config'] = defaults.merge( sandbox_config['vm_config'] )

sandbox_config['hosts'] = sandbox_config['hosts'].uniq

# dashboard configuration
#
# this will grab the dashboard repo and gets installed before the resources takes place.
if ! sandbox_config['dashboard']
  sandbox_config['dashboard'] = Hash.new
end

dashboard_defaults = Hash.new
dashboard_defaults['repo'] = 'https://github.com/benlumia007/vagrant-for-wordpress-dashboard.git'
dashboard_defaults['branch'] = 'master'
sandbox_config['dashboard'] = dashboard_defaults.merge( sandbox_config['dashboard'] )

# Resources
#
# This is the resources that gets added by default under the sandbox-custom.yml. this will
# automatically add phpmyadmin and tls-ca for ssl certificates.
if ! sandbox_config['resources'].kind_of? Hash then
  sandbox_config['resources'] = Hash.new
else
  sandbox_config['resources'].each do | name, args |
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
  sandbox_config['resources']['core']['repo'] = 'https://github.com/benlumia007/vagrant-for-wordpress-resources.git'
  sandbox_config['resources']['core']['branch'] = 'master'
end

if ! sandbox_config['utilities'].kind_of? Hash then
  sandbox_config['utilities'] = Hash.new
end

if defined? sandbox_config['vm_config']['provider']
  # Override or set the vagrant provider.
  ENV['VAGRANT_DEFAULT_PROVIDER'] = sandbox_config['vm_config']['provider']
end

# All Vagrant configuration is done below. The "2" in Vagrant.configure configures the
# configuration version (we support older styles for backwards compatibility). Please don't
# change it unless you know what you're doing.
Vagrant.configure( "2" ) do | config |
  # The most common configuration options are documented and commented below. For a complete
  # reference, please see the online documentation at https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for boxes at
  # https://vagrantcloud.com/search.
  config.vm.box = "benlumia007/bionic64"
  config.vm.box_version = "1.0.0"

  # You can customize the name that appears in the VirtualBox Graphic User Interface by
  # setting up the name property. By default, Vagrant sets it to the container folder of
  # the Vagrantfile plus a timestamp when the machine was created. By setting another name,
  # your Virtual Machine can be more easily identified.
  config.vm.provider "virtualbox" do | vm |
    vm.name = File.basename(vagrant_dir) + "_" + (Digest::SHA256.hexdigest vagrant_dir)[0..10]

    vm.customize ["modifyvm", :id, "--memory", sandbox_config['vm_config']['memory']]
    vm.customize ["modifyvm", :id, "--cpus", sandbox_config['vm_config']['cores']]
  end

  # Private Networking
  #
  # Create a private network, which allows host-only access to the machine using a specific IP. This should only work
  # with VirtualBox and Parallels, whereas, Microsoft Hyper-V does not. Microsoft Hyper-V only detects an IP but no
  # way to tell vagrantfile what IP that is.
  config.vm.network :private_network, id: "sandbox_primary", ip: sandbox_config['vm_config']['private_network_ip']

  # /vagrant
  #
  # The following config.vm.synced_folder will map directories in your Vagrant environment which will map any
  # changes within your local enviornment and virtual machine. This will then cause issues due to sharing the same
  # file. There is really no point of having the same files so we only want to share specific files. We will then
  # disabled the default shared folder /vagrant and re-created as a non-sharing folder.
  config.vm.synced_folder ".", "/vagrant", disabled: true

  # Default Synced Folders
  #
  # Here are the synced folders that gets shared from the host to the virtual machine.
  config.vm.synced_folder "certificates", "/srv/certificates", create: true, :owner => "vagrant", :group => "vagrant", :mount_options => [ "dmode=0775", "fmode=0774" ]
  config.vm.synced_folder "config", "/srv/config", :owner => "vagrant", :group => "vagrant", :mount_options => [ "dmode=0775", "fmode=0774" ]
  config.vm.synced_folder "database", "/srv/database"
  config.vm.synced_folder "provision", "/srv/provision", :owner => "vagrant", :group => "vagrant", :mount_options => [ "dmode=0775", "fmode=0774" ]
  config.vm.synced_folder "sites", "/srv/www", :owner => "vagrant", :group => "www-data", :mount_options => [ "dmode=0775", "fmode=0774" ]

  # Default Synced Folders for Logs
  #
  # Here are the Synced Folders that gets shared which considers to be for logs
  config.vm.synced_folder "log/nginx", "/var/log/nginx", :owner => 'www-data', :group => 'adm'
  config.vm.synced_folder "log/mysql", "/var/log/mysql", :owner => 'mysql', :group => 'adm'
  config.vm.synced_folder "log/php", "/var/log/php", :owner => 'vagrant', :mount_options => [ "dmode=0777", "fmode=0777"]

  # This section when set, it will synced a folder that will use www-data as default.
  sandbox_config['sites'].each do | site, args |
    if args['local_dir'] != File.join( vagrant_dir, 'sites', site ) then
      config.vm.synced_folder args['local_dir'], args['vm_dir'], :owner => "vagrant", :group => "www-data", :mount_options => [ "dmode=0775", "fmode=0774" ]
    end
  end

  # Microsoft Hyper-V
  #
  #
  config.vm.provider :hyperv do | vm, override |
    vm.vmname = File.basename(vagrant_dir) + "_" + (Digest::SHA256.hexdigest vagrant_dir)[0..10]
    vm.memory = sandbox_config['vm_config']['memory']
    vm.cpus = sandbox_config['vm_config']['core']
    vm.enable_virtualization_extensions = true
    vm.linked_clone = true

    override.vm.network :private_network, id: "sandbox_primary", ip: nil

    # Default Synced Folders
    #
    # Here are the synced folders that gets shared from the host to the virtual machine.
    override.vm.synced_folder "certificates", "/srv/certificates", create: true, :owner => "vagrant", :group => "vagrant", :mount_options => [ "dir_mode=0775", "file_mode=0774" ]
    override.vm.synced_folder "config", "/srv/config", :owner => "vagrant", :group => "vagrant", :mount_options => [ "dir_mode=0775", "file_mode=0774" ]
    override.vm.synced_folder "provision", "/srv/provision", :owner => "vagrant", :group => "vagrant", :mount_options => [ "dir_mode=0775", "file_mode=0774" ]
    override.vm.synced_folder "sites", "/srv/www", :owner => "vagrant", :group => "www-data", :mount_options => [ "dir_mode=0775", "file_mode=0774" ]

    # Default Synced Folders for Logs
    #
    # Here are the Synced Folders that gets shared which considers to be for logs
    override.vm.synced_folder "log/php", "/var/log/php", :owner => 'vagrant', :mount_options => [ "dir_mode=0777", "file_mode=0777" ]

    sandbox_config['sites'].each do | site, args |
      if args['local_dir'] != File.join( vagrant_dir, 'sites', site ) then
        override.vm.synced_folder args['local_dir'], args['vm_dir'], :owner => "vagrant", :group => "www-data", :mount_options => [ "dir_mode=0775", "file_mode=0774" ]
      end
    end
  end

  # setup.sh or custom.sh
  #
  # By default, the Vagrantfile is set to use the setup.sh bash script which is located in
  # the provision directory. If custom.sh is detected when created manually, then it will
  # use custom.sh as a replacement.
  config.vm.provision "default", type: "shell", path: File.join( "provision/scripts", "setup.sh" )

  sandbox_config['sites'].each do | site, args |
    if args['provision'] === true then
      config.vm.provision "import-database", type: "shell", path: File.join( "provision/scripts/database.sh" )
    end
  end

  # Add a provision script that allows site created when set in the sandbox-custom.yml
  sandbox_config['sites'].each do | site, args |
    if args['provision'] === true then
      config.vm.provision "site-#{site}",
        type: "shell",
        path: File.join( "provision/scripts", "sites.sh" ),
        args: [
          site,
          args['repo'].to_s,
          args['branch'],
          args['vm_dir'],
          args['provision'].to_s,
        ]
    end
  end

  # Provision the dashboard that appears when you visit https://dashboard.test
  config.vm.provision "site-dashboard",
      type: "shell",
      path: File.join( "provision/scripts", "dashboard.sh" ),
      args: [
        sandbox_config['dashboard']['repo'],
        sandbox_config['dashboard']['branch']
      ]

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

  if defined?(VagrantPlugins::HostManager)
    config.hostmanager.aliases = sandbox_config['hosts']
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true
    config.hostmanager.manage_guest = true
    config.hostmanager.ignore_private_ip = false
    config.hostmanager.include_offline = true
  elsif defined?(VagrantPlugins::HostsUpdater)
    # Pass the found host names to the hostsupdater plugin so it can perform magic.
    config.hostsupdater.aliases = sandbox_config['hosts']
    config.hostsupdater.remove_on_suspend = true
  else
    puts "! Neither the HostManager or HostsUpdater plugins are installed!!! Domains won't work without one of these plugins!"
    puts "Run vagrant plugin install vagrant-hostmanager then try again."
  end


  # triggers
  #
  # triggers allows you to certain commands so that things falls into place, when you vagrant halt or vagrant
  # destroy, it will then back up any database and converted it to a .sql file or if you vagrant up, it will
  # restart the apache and mysql server just in case if something happens.
  config.trigger.after :up do | trigger |
    trigger.name = "vagrant up"
    trigger.run_remote = { inline: "/srv/config/bin/vagrant_up" }
    trigger.on_error = :continue
  end

  config.trigger.after :reload do | trigger |
    trigger.name = "vagrant reload"
    trigger.run_remote = { inline: "/srv/config/bin/vagrant_up" }
    trigger.on_error = :continue
  end

  config.trigger.before :halt do | trigger |
    trigger.name = "vagrant halt"
    trigger.run_remote = { inline: "/srv/config/bin/vagrant_halt" }
    trigger.on_error = :continue
  end

  config.trigger.before :suspend do | trigger |
    trigger.name = "vagrant suspend"
    trigger.run_remote = { inline: "/srv/config/bin/vagrant_halt" }
    trigger.on_error = :continue
  end

  config.trigger.before :destroy do | trigger |
    trigger.name = "vagrant destroy"
    trigger.run_remote = { inline: "/srv/config/bin/vagrant_destroy" }
    trigger.on_error = :continue
  end
end

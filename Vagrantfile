# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.require_version ">= 2.2.14"
require 'yaml'
require 'fileutils'

# All folders and projects will be at the main location of the folder that has been created automatically when vagrant init takes affect.
vagrant_dir = File.expand_path( File.dirname( __FILE__ ) )

if [ 'up', 'reload' ].include? ARGV[0] then
  splash = <<-HEREDOC

  Contributor:    benlumia007
  Version:        1.0.0

  Project:        https://github.com/benlumia007/sturdy-vagrant
  Dashboard:      https://dashboard.test

  HEREDOC
  puts splash
end

# default.yml and custom.yml
#
# By default, default.yml is the main file with all the configurations needed to create and modify a site and modify
# virtual machine if needed. When you run your first vagrant up, it will make a copy of default.yml and rename it to
# custom.yml so that the default.yml remains on touch.
if File.file?( File.join( vagrant_dir, '.global/custom.yml' ) ) == false then
  FileUtils.mkdir( '.global' )
  FileUtils.cp( File.join( vagrant_dir, 'config/default.yml' ), File.join( vagrant_dir, '.global/custom.yml' ) )
end

# This will register custom.yml as the default to be used to configured the entire vm.
set_config_file = File.join( vagrant_dir, '.global/custom.yml' )
get_config_file = YAML.load_file( set_config_file )

# This section allows you to use the custom.yml to register sites so that it can be install sites per each request.
if ! get_config_file['sites'].kind_of? Hash then
  get_config_file['sites'] = Hash.new
end

if ! get_config_file['hosts'].kind_of? Hash then
  get_config_file['hosts'] = Array.new
end

# dashboard.test
#
# This is the default dashboard, when enabled as you can see here, it will then generate a new site before the resources
# takes affect, this will then let you see what exactly have you added a site using the custom.yml.
get_config_file['hosts'] += ['dashboard.test']


get_config_file['sites'].each do | site, args |
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
  defaults['branch'] = 'main'
  defaults['provision'] = false
  defaults['hosts'] = Array.new

  get_config_file['sites'][site] = defaults.merge( args )

  if get_config_file['sites'][site]['provision'] then
    site_paths = Dir.glob( Array.new( 4 ) { | i | get_config_file['sites'][site]['local_dir'] + '/*' * ( i+1 ) + '/sv-hosts' } )

    get_config_file['sites'][site]['hosts'] += site_paths.map do | path |
      lines = File.readlines( path ).map( &:chomp )
      lines.grep( /\A[^#]/ )
    end.flatten

    get_config_file['hosts'] += get_config_file['sites'][site]['hosts']
  end
  get_config_file['sites'][site].delete('hosts')
end

# vm_config
#
# This section for vm_config has its default, memory, core and the private ip that is been use by default. the private ip
# is something that doesn't get change often, so leaving as it is will work just fine.
if ! get_config_file['vm_config'].kind_of? Hash then
  get_config_file['vm_config'] = Hash.new
end

defaults = Hash.new
defaults['memory'] = 2048
defaults['cores'] = 2
defaults['private_network_ip'] = '192.141.145.100'

get_config_file['vm_config'] = defaults.merge( get_config_file['vm_config'] )

get_config_file['hosts'] = get_config_file['hosts'].uniq

# dashboard configuration
#
# this will grab the dashboard repo and gets installed before the resources takes place.
if ! get_config_file['dashboard']
  get_config_file['dashboard'] = Hash.new
end

dashboard_defaults = Hash.new
dashboard_defaults['repo'] = 'https://github.com/benlumia007/sturdy-vagrant-dashboard.git'
dashboard_defaults['branch'] = 'main'
dashboard_defaults['vm_dir'] = '/srv/www/dashboard'
get_config_file['dashboard'] = dashboard_defaults.merge( get_config_file['dashboard'] )

# Resources
#
# This is the resources that gets added by default under the custom.yml. this will
# automatically add phpmyadmin and tls-ca for ssl certificates.
if ! get_config_file['resources'].kind_of? Hash then
  get_config_file['resources'] = Hash.new
else
  get_config_file['resources'].each do | name, args |
    if args.kind_of? String then
        repo = args
        args = Hash.new
        args['repo'] = repo
        args['branch'] = 'main'

        get_config_file['resources'][name] = args
    end
  end
end

if ! get_config_file['resources'].key?('core')
  get_config_file['resources']['core'] = Hash.new
  get_config_file['resources']['core']['repo'] = 'https://github.com/benlumia007/sturdy-vagrant-resources.git'
  get_config_file['resources']['core']['branch'] = 'main'
end

if ! get_config_file['utilities'].kind_of? Hash then
  get_config_file['utilities'] = Hash.new
end

if defined? get_config_file['vm_config']['provider']
  # Override or set the vagrant provider.
  ENV['VAGRANT_DEFAULT_PROVIDER'] = get_config_file['vm_config']['provider']
end

# All Vagrant configuration is done below. The "2" in Vagrant.configure configures the
# configuration version (we support older styles for backwards compatibility). Please don't
# change it unless you know what you're doing.
Vagrant.configure( "2" ) do | config |
  # The most common configuration options are documented and commented below. For a complete
  # reference, please see the online documentation at https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for boxes at
  # https://vagrantcloud.com/search.
  config.vm.box = "benlumia007/sturdy-vagrant"
  config.vm.box_version = "1.0.0"

  # You can customize the name that appears in the VirtualBox Graphic User Interface by
  # setting up the name property. By default, Vagrant sets it to the container folder of
  # the Vagrantfile plus a timestamp when the machine was created. By setting another name,
  # your Virtual Machine can be more easily identified.
  config.vm.provider "virtualbox" do | vm |
    vm.name = File.basename(vagrant_dir) + "_" + (Digest::SHA256.hexdigest vagrant_dir)[0..10]

    vm.customize ["modifyvm", :id, "--memory", get_config_file['vm_config']['memory']]
    vm.customize ["modifyvm", :id, "--cpus", get_config_file['vm_config']['cores']]
  end

  # Private Networking
  #
  # Create a private network, which allows host-only access to the machine using a specific IP. This should only work
  # with VirtualBox and Parallels, whereas, Microsoft Hyper-V does not. Microsoft Hyper-V only detects an IP but no
  # way to tell vagrantfile what IP that is.
  config.vm.network :private_network, id: "sandbox_primary", ip: get_config_file['vm_config']['private_network_ip']

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
  config.vm.synced_folder ".global", "/srv/.global", :owner => "vagrant", :group => "vagrant", :mount_options => [ "dmode=0775", "fmode=0774" ]
  config.vm.synced_folder "certificates", "/srv/certificates", create: true, :owner => "vagrant", :group => "vagrant", :mount_options => [ "dmode=0775", "fmode=0774" ]
  config.vm.synced_folder "config", "/srv/config", :owner => "vagrant", :group => "vagrant", :mount_options => [ "dmode=0775", "fmode=0774" ]
  config.vm.synced_folder "databases", "/srv/databases", create: true
  config.vm.synced_folder "provision", "/srv/provision", :owner => "vagrant", :group => "vagrant", :mount_options => [ "dmode=0775", "fmode=0774" ]
  config.vm.synced_folder "sites", "/srv/www", create: true, :owner => "vagrant", :group => "www-data", :mount_options => [ "dmode=0775", "fmode=0774" ]

  # Default Synced Folders for Logs
  #
  # Here are the Synced Folders that gets shared which considers to be for logs
  config.vm.synced_folder "logs/apache2", "/var/logs/apache2", :owner => 'www-data', :group => 'adm', create: true
  config.vm.synced_folder "logs/mysql", "/var/logs/mysql", :owner => 'mysql', :group => 'adm', create: true
  config.vm.synced_folder "logs/php", "/var/logs/php", :owner => 'vagrant', :mount_options => [ "dmode=0777", "fmode=0777"], create: true

  # This section when set, it will synced a folder that will use www-data as default.
  get_config_file['sites'].each do | site, args |
    if args['local_dir'] != File.join( vagrant_dir, 'sites', site ) then
      config.vm.synced_folder args['local_dir'], args['vm_dir'], :owner => "vagrant", :group => "www-data", :mount_options => [ "dmode=0775", "fmode=0774" ]
    end
  end

  # Microsoft Hyper-V
  #
  #
  config.vm.provider :hyperv do | vm, override |
    vm.vmname = File.basename(vagrant_dir) + "_" + (Digest::SHA256.hexdigest vagrant_dir)[0..10]
    vm.memory = get_config_file['vm_config']['memory']
    vm.cpus = get_config_file['vm_config']['core']
    vm.enable_virtualization_extensions = true
    vm.linked_clone = true

    override.vm.network :private_network, id: "sandbox_primary", ip: nil

    # Microsoft Hyper-V  Synced Folders
    #
    # Here are the synced folders that gets shared from the host to the virtual machine. We will be overriding
    # the default synced folder for Microsoft Hyper-V
    override.vm.synced_folder ".global", "/srv/.global", :owner => "vagrant", :group => "vagrant", :mount_options => [ "dir_mode=0775", "file_mode=0774" ]
    override.vm.synced_folder "certificates", "/srv/certificates", create: true, :owner => "vagrant", :group => "vagrant", :mount_options => [ "dir_mode=0775", "file_mode=0774" ]
    override.vm.synced_folder "config", "/srv/config", :owner => "vagrant", :group => "vagrant", :mount_options => [ "dir_mode=0775", "file_mode=0774" ]
    override.vm.synced_folder "provision", "/srv/provision", :owner => "vagrant", :group => "vagrant", :mount_options => [ "dir_mode=0775", "file_mode=0774" ]
    override.vm.synced_folder "sites", "/srv/www", create: true, :owner => "vagrant", :group => "www-data", :mount_options => [ "dir_mode=0775", "file_mode=0774" ]

    override.vm.synced_folder "logs/php", "/var/logs/php", :owner => 'vagrant', :mount_options => [ "dir_mode=0777", "file_mode=0777" ]

    get_config_file['sites'].each do | site, args |
      if args['local_dir'] != File.join( vagrant_dir, 'sites', site ) then
        override.vm.synced_folder args['local_dir'], args['vm_dir'], :owner => "vagrant", :group => "www-data", :mount_options => [ "dir_mode=0775", "file_mode=0774" ]
      end
    end
  end

  # Parallels Desktop ( Pro )
  #
  #
  config.vm.provider :parallels do | vm, override |
    vm.name = File.basename(vagrant_dir) + "_" + (Digest::SHA256.hexdigest vagrant_dir)[0..10]
    vm.memory = get_config_file['vm_config']['memory']
    vm.cpus = get_config_file['vm_config']['core']

    # Default Synced Folders
    #
    # Here are the synced folders that gets shared from the host to the virtual machine.
    override.vm.synced_folder ".global", "/srv/.global", :owner => "vagrant", :group => "vagrant", :mount_options => [ 'share' ]
    override.vm.synced_folder "certificates", "/srv/certificates", create: true, :owner => "vagrant", :group => "vagrant", :mount_options => [ 'share' ]
    override.vm.synced_folder "config", "/srv/config", :owner => "vagrant", :group => "vagrant", :mount_options => [ 'share' ]
    override.vm.synced_folder "provision", "/srv/provision", :owner => "vagrant", :group => "vagrant", :mount_options => [ 'share' ]
    override.vm.synced_folder "sites", "/srv/www", create: true, :owner => "vagrant", :group => "www-data", :mount_options => [ 'share' ]

    # Default Synced Folders for Logs
    #
    # Here are the Synced Folders that gets shared which considers to be for logs
    override.vm.synced_folder "logs/php", "/var/logs/php", :owner => 'vagrant', :mount_options => [ 'share' ]

    get_config_file['sites'].each do | site, args |
      if args['local_dir'] != File.join( vagrant_dir, 'sites', site ) then
        override.vm.synced_folder args['local_dir'], args['vm_dir'], :owner => "vagrant", :group => "www-data", :mount_options => [ 'share' ]
      end
    end
  end

  # setup.sh
  #
  # By default, the Vagrantfile is set to use the setup.sh bash script which is located in
  # the provision directory.
  config.vm.provision "default", type: "shell", path: File.join( "provision", "setup.sh" )

  # import-database
  #
  # We should import databases if exists so that when you do a vagrant destroy and vagrant up, it
  # will check of the *.sql exists then import database but will check the tables in mysql first, if it exists
  # stop the sequence.
  get_config_file['sites'].each do | site, args |
    if args['provision'] === true then
      config.vm.provision "import-database", type: "shell", path: File.join( "provision", "database.sh" )
    end
  end

  # Provision the dashboard that appears when you visit https://dashboard.test
  config.vm.provision "site-dashboard",
      type: "shell",
      path: File.join( "provision", "dashboard.sh" ),
      args: [
        get_config_file['dashboard']['repo'],
        get_config_file['dashboard']['branch'],
        get_config_file['dashboard']['vm_dir']
      ]

  # Add a provision script that allows site created when set in the custom.yml
  get_config_file['sites'].each do | site, args |
    if args['provision'] === true then
      config.vm.provision "site-#{site}",
        type: "shell",
        path: File.join( "provision", "sites.sh" ),
        args: [
          site,
          args['repo'].to_s,
          args['branch'],
          args['vm_dir'],
          args['provision'].to_s,
        ]
    end
  end

  # resources
  #
  # creates and pulls resources into provision/resources/core
  get_config_file['resources'].each do | name, args |
    config.vm.provision "resources-#{name}",
      type: "shell",
      path: File.join( "provision", "resources.sh" ),
      args: [
          name,
          args['repo'].to_s,
          args['branch'],
      ]
  end

  # utilities
  #
  # checks if provision/resources/core exists then continue to deploy the core features
  # such as phpmyadmin and tls-ca.
  get_config_file['utilities'].each do | name, utilities |
    if ! utilities.kind_of? Array then
      utilities = Hash.new
    end

    utilities.each do | utility |
        config.vm.provision "resources-#{name}-#{utility}",
          type: "shell",
          path: File.join( "provision", "utility.sh" ),
          args: [
              name,
              utility
          ]
      end
  end

# vagrant-hostsupdater
#
# If the vagrant-hostsupdater exists then it should allow all hosts be added automatically
 if defined?(VagrantPlugins::HostsUpdater)
    # Pass the found host names to the hostsupdater plugin so it can perform magic.
    config.hostsupdater.aliases = get_config_file['hosts']
    config.hostsupdater.remove_on_suspend = true
  else
    puts "! HostsUpdater is not install!!! Domains won't work without one of these plugins!"
    puts "Run vagrant plugin install vagrant-hostsupdater then try again."
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

  config.trigger.before :reload do | trigger |
    trigger.name = "vagrant reload"
    trigger.run_remote = { inline: "/srv/config/bin/vagrant_halt" }
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

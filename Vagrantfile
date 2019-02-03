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

# This section is meant to be used for sandbox-custom.yml and register vm_config.
if ! sandbox_config['vm_config'].kind_of? Hash then
  sandbox_config['vm_config'] = Hash.new
end

defaults = Hash.new
defaults['memory'] = 512
defaults['cores'] = 1
defaults['private_network_ip'] = '192.141.145.100'

sandbox_config['vm_config'] = defaults.merge( sandbox_config['vm_config'] )

sandbox_config['hosts'] = sandbox_config['hosts'].uniq

# All Vagrant configuration is done below. The "2" in Vagrant.configure configures the 
# configuration version (we support older styles for backwards compatibility). Please don't
# change it unless you know what you're doing.
Vagrant.configure( "2" ) do | config |
  # The most common configuration options are documented and commented below. For a complete
  # reference, please see the online documentation at https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for boxes at 
  # https://vagrantcloud.com/search.
  config.vm.box = "benlumia007/sandbox"

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

  # /srv/www. This is the default folder that  holds all of the custom sites when you
  # generate a new site using the sandbox-custom.yml.
  config.vm.synced_folder "sites/", "/srv/www", :owner => "www-data", :mount_options => [ "dmode=775", "fmode=774" ]

  # This section when set, it will synced a folder that will use www-data as default.
  sandbox_config['sites'].each do | site, args |
    if args['local_dir'] != File.join( vagrant_dir, 'sites', site ) then
      config.vm.synced_folder args['local_dir'], args['vm_dir'], :owner => "www-data", :mount_options => [ "dmode=775", "fmode=774" ]
    end
  end

  # Add a provision script that allows site created when set in the sandbox-custom.yml
  sandbox_config['sites'].each do | site, args |
    if args['skip_provisioning'] === false then
      config.vm.provision "site-#{site}",
        type: "shell",
        path: File.join( "provision", "sites.sh" ),
        args: [
          site,
          args['repo'].to_s,
          args['branch'],
          args['vm_dir'],
          args['skip_provisioning'].to_s,
        ]
    end
  end

  # This uses the vagrant-hostsupdater plugin and adds an entry to your /etc/hosts file on your host system.
  if defined?( VagrantPlugins::HostsUpdater )
    config.hostsupdater.aliases = sandbox_config['hosts']
    config.hostsupdater.remove_on_suspend = true
  end

  # setup.sh or custom.sh
  #
  # By default, the Vagrantfile is set to use the setup.sh bash script which is located in
  # the provision directory. If custom.sh is detected when created manually, then it will
  # use custom.sh as a replacement.
  # if File.exists?( File.join( vagrant_dir,'provision','custom.sh' ) ) then
  #  config.vm.provision "custom", type: "shell", path: File.join( "provision", "custom.sh" )
  # else
  #  config.vm.provision "default", type: "shell", path: File.join( "provision", "setup.sh" )
  # end
end
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
  FileUtils.cp( File.join( vagrant_dir, 'sandbox-setup.yml' ), File.join(vagrant_dir, 'sandbox-custom.yml' ) )
end

# All Vagrant configuration is done below. The "2" in Vagrant.configure configures the 
# configuration version (we support older styles for backwards compatibility). Please don't
# change it unless you know what you're doing.
Vagrant.configure( "2" ) do | config |
  # The most common configuration options are documented and commented below. For a complete
  # reference, please see the online documentation at https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for boxes at 
  # https://vagrantcloud.com/search.
  config.vm.box = "benlumia007/sandbox"

  # setup.sh or custom.sh
  #
  # By default, the Vagrantfile is set to use the setup.sh bash script which is located in
  # the provision directory. If custom.sh is detected when created manually, then it will
  # use custom.sh as a replacement.
  if File.exists?( File.join( vagrant_dir,'provision','custom.sh' ) ) then
    config.vm.provision "custom", type: "shell", path: File.join( "provision", "custom.sh" )
  else
    config.vm.provision "default", type: "shell", path: File.join( "provision", "setup.sh" )
  end
end
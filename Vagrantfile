# -*- mode: ruby -*-
# vi: set ft=ruby :
# In order to add hosts to virtual box, please run :
# vagrant up
# In order to connect to the server
# ssh vagrant@192.168.33.10
# password is vagrant

current_version = Gem::Version.new(Vagrant::VERSION)
windows_version = Gem::Version.new("1.6.0")

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Vagrant file for Modern IE (https://www.modern.ie/en-us) boxes
  # This file is for Windown 7 running IE9, but there are other possibilities.
  # NB: Vagrant wants to ssh into the VM, but these VMs don't have ssh.  So,
  # you'll get a timeout error message, which is safe to ignore.
   
  # To use a different box, replace the config.vm.box_url with the URL and
  # update the config.vm.box to some name you want to refer to it as.
  #
  # XP with IE6: http://aka.ms/vagrant-xp-ie6
  # XP with IE8: http://aka.ms/vagrant-xp-ie8
  # Vista with IE7: http://aka.ms/vagrant-vista-ie7
  # Windows 7 with IE8: http://aka.ms/vagrant-win7-ie8
  # Windows 7 with IE9: http://aka.ms/vagrant-win7-ie9
  # Windows 7 with IE10: http://aka.ms/vagrant-win7-ie10
  # Windows 7 with IE11: http://aka.ms/vagrant-win7-ie11
  # Windows 8 with IE10: http://aka.ms/vagrant-win8-ie10
  # Windows 8.1 with IE11: http://aka.ms/vagrant-win81-ie11
  #config.vm.box_url = "http://aka.ms/vagrant-win7-ie9"
  #config.vm.box = "Win7-ie9"

  #Windows server 2012
  #
  #in order to export VM as a vagrant image do the following:
  #vagrant package --base 'vagrant-windows-2012'
  config.vm.define "vagrant-windows-2012"
  config.vm.box = "opentable/win-2012r2-standard-amd64-nocm"  
  #config.vm.box_url = "https://vagrantcloud.com/opentable/boxes/win-2012r2-standard-amd64-nocm/versions/1.0.0/providers/virtualbox.box"
  config.vm.hostname = "vagrant-windows-2012"
  config.vm.boot_timeout = 600
  
  #config.windows.set_work_network = true
  
  # Set local user details if default vagrant/vagrant isn't used
  #config.winrm.username = "**"
  #config.winrm.password = "**"
  ## Admin user name and password
  config.winrm.username = "vagrant"
  config.winrm.password = "Motdepasse12"
  
  if current_version < windows_version
    if !Vagrant.has_plugin?('vagrant-windows')
      puts "vagrant-windows missing, please install the vagrant-windows plugin!"
      puts "Run this command in your terminal:"
      puts "vagrant plugin install vagrant-windows"
      exit 1
    end
  
    # Admin user name and password
    #config.winrm.username = "vagrant"
    #config.winrm.password = "vagrant"
  
    config.vm.guest = :windows
    config.windows.halt_timeout = 15
  
    # Port forward WinRM and RDP
    config.vm.network :forwarded_port, guest: 5985, host: 5985, id: "winrm", auto_correct: true
    config.vm.network :forwarded_port, guest: 3389, host: 3389, id: "rdp", auto_correct: true
    config.vm.network :forwarded_port, guest: 22, host: 2222, id: "ssh", auto_correct: true
  else
    config.vm.communicator = "winrm"
    #config.winrm.timeout = 500
  end
  
  config.vm.provider :virtualbox do |v, override|
      v.gui = true
      v.name = "vagrant-windows-2012"
      v.customize ["modifyvm", :id, "--memory", 2048]
      v.customize ["modifyvm", :id, "--cpus", 2]
      v.customize ["setextradata", "global", "GUI/SuppressMessages", "all" ]
  end
  
  config.vm.provision "ansible" do |ansible|
   #see https://docs.vagrantup.com/v2/provisioning/ansible.html
   ansible.playbook = "windows.yml"
   ansible.inventory_path = "hosts"
   ansible.verbose = "vvvv"
   ansible.sudo = true
   ansible.host_key_checking = false
   #ansible.extra_vars = { ansible_ssh_user: 'IEUser',
   #                       ansible_ssh_pass: 'Passw0rd!',
   #                       ansible_ssh_port: '55985' }   
   ansible.extra_vars = { ansible_ssh_user: 'vagrant',
                          ansible_ssh_pass: 'Motdepasse12',
                          ansible_ssh_port: '55985' }
   # Disable default limit (required with Vagrant 1.5+)
   ansible.limit = 'all'
  end

  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  #config.vm.box = "base"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  # config.vm.box_url = "http://domain.com/path/to/above.box"

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network :forwarded_port, guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network :private_network, ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network :public_network

  # If true, then any SSH connections made will enable agent forwarding.
  # Default value: false
  # config.ssh.forward_agent = true

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider :virtualbox do |vb|
  #   # Don't boot with headless mode
  #   vb.gui = true
  #
  #   # Use VBoxManage to customize the VM. For example to change memory:
  #   vb.customize ["modifyvm", :id, "--memory", "1024"]
  # end
  #
  # View the documentation for the provider you're using for more
  # information on available options.

  # Enable provisioning with Puppet stand alone.  Puppet manifests
  # are contained in a directory path relative to this Vagrantfile.
  # You will need to create the manifests directory and a manifest in
  # the file base.pp in the manifests_path directory.
  #
  # An example Puppet manifest to provision the message of the day:
  #
  # # group { "puppet":
  # #   ensure => "present",
  # # }
  # #
  # # File { owner => 0, group => 0, mode => 0644 }
  # #
  # # file { '/etc/motd':
  # #   content => "Welcome to your Vagrant-built virtual machine!
  # #               Managed by Puppet.\n"
  # # }
  #
  # config.vm.provision :puppet do |puppet|
  #   puppet.manifests_path = "manifests"
  #   puppet.manifest_file  = "site.pp"
  # end

  # Enable provisioning with chef solo, specifying a cookbooks path, roles
  # path, and data_bags path (all relative to this Vagrantfile), and adding
  # some recipes and/or roles.
  #
  # config.vm.provision :chef_solo do |chef|
  #   chef.cookbooks_path = "../my-recipes/cookbooks"
  #   chef.roles_path = "../my-recipes/roles"
  #   chef.data_bags_path = "../my-recipes/data_bags"
  #   chef.add_recipe "mysql"
  #   chef.add_role "web"
  #
  #   # You may also specify custom JSON attributes:
  #   chef.json = { :mysql_password => "foo" }
  # end

  # Enable provisioning with chef server, specifying the chef server URL,
  # and the path to the validation key (relative to this Vagrantfile).
  #
  # The Opscode Platform uses HTTPS. Substitute your organization for
  # ORGNAME in the URL and validation key.
  #
  # If you have your own Chef Server, use the appropriate URL, which may be
  # HTTP instead of HTTPS depending on your configuration. Also change the
  # validation key to validation.pem.
  #
  # config.vm.provision :chef_client do |chef|
  #   chef.chef_server_url = "https://api.opscode.com/organizations/ORGNAME"
  #   chef.validation_key_path = "ORGNAME-validator.pem"
  # end
  #
  # If you're using the Opscode platform, your validator client is
  # ORGNAME-validator, replacing ORGNAME with your organization name.
  #
  # If you have your own Chef Server, the default validation client name is
  # chef-validator, unless you changed the configuration.
  #
  #   chef.validation_client_name = "ORGNAME-validator"
end

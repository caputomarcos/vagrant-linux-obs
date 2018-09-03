# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  # Box Dist
  config.vm.box = "ubuntu/xenial64"

  # Disk Size
  config.disksize.size = '20GB'

  # Network Host Name
  config.vm.hostname = "ubuntu-osb"

  # Private Ip Address
  config.vm.network "private_network", ip: "192.168.33.144"
  config.vm.network :forwarded_port, guest: 22, host: 2223, host_ip: "0.0.0.0", id: "ssh", auto_correct: true

  # VM customize Settings
  config.vm.provider :virtualbox do |vb|
    # Use VBoxManage to customize the VM
    vb.auto_nat_dns_proxy = false
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "off"]
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "off"]
    vb.memory = 4069
    vb.cpus = 2
    vb.gui = false
  end

  # fix-no-tty
  config.vm.provision "fix-no-tty", type: "shell" do |s|
    s.privileged = false
    s.inline = "sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile"
  end

  # git curl puppet apt-transport-https ca-certificates software-properties-common
  config.ssh.forward_agent = false
  config.vm.provision "shell", inline: <<-SHELL
    sudo apt-get update
    sudo apt-get install -y git curl puppet apt-transport-https ca-certificates software-properties-common
  SHELL

  # Install sdkman
  config.vm.provision "shell", privileged: false, inline: "curl -s http://get.sdkman.io | bash"
  config.vm.provision "shell", privileged: false, inline: "source '/home/vagrant/.sdkman/bin/sdkman-init.sh' && yes | sdk selfupdate force"
  config.vm.provision "shell", privileged: false, inline: "source '/home/vagrant/.sdkman/bin/sdkman-init.sh' && yes | sdk install java 6.0.113-zulu"
  config.vm.provision "shell", privileged: false, inline: "source '/home/vagrant/.sdkman/bin/sdkman-init.sh' && yes | sdk use java 6.0.113-zulu"
  config.vm.provision "shell", privileged: false, inline: "source '/home/vagrant/.sdkman/bin/sdkman-init.sh' && yes | sdk default java 6.0.113-zulu"

  # Forward Oracle port
  config.vm.network :forwarded_port, guest: 7001, host: 7001
  config.vm.network :forwarded_port, guest: 7002, host: 7002
  # config.vm.network :forwarded_port, guest: 8453, host: 8453
  # config.vm.network :forwarded_port, guest: 7453, host: 7453

  # Forward Redis port
  config.vm.network :forwarded_port, guest: 6379, host: 26379

  # Forward Mongo port
  config.vm.network :forwarded_port, guest: 27017, host: 27017

  # Run Redis & Mongo
  config.vm.provision "docker" do |d|
    d.pull_images 'redis'
    d.pull_images 'mongo'

    d.run 'redis', args: "-p 6379:26379", name: 'redis'
    d.run 'mongo', args: "-p 27017:27017", name: 'mongo'
  end

  # Others Settings
  config.vbguest.auto_update = false
  # config.vm.synced_folder "deploy/", "/home/vagrant"


  config.git.add_repo do |rc|
    rc.target = 'https://github.com/Learnosity/vagrant-git.git'
    rc.path = '/tmp/vagrant-git'
    rc.branch = 'master'
    rc.clone_in_host = true
  end

  # Run Puppet
  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "manifests"
    puppet.module_path = "modules"
    puppet.manifest_file = "site.pp"
    puppet.options = "--verbose --trace"
  end

  # Get Project Source Code
  # config.git.add_repo do |rc|
  #   rc.target = 'https://github.com/chiroito/weblogic-jee-quickstart'
  #   rc.path = '/tmp'
  #   rc.branch = 'master'
  #   rc.clone_in_host = true
  # end

end

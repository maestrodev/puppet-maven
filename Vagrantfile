# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "CentOS-6.4-x86_64-minimal"

  config.vm.synced_folder ".", "/etc/puppet/modules/maven"
  config.vm.synced_folder "spec/fixtures/modules/wget", "/etc/puppet/modules/wget"
  config.vm.synced_folder "lib/facter", "/var/lib/puppet/lib/facter"

  # install the java module
  config.vm.provision :shell, :inline => "test -d /etc/puppet/modules/java || puppet module install puppetlabs/java -v 1.0.1"

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "tests"
    puppet.manifest_file  = "init.pp"
  end

  config.vm.define :centos63 do |config|
    config.vm.box = "CentOS-6.3-x86_64-minimal"
    config.vm.box_url = "https://repo.maestrodev.com/archiva/repository/public-releases/com/maestrodev/vagrant/CentOS/6.3/CentOS-6.3-x86_64-minimal.box"
  end

  config.vm.define :centos64 do |config|
    config.vm.box = "CentOS-6.4-x86_64-minimal"
    config.vm.box_url = "https://repo.maestrodev.com/archiva/repository/public-releases/com/maestrodev/vagrant/CentOS/6.4/CentOS-6.4-x86_64-minimal.box"
  end
end

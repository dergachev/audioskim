# vi: set ft=ruby :

# see https://github.com/mitchellh/vagrant/issues/143#issuecomment-14781762
require_relative "vagrant-snapshot.rb"

Vagrant::Config.run do |config|
  config.vm.box = "precise64"
  config.vm.forward_port 9093, 9093 # guest, host
  config.ssh.forward_agent = true

  config.vm.provision :shell, :inline => "apt-get -y install vim git curl"
  config.vm.provision :shell, :inline => "apt-get -y install ffmpeg"

  # config.vm.provision :snapshot, :label => "CLEAN"
  # next # break out of provisioning, to facilitate running 'vagrant snap take LABEL'

  # partial run, for snapshot (eg `vagrant snap take RVM`)
  #
  # config.vm.provision :chef_solo do |chef|
  #   chef.provisioning_path = "/tmp/chef1"
  #   chef.cookbooks_path = ["cookbooks","site-cookbooks"]

  #   chef.add_recipe "apt::default"
  #   chef.add_recipe "passenger_rvm::rvm"
  # end
  # config.vm.provision :snapshot, :label => "RVM"
  # next # break out of provisioning, to facilitate running 'vagrant snap take LABEL'
  
  # full run
  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = ["cookbooks","site-cookbooks"]
    chef.provisioning_path = "/tmp/chef2"
    chef.add_recipe "passenger_rvm"
  end

end

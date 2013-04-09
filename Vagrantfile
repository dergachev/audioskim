# vi: set ft=ruby :

# see https://github.com/mitchellh/vagrant/issues/143#issuecomment-14781762
require_relative "vagrant-snapshot.rb"

Vagrant::Config.run do |config|
  ## Consider packaging a customized vagrant box, pre-provisioned with vim, user
  ## accounts, etc (see https://gist.github.com/3866825):
  # config.vm.box = "precise64-customized"
  config.vm.box = "precise64-rm-deps"

  config.vm.forward_port 9093, 9093 # guest, host

  config.ssh.forward_agent = true

  #necessary for runit error https://github.com/opscode-cookbooks/runit/pull/23
  #config.vm.provision :shell, :inline => "gem update chef"

  # get vim in there
  config.vm.provision :shell, :inline => "apt-get -y install vim git curl"

  config.vm.provision :chef_solo do |chef|

    chef.cookbooks_path = ["cookbooks","site-cookbooks"]
    chef.json = {
      # 'rvm_passenger' => {
      #   'global_gemset' => 'ruby-1.8.7-p330',
      #   'app_gemset' => 'ruby-1.8.7-p330@audioskim',
      }
    }

    chef.add_recipe "passenger_rvm"

  end

  # next # break out of provisioning, to facilitate running 'vagrant snap take LABEL'

  config.vm.provision :shell, :inline => <<-EOT
    cd /vagrant/www-root
    mkdir -p public/files # for uploads
    # rvm create ruby-1.8.7-p330@audioskim
    bundle install
    sequel -m db/migrations sqlite://db/audioskim.db

    service nginx restart

    # install ffmpeg for transcoding mp3 to flac
    # apt-get -y install ffmpeg
  EOT
end

include_attribute "rvm" # ensure that any foreign attributes we read are included first

# TODO: clean this up
if "#{node['languages']['ruby']['bin_dir']}" =~ /^.*rvm\/rubies\/(.*)\/bin$/
  # default['passenger_rvm']['global_gemset'] = 'ruby-1.8.7-p330'
  # default['passenger_rvm']['app_gemset'] = 'ruby-1.8.7-p330@audioskim'
  default['passenger_rvm']['global_gemset'] = $~[1]
  default['passenger_rvm']['app_gemset'] = "#{$~[1]}@audioskim"
elsif rvm_ruby = node['rvm']['default_ruby']
  default['passenger_rvm']['global_gemset'] = rvm_ruby
  default['passenger_rvm']['app_gemset'] = "#{rvm_ruby}@audioskim"
else
  raise "No RVM detected"
end

# Workaround for rvm::vagrant bug https://github.com/fnichol/chef-rvm/issues/121
node.set['rvm']['vagrant']['system_chef_solo']  = '/opt/vagrant_ruby/bin/chef-solo'

# required to get bluepill, passenger to install to right gemset 
node.set['rvm']['gem_package']['rvm_string']  = node['passenger_rvm']['global_gemset']

#configures nginx cookbook
node.set['nginx']['install_method'] = 'source'
node.set['nginx']['init_style'] = 'bluepill'  #runit was giving me lots of trouble, eg https://github.com/opscode-cookbooks/runit/pull/23
node.set['nginx']['source']['modules'] = ['passenger']  
node.set['nginx']['passenger']['ruby'] = "/usr/local/rvm/wrappers/#{node['passenger_rvm']['app_gemset']}/ruby"
node.set['nginx']['passenger']['gem_binary'] = "/usr/local/rvm/rubies/#{node['passenger_rvm']['global_gemset']}/bin/gem"

default['passenger_rvm']['nginx_port'] = '9093'
default['passenger_rvm']['app_path'] = '/vagrant/www-root'
default['passenger_rvm']['nginx_public'] = "#{node['passenger_rvm']['app_path']}/public"

# since we override rvm and nginx attributes, ensure chef loads them first
include_attribute "rvm"
include_attribute "nginx::source"

if "#{node['languages']['ruby']['bin_dir']}" =~ /^.*rvm\/rubies\/(.*)\/bin$/
  # default['passenger_rvm']['global_gemset'] = 'ruby-1.8.7-p330'
  # default['passenger_rvm']['app_gemset'] = 'ruby-1.8.7-p330@audioskim'
  default['passenger_rvm']['global_gemset'] = $~[1]
  default['passenger_rvm']['app_gemset'] = "#{$~[1]}@audioskim"
else
  raise "No RVM detected"
end

# Workaround for rvm::vagrant bug https://github.com/fnichol/chef-rvm/issues/121
default['rvm']['vagrant']['system_chef_solo']  = '/opt/vagrant_ruby/bin/chef-solo'

# required to get bluepill, passenger to install to right gemset 
default['rvm']['gem_package']['rvm_string']  = node['passenger_rvm']['global_gemset']

#configures nginx cookbook
default['nginx']['install_method'] = 'source'
default['nginx']['init_style'] = 'bluepill'  #runit was giving me lots of trouble
default['nginx']['source']['modules'] = ['passenger']  #runit was giving me lots of trouble
default['nginx']['passenger']['ruby'] = "/usr/local/rvm/wrappers/#{node['passenger_rvm']['app_gemset']}/ruby"
default['nginx']['passenger']['gem_binary'] = "/usr/local/rvm/rubies/#{node['passenger_rvm']['global_gemset']}/bin/gem"
# default['nginx']['passenger']['root'] = "/usr/local/rvm/gems/#{default['passengerglobal_gemset}/gems/passenger-3.0.19", #should be same as default


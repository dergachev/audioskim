include_recipe "rvm::system" # install the default ruby

include_recipe "rvm::default" # required to avoid https://github.com/fnichol/chef-rvm/issues/141
include_recipe "rvm::vagrant" 
include_recipe "rvm::gem_package" # makes gem_package resource respect RVM

# create the default gemset for the application
rvm_gemset node['passenger_rvm']['app_gemset']

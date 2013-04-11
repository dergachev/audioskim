include_recipe "rvm::vagrant" 
include_recipe "rvm::system" # install the default ruby

# only required if not running rvm::system or rvm::system_install 
# required to avoid https://github.com/fnichol/chef-rvm/issues/141
## include_recipe "rvm::default" 

include_recipe "rvm::gem_package" # makes gem_package resource respect RVM

# create the default gemset for the application
rvm_gemset node['passenger_rvm']['app_gemset']

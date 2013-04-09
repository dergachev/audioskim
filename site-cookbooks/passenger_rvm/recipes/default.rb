#
# Cookbook Name:: passenger_rvm
# Recipe:: default
#
# Author:: Alex Dergachev (<alex@evolvingweb.ca>)
#
# Copyright 2013, Alex Dergachev
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "apt::default"

include_recipe "rvm::default" # required to avoid https://github.com/fnichol/chef-rvm/issues/141
include_recipe "rvm::vagrant" 
include_recipe "rvm::gem_package" # makes gem_package resource respect RVM

include_recipe "passenger_rvm::bluepill"

include_recipe "nginx" # loads the default recipe

# guard against mysterious attribute overriding behavior (fail early)
raise "TRYING TO INSTALL NGINX FROM PACKAGE" unless node['nginx']['install_method'] == 'source'

# workaround to make nginx::passenger compatible with RVM
# adapted from https://github.com/substantial/cookbook-nginx/blob/master/recipes/rvm_passenger.rb#L51
# otherwise nginx compilation will trigger passenger compilation, without rvmsudo
rvm_shell "compile_passenger_support_files" do
  action :nothing
  subscribes :run, resources('gem_package[passenger]'), :immediately
  ruby_string node['passenger_rvm']['global_gemset']
  user "root"
  code <<-CODE
    cd `passenger-config --root`
    rake nginx RELEASE=yes
  CODE
  creates "#{node["nginx"]["passenger"]["root"]}/ext/common/libpassenger_common.a"
end

template "#{node.nginx.dir}/sites-available/passenger.conf" do
  source "nginx.conf.erb"
  mode "0644"
end

nginx_site "passenger.conf"

rvm_shell "run_bundle_install" do
  cwd "/vagrant/www-root"
  code "bundle install"
  ruby_string node['passenger_rvm']['app_gemset']
  notifies :restart, 'service[nginx]'
  not_if 
end

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

include_recipe "passenger_rvm::rvm"
include_recipe "passenger_rvm::bluepill"
include_recipe "passenger_rvm::nginx"

template "#{node.nginx.dir}/sites-available/passenger.conf" do
  source "nginx.conf.erb"
  mode "0644"
end

nginx_site "passenger.conf"

file '.ruby-version' do 
  content node['passenger_rvm']['app_gemset']
  path "#{node['passenger_rvm']['app_path']}/.ruby-version"
end

rvm_shell "run_bundle_install" do
  code "bundle install"
  cwd node['passenger_rvm']['app_path']
  ruby_string node['passenger_rvm']['app_gemset']
  notifies :restart, 'service[nginx]'
  not_if "bundle check", :cwd => "/vagrant/www-root"
end

rvm_shell "initialize-audioskim-site" do
  code <<-EOT
    mkdir -p public/files
    sequel -m db/migrations sqlite://db/audioskim.db 
  EOT
  ruby_string node['passenger_rvm']['app_gemset']
  cwd node['passenger_rvm']['app_path']
end

log("SUCCESS: site deployed at http://localhost:#{node['passenger_rvm']['nginx_port']}")

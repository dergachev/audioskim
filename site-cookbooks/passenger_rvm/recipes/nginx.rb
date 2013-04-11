include_recipe "nginx" # loads the default recipe

# guard against mysterious attribute overriding behavior (fail early)
raise "TRYING TO INSTALL NGINX FROM PACKAGE" unless node['nginx']['install_method'] == 'source'

# workaround to make nginx::passenger compatible with RVM
# adapted from https://github.com/substantial/cookbook-nginx/blob/master/recipes/rvm_passenger.rb#L51
# otherwise nginx compilation will trigger passenger compilation, without rvmsudo, and errors:
#   *** Running 'rake nginx RELEASE=yes' in /usr/local/rvm/gems/ruby-1.8.7-p330/gems/passenger-3.0.19/ext/nginx... ***
#   STDERR: /usr/local/rvm/rubies/ruby-1.8.7-p330/lib/ruby/site_ruby/1.8/rubygems/dependency.rb:247:in `to_specs': Could not find rake (>= 0) amongst [] (Gem::LoadError)
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

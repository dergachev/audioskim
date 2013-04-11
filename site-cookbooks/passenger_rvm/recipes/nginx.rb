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

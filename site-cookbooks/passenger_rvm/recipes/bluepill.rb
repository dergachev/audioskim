Chef::Log.info("Installing workaround for https://github.com/opscode-cookbooks/bluepill/pull/6")

node.set['bluepill']['bin'] = "/usr/local/rvm/wrappers/#{node['passenger_rvm']['global_gemset']}/bluepill"

include_recipe "bluepill" # install this after RVM but before nginx::source

# NOTE: the following code surpisingly threw an error.
#   Code:
#     execute "creating_bluepill_wrapper" do
#       command "rvm wrapper #{node["passenger_rvm"]["global_gemset"]} bootup bluepill"
#       not_if "which bootup_bluepill"
#     end
#   Error:
#      FATAL: Errno::ENOENT: execute[creating_bluepill_wrapper] (passenger_rvm::bluepill line 7) had an error: 
#      Errno::ENOENT: No such file or directory - rvm wrapper ruby-1.9.3-p327 bootup bluepill
#   The error would only appear when doing "vagrant destroy --force && vagrant up",
#   but went away on subsequent "vagrant provision" calls. I suspect it has to do with rvm
#   not yet being available in the root shell that chef-solo is running in.
rvm_shell "creating_bluepill_wrapper" do
  code "rvm wrapper #{node["passenger_rvm"]["global_gemset"]} bootup bluepill"
  not_if "which bootup_bluepill"
end

# Interactively discovered this error: 
#   vagrant ssh
#   rvm wrapper ruby-1.9.3-p327 bootup bluepill
#     =>  No bin path suitable for lining wrapper. Try setting 'rvm_bin_path'
#   groups vagrant | grep rvm
#     => does not include rvm
# workaround found via http://tickets.opscode.com/browse/CHEF-3474
node.set['rvm']['group_users'] = ['vagrant']

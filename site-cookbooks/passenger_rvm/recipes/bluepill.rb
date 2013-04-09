# workaround for bluepill bug https://github.com/opscode-cookbooks/bluepill/pull/6

Chef::Log.info("Installing workaround for https://github.com/opscode-cookbooks/bluepill/pull/6")

# workaround for bluepill bug https://github.com/opscode-cookbooks/bluepill/pull/6
node.set['bluepill']['bin'] = "/usr/local/rvm/wrappers/#{node['passenger_rvm']['global_gemset']}/bluepill"

include_recipe "bluepill" # install this after RVM but before nginx::source

execute "creating_bluepill_wrapper" do
  command "rvm wrapper #{node["passenger_rvm"]["global_gemset"]} bootup bluepill"
  not_if "which bootup_bluepill"
end

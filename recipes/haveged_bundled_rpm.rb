# We have to install haveged from a bundled RPM on el 5 platforms since it is not in any el 5 package repository

cookbook_file "#{Chef::Config[:file_cache_path]}/haveged.rpm" do
  source "haveged-1.3-2.2.#{node['kernel']['machine']}.rpm"
  action :create
end

rpm_package 'Install haveged from bundled RPM' do
  source "#{Chef::Config[:file_cache_path]}/haveged.rpm"
  action :install
end

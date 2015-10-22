# This is used for most of the systemd platforms too, except for platforms that have really old systemd
def start_sys_v_haveged_service
  service 'haveged' do
    action :start
  end
end

# Some old versions of systemd won't let you use the shorthand for the unit name
def start_systemd_haveged_service
  service 'haveged.service' do
    action :start
  end
end

def install_debian
  # Update apt if we are on debian
  include_recipe 'apt'
  package 'haveged'
  start_sys_v_haveged_service
end

def install_rhel_from_epel
  # Make sure yum has access to the epel packages
  include_recipe 'yum-epel'
  package 'haveged'
end

def install_rhel_from_bundled_rpm
  include_recipe 'entropy::haveged_bundled_rpm'
end

def install_rhel
  # TODO Some linuxes in the rhel family like scientific and amazon don't use the same version
  # numbers and so this trick won't work.
  if node['platform_version'].to_i == 5
    # There is no haveged package in epel for el 5.x
    install_rhel_from_bundled_rpm
  else
    install_rhel_from_epel
  end
  start_sys_v_haveged_service
end

def install_fedora
  package 'haveged'
  start_sys_v_haveged_service
end

def install_suse
  package 'haveged'
  if node['platform_version'].to_i < 12
    start_sys_v_haveged_service
  else
    start_systemd_haveged_service
  end
end

if node['platform_family'] == 'rhel'
  install_rhel
elsif node['platform_family'] == 'debian'
  install_debian
elsif node['platform_family'] == 'fedora'
  install_fedora
elsif node['platform_family'] == 'suse'
  install_suse
elsif node['platform_family'].nil?
  # If ohai couldn't figure out the platform family, we will just have to try to do the best we can with the platform
  # ohai has never given us a nil platform family in the wild, but fauxhai data does have json files with no platform_family.

  # If platform_family and platform are both nil, then we are screwed
  Chef::Application.fatal!('Unable to determine platform_family or platform') if node['platform'].nil?

  # This is roughly the rhel platform family
  install_rhel if %w(redhat oracle centos amazon scientific).include?(node['platform'])
  # This is roughly the debian platform family
  install_debian if %w(debian ubuntu linuxmint).include?(node['platform'])
  install_fedora if node['platform'] == 'fedora'
  install_suse if node['platform'] == 'suse'
end

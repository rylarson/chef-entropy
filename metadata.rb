name             'entropy'
maintainer       'Ryan Larson'
maintainer_email 'ryan.mango.larson@gmail.com'
license          'MIT'
description      'Ensures a good source of entropy'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.0'

depends 'yum-epel', '<= 0.6.0'
depends 'apt', '>= 0.0.0'

supports 'ubuntu', '>= 12.04'
supports 'debian', '>= 7.0'
supports 'centos', '>= 5.0'
supports 'oracle', '>= 5.0'
# We claim rhel support because we work on CentOS but we don't have the ability to test on rhel
supports 'redhat', '>= 5.0'
supports 'fedora', '>= 18.0'
supports 'suse', '>= 12.2'

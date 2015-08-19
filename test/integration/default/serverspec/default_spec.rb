require 'serverspec'

set :backend, :exec
set :path, '/sbin:$PATH'

describe package('haveged') do
  it { should be_installed }
end

describe service('haveged') do
  it { should be_running }
end

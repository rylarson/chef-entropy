require 'chefspec'
require 'chefspec/berkshelf'
require 'json'
require 'set'

# ChefSpec uses fauxhai to mock ohai data to trick chef into thinking it is on a different platform.

# return all of the versions of the given platform that the currently installed fauxhai has mock data for
def mock_versions_for_platform(platform)
  # This is adapted from Fauxhai::Mocker::platform_path
  Dir.glob(File.join(Fauxhai.root, "**/#{platform}/*.json")).map { |it| File.basename(it, '.json') }
end

# return all of the platforms belonging to the given platform_family that the currently installed fauxhai has mock data for
def mock_platforms_for_family(platform_family)
  platforms = Set.new
  Dir.glob(File.join(Fauxhai.root, "**/*.json")).each do |fauxhai_json_file|
    fauxhai_json = JSON.parse(File.read(fauxhai_json_file))
    fauxhai_platform_family = fauxhai_json['platform_family']
    if fauxhai_platform_family && fauxhai_platform_family.to_sym == platform_family.to_sym
      platforms.add(fauxhai_json['platform'])
    end
  end
  platforms
end

# build an array of {:platform => 'platform', :version => 'version'} hashes for every version of each platform in the given family
def mock_platform_to_version_map_for_family(platform_family)
  mock_platforms_for_family(platform_family).map { |platform| [mock_versions_for_platform(platform).map { |v| {:platform => platform, :version => v} }] }.flatten
end

def debian_family_platforms
  mock_platform_to_version_map_for_family('debian')
end

def rhel_family_platforms
  mock_platform_to_version_map_for_family('rhel')
end

def fedora_family_platforms
  mock_platform_to_version_map_for_family('fedora')
end

def suse_family_platforms
  mock_platform_to_version_map_for_family('suse')
end

describe 'entropy::default' do
  subject(:chef_run) do
    ChefSpec::SoloRunner.new(platform).converge(described_recipe)
  end

  context 'on debian family' do
    debian_family_platforms.each do |debian_platform|
      context "on #{debian_platform[:platform]} #{debian_platform[:version]}" do
        let(:platform) { debian_platform }
        it { is_expected.to include_recipe('apt::default') }
        it { is_expected.to install_package('haveged') }
        it { is_expected.to start_service('haveged') }
      end
    end
  end

  context 'on rhel family' do
    rhel_family_platforms.each do |rhel_platform|
      context "on #{rhel_platform[:platform]} #{rhel_platform[:version]}" do
        let(:platform) { rhel_platform }
        # We have to install from a bundled rpm on el 5.x
        if rhel_platform[:version].to_i == 5
          it { is_expected.to include_recipe('entropy::haveged_bundled_rpm') }
          it { is_expected.to start_service('haveged') }
        else
          it { is_expected.to include_recipe('yum-epel::default') }
          it { is_expected.to install_package('haveged') }
          it { is_expected.to start_service('haveged') }
        end
      end
    end
  end

  context 'on fedora family' do
    fedora_family_platforms.each do |fedora_platform|
      context "on #{fedora_platform[:platform]} #{fedora_platform[:version]}" do
        let(:platform) { fedora_platform }
        it { is_expected.to install_package('haveged') }
        it { is_expected.to start_service('haveged') }
      end
    end
  end

  context 'on suse family' do
    suse_family_platforms.each do |suse_platform|
      context "on #{suse_platform[:platform]} #{suse_platform[:version]}" do
        let(:platform) { suse_platform }
        major_version = suse_platform[:version].split('.')[0].to_i
        it { is_expected.to install_package('haveged') }
        if major_version < 12
          it { is_expected.to start_service('haveged') }
        else
          it { is_expected.to start_service('haveged.service') }
        end
      end
    end
  end

end

require 'spec_helper'

shared_examples :maven_settings do |expected_file|

  def read_file(filename)
    IO.read(File.expand_path(filename, File.dirname(__FILE__)))
  end

  it { should contain_file(expected_filename).with_owner('u') }

  it 'should generate valid settings.xml' do
    should contain_file(expected_filename).with_content(read_file(expected_file))
  end
end

describe "maven::settings" do
  let(:title) { 'settings' }
  let(:params) { {
      :user => "u",
      :home => "/home/u",
  } }

  let(:url) { 'http://localhost:8082/archiva/repository/all/' }
  let(:mirror) {{
    'id' => 'maestro-mirror',
    'url' => url,
    'mirrorof' => 'external:*',
  }}
  let(:mirror_server) {{
    'id' => 'maestro-mirror',
    'username' => 'mirror_user',
    'password' => 'mirror_pass',
  }}
  let(:deploy_server) {{
    'id' => 'maestro-deploy',
    'username' => 'deploy_user',
    'password' => 'deploy_pass',
  }}
  let(:deploy_server_with_ssh) {{
    'id' => 'maestro-deploy-ssh',
    'username' => 'deploy_ssh_user',
    'privateKey' => '~/.ssh/id_rsa',
  }}
  let(:default_repo_config) {{
    'url' => url,
    'snapshots' => {
        'enabled' => 'true',
        'checksumPolicy' => 'fail',
    },
    'releases' => {
        'checksumPolicy' => 'fail',
    }
  }}
  let(:profiles) {{
    'profile1' => {
      'activation' => {
        'activeByDefault' => false,
        'jdk' => '1.5',
        'os' => {
          'name' => 'Windows XP',
          'family' => 'Windows',
          'arch' => 'x86',
          'version' => '5.1.2600'
        },
        'property' => {
          'name' => 'mavenVersion',
          'value' => '2.0.3'
        },
        'file' => {
          'exists' => '${basedir}/file2.properties',
          'missing' => '${basedir}/file1.properties'
        }
      },
      'repositories' => {
        'repo1' => {
          'name' => 'First Repo',
          'releases' => {
            'enabled' => true,
            'updatePolicy' => 'always',
            'checksumPolicy' => 'warn'
          },
          'snapshots' => {
            'enabled' => false,
            'updatePolicy' => 'never',
            'checksumPolicy' => 'fail'
          },
          'url' => 'http://repo1.example.com/maven2',
          'layout' => 'default'
        }
      },
      'plugin_repositories' => {
        'repo2' => {
          'name' => 'Second Repo',
          'releases' => {
            'enabled' => false,
            'updatePolicy' => 'never',
            'checksumPolicy' => 'fail'
          },
          'snapshots' => {
            'enabled' => true,
            'updatePolicy' => 'always',
            'checksumPolicy' => 'warn'
          },
          'url' => 'http://repo2.example.com/maven2',
          'layout' => 'legacy'
        }
      },
      'properties' => {
          'key1' => 'value1'
      }
    },
    'minimal_profile' => {
    }
  }}
  let(:active_profiles) {
    ['profile1', 'profile2']
  }
  let(:proxy) {{
    'active' => true,
    'protocol' => 'http',
    'host' => 'http://proxy.acme.com',
    'username' => 'myuser',
    'password' => 'mypassword',
    'nonProxyHosts' => 'www.acme.com',
  }}
  let(:properties) {{
    'sonar.jdbc.url' => 'jdbc:postgresql://localhost:5432/sonar',
    'sonar.jdbc.driverClassName' => 'org.postgresql.Driver',
    'sonar.jdbc.username' => 'user',
    'sonar.jdbc.password' => 'password',
    'sonar.host.url' => 'http://localhost:8083/sonar',
    'selenium.host' => 'localhost',
  }}

  let(:expected_filename) { '/home/u/.m2/settings.xml' }

  context "default", :compile do
    it_behaves_like :maven_settings, "default-settings.xml"
  end

  context "with empty default_repo_config", :compile do
    let(:params) {{
          :user => "u",
          :home => "/home/u",
          :default_repo_config => {},
      }}

    it_behaves_like :maven_settings, "default-settings.xml"
  end

  context "with mirrors and settings", :compile do
    let(:params) {{
          :user => "u",
          :home => "/home/u",
          :mirrors => [mirror],
          :servers => [mirror_server, deploy_server, deploy_server_with_ssh]
      }}

    it_behaves_like :maven_settings, "mirror-servers-settings.xml"
  end

  context "with default repository", :compile do
    let(:params) {{
          :user => "u",
          :home => "/home/u",
          :default_repo_config => default_repo_config,
      }}

    it_behaves_like :maven_settings, "default-repo-settings.xml"
  end

  context "with default repository configuration url only", :compile do
    let(:params) {{
          :user => "u",
          :home => "/home/u",
          :default_repo_config => {
              'url' => default_repo_config['url'],
          },
      }}

    it_behaves_like :maven_settings, "default-repo-only-url-settings.xml"
  end

  context "with properties", :compile do
    let(:params) {{
          :user => "u",
          :home => "/home/u",
          :properties => properties,
      }}

    it_behaves_like :maven_settings, "properties-settings.xml"
  end

  context "with local repository", :compile do
    let(:params) {{
          :user => "u",
          :home => "/home/u",
          :local_repo => "/var/cache/maven/repository",
      }}

    it_behaves_like :maven_settings, "local-repo-settings.xml"
  end

  context "with proxy", :compile do
    let(:params) {{
          :user => "u",
          :home => "/home/u",
          :proxies => [proxy],
      }}

    it_behaves_like :maven_settings, "proxy-settings.xml"
  end

  context "with the lot", :compile do
    let(:params) {{
          :user => "u",
          :home => "/home/u",
          :mirrors => [mirror],
          :servers => [mirror_server, deploy_server, deploy_server_with_ssh],
          :default_repo_config => default_repo_config,
          :properties => properties,
          :local_repo => "/var/cache/maven/repository",
      }}

    it_behaves_like :maven_settings, "complete-settings.xml"
  end

  context "with profiles", :compile do
    let(:params) {{
          :user => "u",
          :home => "/home/u",
          :profiles => profiles
      }}

    it_behaves_like :maven_settings, "profiles-settings.xml"
  end

  context "with active_profiles", :compile do
    let(:params) {{
          :user => "u",
          :home => "/home/u",
          :active_profiles => active_profiles
      }}

    it_behaves_like :maven_settings, "active-profiles-settings.xml"
  end
end

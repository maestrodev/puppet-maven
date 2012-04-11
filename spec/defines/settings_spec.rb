require "#{File.join(File.dirname(__FILE__),'..','spec_helper')}"

URL = 'http://localhost:8082/archiva/repository/all/'
MIRROR = {
    'id' => 'maestro-mirror',
    'url' => URL,
    'mirrorof' => 'external:*',
}
MIRROR_SERVER = {
    'id' => 'maestro-mirror',
    'username' => 'mirror_user',
    'password' => 'mirror_pass',
}
DEPLOY_SERVER = {
    'id' => 'maestro-deploy',
    'username' => 'deploy_user',
    'password' => 'deploy_pass',
}
DEFAULT_REPO_CONFIG = {
    'url' => URL,
    'snapshots' => {
        'enabled' => 'true',
        'checksumPolicy' => 'fail',
    },
    'releases' => {
        'checksumPolicy' => 'fail',
    }
}
PROPERTIES = {
    'sonar.jdbc.url' => 'jdbc:postgresql://localhost:5432/sonar',
    'sonar.jdbc.driverClassName' => 'org.postgresql.Driver',
    'sonar.jdbc.username' => 'user',
    'sonar.jdbc.password' => 'password',
    'sonar.host.url' => 'http://localhost:8083/sonar',
    'selenium.host' => 'localhost',
}

describe "maven::settings" do
  let(:title) { 'settings' }
  let(:params) { {
      :user => "u",
      :home => "/home/u",
  } }

  expected_filename = '/home/u/.m2/settings.xml'
  it { should contain_file(expected_filename).with_owner('u') }

  it 'should generate valid settings.xml' do
    content = catalogue.resource('file', expected_filename).send(:parameters)[:content]
    content.should == read_file("default-settings.xml")
  end

  context "with mirrors and settings" do
    let(:params) {
      {
          :user => "u",
          :home => "/home/u",
          :mirrors => [MIRROR],
          :servers => [MIRROR_SERVER, DEPLOY_SERVER]
      } }

    expected_filename = '/home/u/.m2/settings.xml'
    it { should contain_file(expected_filename).with_owner('u') }

    it 'should generate valid settings.xml when mirrors and servers are specified' do
      content = catalogue.resource('file', expected_filename).send(:parameters)[:content]
      content.should == read_file("mirror-servers-settings.xml")
    end
  end

  context "with default repository" do
    let(:params) {
      {
          :user => "u",
          :home => "/home/u",
          :default_repo_config => DEFAULT_REPO_CONFIG,
      } }

    expected_filename = '/home/u/.m2/settings.xml'
    it { should contain_file(expected_filename).with_owner('u') }

    it 'should generate valid settings.xml when default repository configuration is specified' do
      content = catalogue.resource('file', expected_filename).send(:parameters)[:content]
      content.should == read_file("default-repo-settings.xml")
    end
  end

  context "with default repository configuration url only" do
    let(:params) {
      {
          :user => "u",
          :home => "/home/u",
          :default_repo_config => {
              'url' => DEFAULT_REPO_CONFIG['url'],
          },
      } }

    expected_filename = '/home/u/.m2/settings.xml'
    it { should contain_file(expected_filename).with_owner('u') }

    it 'should generate valid settings.xml when default repository configuration is specified with only an url' do
      content = catalogue.resource('file', expected_filename).send(:parameters)[:content]
      content.should == read_file("default-repo-only-url-settings.xml")
    end

  end

  context "with properties" do
    let(:params) {
      {
          :user => "u",
          :home => "/home/u",
          :properties => PROPERTIES,
      } }

    expected_filename = '/home/u/.m2/settings.xml'
    it { should contain_file(expected_filename).with_owner('u') }

    it 'should generate valid settings.xml when properties are specified' do
      content = catalogue.resource('file', expected_filename).send(:parameters)[:content]
      content.should == read_file("properties-settings.xml")
    end

  end

  context "with local repository" do
    let(:params) {
      {
          :user => "u",
          :home => "/home/u",
          :local_repo => "/var/cache/maven/repository",
      } }

    expected_filename = '/home/u/.m2/settings.xml'
    it { should contain_file(expected_filename).with_owner('u') }

    it 'should generate valid settings.xml when local repository configuration is specified' do
      content = catalogue.resource('file', expected_filename).send(:parameters)[:content]
      content.should == read_file("local-repo-settings.xml")
    end

  end

  context "with the lot" do
    let(:params) {
      {
          :user => "u",
          :home => "/home/u",
          :mirrors => [MIRROR],
          :servers => [MIRROR_SERVER, DEPLOY_SERVER],
          :default_repo_config => DEFAULT_REPO_CONFIG,
          :properties => PROPERTIES,
          :local_repo => "/var/cache/maven/repository",
      } }

    expected_filename = '/home/u/.m2/settings.xml'
    it { should contain_file(expected_filename).with_owner('u') }

    it 'should generate valid settings.xml with everything specified' do
      content = catalogue.resource('file', expected_filename).send(:parameters)[:content]
      content.should == read_file("complete-settings.xml")
    end

  end
end

def read_file(filename)
  IO.read(File.expand_path(filename, File.dirname(__FILE__)))
end


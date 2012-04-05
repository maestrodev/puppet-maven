require "spec_helper"

MIRROR = {
    'id' => 'maestro-mirror',
    'url' => 'https://localhost:8082/archiva/repository/all/',
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
    content.should == read_settings_file("default-settings.xml")
  end
end

describe "maven::settings" do
  let(:title) { 'settings' }
  let(:params) {
    {
        :user => "u",
        :home => "/home/u",
        :mirrors => [MIRROR],
        :servers => [MIRROR_SERVER, DEPLOY_SERVER]
    } }

  expected_filename = '/home/u/.m2/settings.xml'
  it { should contain_file(expected_filename).with_owner('u') }

  it 'should generate valid settings.xml when mirrors and servers are nil' do
    content = catalogue.resource('file', expected_filename).send(:parameters)[:content]
    content.should == read_settings_file("mirror-servers-settings.xml")
  end

end

def read_settings_file(filename)
  IO.read(File.expand_path(filename, File.dirname(__FILE__)))
end


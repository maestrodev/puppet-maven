require "#{File.join(File.dirname(__FILE__),'..','spec_helper')}"

describe 'maven::maven' do
  let(:title) { 'maven' }
  let(:params) { { :user => 'myuser' } }

  context "when user does not exist" do
    it { should contain_user('myuser') }
  end

  context "when running as root" do
    it { should contain_file('/root/.mavenrc') }
  end

  context "when downloading maven" do
    it do should contain_wget__fetch('fetch-maven').with(
        'source'      => 'http://archive.apache.org/dist/maven/binaries/apache-maven-2.2.1-bin.tar.gz',
        'user'        => nil,
        'password'    => nil
    ) end
  end

  context "when downloading maven from another repo" do
    let(:params) { { :user => 'myuser', :repo => {
        'url'      => 'http://repo1.maven.org/maven2',
        'username' => 'u',
        'password' => 'p'
      }
    } }

    it do should contain_wget__authfetch('fetch-maven').with(
        'source'      => 'http://repo1.maven.org/maven2/org/apache/maven/apache-maven/2.2.1/apache-maven-2.2.1-bin.tar.gz',
        'user'        => 'u',
        'password'    => 'p'
    ) end
  end
end

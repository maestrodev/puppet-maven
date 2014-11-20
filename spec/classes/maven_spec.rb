require 'spec_helper'

describe 'maven::maven' do
  let(:title) { 'maven' }

  context "when downloading maven", :compile do
    it do should contain_exec('install_maven').with(
        'command'     => 'wget -O - http://archive.apache.org/dist/maven/binaries/apache-maven-3.0.5-bin.tar.gz | tar zxf -'
    ) end
    it 'should fetch maven before managing symlink' do
      should contain_exec('install_maven').that_comes_before('File[/usr/bin/mvn]')
    end
  end

  context "when downloading maven from another repo", :compile do
    let(:params) { { :repo => {
        'url'      => 'http://repo1.maven.org/maven2',
        'username' => 'u',
        'password' => 'p'
      }
    } }

    it 'should fetch maven with username and password' do
      should contain_exec('install_maven').with(
        'command'     => 'wget -O - --user="u" --password="p" http://repo1.maven.org/maven2/org/apache/maven/apache-maven/3.0.5/apache-maven-3.0.5-bin.tar.gz | tar zxf -'
      )
    end
  end

  context "when installing maven from os package repository", :compile do
    let(:params) { {
      :system_package => 'maven-package',
      :version => 'present'
    } }

    it 'should contain package resource' do
      should contain_package('maven-package').with(
        :ensure => 'present'
      )
    end

    it 'should not fetch maven from tar gz' do
      should_not contain_exec('install_maven')
    end

    it 'should install package before symlink' do
      should contain_package('maven-package').that_comes_before('File[/usr/bin/mvn]')
    end
  end

  context "when not managing symlink", :compile do
    let(:params) { {
      :manage_symlink => false
    } }

    it 'should not manage symlink' do
      should_not contain_file('/usr/bin/mvn')
      should_not contain_file('/usr/local/bin/mvn')
    end
  end

  context "when managing custom symlink", :compile do
    let(:params) { {
      :symlink_target => '/custom/bin/mvn'
    } }

    it 'should manage symlink target' do
      should contain_file('/usr/bin/mvn').with(
        :target => '/custom/bin/mvn'
      )
    end
  end

end

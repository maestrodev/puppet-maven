require 'spec_helper_system'

describe 'maven type' do
  before(:all) do
    [0,2].should include(puppet_apply(%Q(
      class { 'java': }
      class { 'maven::maven': }
     )).exit_code)
  end

  it 'should be idempotent' do
    pp = %Q(
      maven { '/tmp/maven-core-3.0.5.jar':
        id     => 'org.apache.maven:maven-core:3.0.5:jar',
        repos  => [
          'central::default::http://repo1.maven.apache.org/maven2',
          'http://mirrors.ibiblio.org/pub/mirrors/maven2'],
      }
    )
    puppet_apply(pp)
    puppet_apply(pp).exit_code.should be_zero
  end

  context 'an existing SNAPSHOT artifact' do
    let(:version) { '0.0.1-SNAPSHOT' }
    let(:ensure_param) { 'present' }
    let(:repo_version) { 1 }

    before(:each) do
      shell 'rm -rf /var/www/html/repo /root/.m2/repository/org/foo /tmp/touch-me-if-updated'

      shell 'mkdir -p /var/www/html'
      fixture_rcp "system/maven/repo-#{repo_version}", '/var/www/html/repo'

      [0,2].should include(puppet_apply(%Q(
        package{'httpd': ensure => 'present'} ->
        service{'httpd': ensure  => 'running' } ->

        maven { '/tmp/hello.jar':
          ensure => '#{ensure_param}',
          id     => 'org.foo:hello:#{version}',
          repos  => 'http://localhost/repo'
        }

        exec{'touch-me':
          command => '/bin/touch /tmp/touch-me-if-updated',
          refreshonly => true,
          subscribe => Maven['/tmp/hello.jar']
        }
      )).exit_code)
    end

    describe file('/tmp/hello.jar') do
      it 'should have have the original version' do
        should match_md5checksum '807f2fca0e279dbe48f695983141fd5c'
      end
    end

    context 'with the same SNAPSHOT in the repote repo' do
      let(:repo_version) { 1 }

      around(:each) do |example|
        #make sure the v1 verson of the SNAPSHOT is on the filesystem
        fixture_rcp 'system/maven/repo-1/org/foo/hello/0.0.1-SNAPSHOT/hello-0.0.1-20131008.014634-1.jar', '/tmp/hello.jar'
        example.run
      end

      context 'and ensure => latest' do
        let(:ensure_param) { 'latest' }

        describe file('/tmp/hello.jar') do
          it 'should have the same snapshot' do
            should match_md5checksum  '807f2fca0e279dbe48f695983141fd5c'
          end
        end

        describe file('/tmp/touch-me-if-updated') do
          it 'should not have been created by subscribe relationship' do
            should_not be_file
          end
        end
      end
    end

    context 'with an updated SNAPSHOT in the remote repo' do
      let(:repo_version) { 2 }

      around(:each) do |example|
        #make sure the v1 verson of the SNAPSHOT is on the filesystem
        fixture_rcp 'system/maven/repo-1/org/foo/hello/0.0.1-SNAPSHOT/hello-0.0.1-20131008.014634-1.jar', '/tmp/hello.jar'
        example.run
      end

      context 'and ensure => present' do
        let(:ensure_param) { 'present' }

        describe file('/tmp/hello.jar') do
          it 'should still have have the original version' do
            should match_md5checksum '807f2fca0e279dbe48f695983141fd5c'
          end
        end

        describe file('/tmp/touch-me-if-updated') do
          it 'should not have been created by subscribe relationship' do
            should_not be_file
          end
        end
      end

      context 'and ensure => latest' do
        let(:ensure_param) { 'latest' }

        describe file('/tmp/hello.jar') do
          it 'should have the updated snapshot' do
            should match_md5checksum '67fce35a2a7227a53cdcde06b86d33bf'
          end
        end

        describe file('/tmp/touch-me-if-updated') do
          it 'should have been created by subscribe relationship' do
            should be_file
          end
        end
      end
    end
  end
end

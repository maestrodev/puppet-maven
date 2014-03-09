require 'spec_helper_acceptance'

describe 'maven type' do
  before(:all) do
    pp = %Q(
      class { 'java': }
      class { 'maven::maven': }
    )
    apply_manifest(pp, :catch_failures => true)
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
    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes => true)
  end

  context 'when changing the version' do
    describe file('/tmp/maven-core.jar') do

      before do
        apply_manifest(%Q(
          maven { '/tmp/maven-core.jar':
            id => 'org.apache.maven:maven-core:3.0.5:jar',
          }
        ), :catch_failures => true)
        on(hosts, 'rm -rf /tmp/touch-me-if-updated')
      end

      it 'should not update to the same version' do
        should match_md5checksum 'ee0bd82403231f5e268fd85044027221'
        apply_manifest(%Q(
          maven { '/tmp/maven-core.jar':
            id => 'org.apache.maven:maven-core:3.0.5:jar',
          }
          exec { 'touch-me':
            command     => '/bin/touch /tmp/touch-me-if-updated',
            refreshonly => true,
            subscribe   => Maven['/tmp/maven-core.jar']
          }
        ), :catch_failures => true)
        should match_md5checksum 'ee0bd82403231f5e268fd85044027221'
        file('/tmp/touch-me-if-snapshot-updated').should_not be_file
      end

      it 'should update to a different version' do
        should match_md5checksum 'ee0bd82403231f5e268fd85044027221'
        apply_manifest(%Q(
          maven { '/tmp/maven-core.jar':
            ensure => 'latest',
            id     => 'org.apache.maven:maven-core:3.1.0:jar',
          }
        ), :catch_failures => true)
        should match_md5checksum '67c1cd4fa81ff39826826f46e88f420f'
      end
    end
  end

  context 'an existing SNAPSHOT artifact' do
    let(:version) { '0.0.1-SNAPSHOT' }
    let(:ensure_param) { 'present' }
    let(:repo_version) { 1 }

    before(:each) do
      apply_manifest(%Q(
        package { 'httpd': ensure => 'present' } ->
        service { 'httpd': ensure => 'running' }
      ), :catch_failures => true)

      hosts.each do |host|
        on(host, 'rm -rf /var/www/html/repo /root/.m2/repository/org/foo /tmp/touch-me-if-snapshot-updated')
        fixture_rcp(host, "acceptance/maven/repo-#{repo_version}", '/var/www/html/repo')
      end

      apply_manifest(%Q(
        maven { '/tmp/hello.jar':
          ensure => '#{ensure_param}',
          id     => 'org.foo:hello:#{version}',
          repos  => 'http://localhost/repo'
        }

        exec { 'touch-me':
          command     => '/bin/touch /tmp/touch-me-if-snapshot-updated',
          refreshonly => true,
          subscribe   => Maven['/tmp/hello.jar']
        }
      ), :catch_failures => true)
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
        hosts.each do |host|
          fixture_rcp(host, 'acceptance/maven/repo-1/org/foo/hello/0.0.1-SNAPSHOT/hello-0.0.1-20131008.014634-1.jar', '/tmp/hello.jar')
        end
        example.run
      end

      context 'and ensure => latest' do
        let(:ensure_param) { 'latest' }

        describe file('/tmp/hello.jar') do
          it 'should have the same snapshot' do
            should match_md5checksum  '807f2fca0e279dbe48f695983141fd5c'
          end
        end

        describe file('/tmp/touch-me-if-snapshot-updated') do
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
        hosts.each do |host|
          fixture_rcp(host, 'acceptance/maven/repo-1/org/foo/hello/0.0.1-SNAPSHOT/hello-0.0.1-20131008.014634-1.jar', '/tmp/hello.jar')
        end
        example.run
      end

      context 'and ensure => present' do
        let(:ensure_param) { 'present' }

        describe file('/tmp/hello.jar') do
          it 'should still have have the original version' do
            should match_md5checksum '807f2fca0e279dbe48f695983141fd5c'
          end
        end

        describe file('/tmp/touch-me-if-snapshot-updated') do
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

        describe file('/tmp/touch-me-if-snapshot-updated') do
          it 'should have been created by subscribe relationship' do
            should be_file
          end
        end
      end
    end
  end
end

require 'spec_helper'
require 'tempfile'

type = Puppet::Type.type(:maven)
provider_class = type.provider(:mvn)

describe provider_class do
  subject { provider_class.new type.new({ path: path }.merge params) }
  let(:params) { { } }

  context 'if the file exists' do
    let(:path) do
      file = Tempfile.new 'tmp'
      file_path = file.path
      file.close!
      File.open(file_path, 'w') do |f|
        f.write 'blah'
      end

      file_path
    end

    its(:exists?) { should be_true }

    example do
      expect { subject.ensure = :absent }.to raise_error NotImplementedError
    end
  end

  describe '#ensure' do
    subject { provider_class.new(type.new({ path: path, ensure: ensure_param }.merge params)).ensure }

    context 'with an existing file' do
      let(:path) do
        file = Tempfile.new 'tmp'
        file_path = file.path
        file.close!
        File.open(file_path, 'w') do |f|
          f.write 'foo'
        end

        file_path
      end

      context 'and ensure => latest' do
        let(:ensure_param) { 'latest' }

        context 'and a SNAPSHOT version' do
          let(:params) { { id: 'groupid:artifactid:1.2.3-SNAPSHOT' } }

          context 'and an updated snapshot' do
            before do
              expect(Puppet::Util::SUIDManager).to receive(:run_and_capture) { |command|
                command[0] =~ /-Ddest=([^\s]+)/
                File.open($1, 'w') do |f|
                  f.write 'bar'
                end
              }.and_return ['', OpenStruct.new({exitstatus: 0})]
            end

            it { should equal :present }
          end

          context 'and a current snapshot' do
            before do
              expect(Puppet::Util::SUIDManager).to receive(:run_and_capture) { |command|
                command[0] =~ /-Ddest=([^\s]+)/
                File.open($1, 'w') do |f|
                  f.write 'foo'
                end
              }.and_return ['', OpenStruct.new({exitstatus: 0})]
            end

            it { should equal :latest }
          end
        end
      end

      context 'and ensure => present' do
        let(:ensure_param) { 'present' }

        context 'and a SNAPSHOT version' do
          let(:params) { { id: 'groupid:artifactid:1.2.3-SNAPSHOT' } }

          context 'and an updated snapshot' do
            it { should equal :present }
          end

          context 'and a current snapshot' do
            it { should equal :present }
          end
        end
      end
    end
  end

  context 'if the file does not exist' do
    let(:path) do
      file = Tempfile.new 'tmp'
      file_path = file.path
      file.close!
      file_path
    end

    its(:exists?) { should be_false }
  end

  describe '#ensure=' do
    subject { provider_class.new(type.new({ path: path }.merge params)).ensure = ensure_param }

    context 'with ensure => latest' do
      let(:ensure_param) { :latest }
      let(:exitstatus) { OpenStruct.new exitstatus: 0 }

      context 'given a valid path' do
        let(:path) { '/tmp/blah.txt' }

        describe 'maven command line' do
          subject do
            command_line = nil

            expect(Puppet::Util::SUIDManager).to receive(:run_and_capture) { |command|
              command_line = command[0]
            }.and_return [nil, exitstatus]
            provider_class.new(type.new({ path: path }.merge params)).ensure = ensure_param
            command_line
          end

          it 'should not pass -U' do
            should_not match /-U/
          end

          context 'given a SNAPSHOT version' do
            let(:params) do
              {
                groupid: 'groupid_test',
                artifactid: 'artifactid_test',
                version: '1.2.3-SNAPSHOT'
              }
            end

            it 'should pass -U' do
              should match /-U/
            end
          end

          context 'given the version LATEST' do
            let(:params) do
              {
                groupid: 'groupid_test',
                artifactid: 'artifactid_test',
                version: 'LATEST'
              }
            end

            it 'should pass -U' do
              should match /-U/
            end
          end

          context 'given the version RELEASE' do
            let(:params) do
              {
                groupid: 'groupid_test',
                artifactid: 'artifactid_test',
                version: 'LATEST'
              }
            end

            it 'should pass -U' do
              should match /-U/
            end
          end
        end
      end
    end

    context 'with ensure => present' do
      let(:ensure_param) { :present }
      let(:exitstatus) { OpenStruct.new exitstatus: 0 }

      context 'given a valid path' do
        let(:path) { '/tmp/blah.txt' }

        context 'when mvn returns 1' do
          let(:exitstatus) { OpenStruct.new exitstatus: 1 }

          context 'with no output' do
            let(:output) { '' }

            example do
              expect(Puppet::Util::SUIDManager).to receive(:run_and_capture)
                .and_return [output, exitstatus]
              expect { subject }.to raise_error Puppet::Error, /^mvn returned 1: Is Maven installed\?/
            end
          end

          context 'with output "busted!"' do
            let(:output) { 'busted!' }

            example do
              expect(Puppet::Util::SUIDManager).to receive(:run_and_capture)
                .and_return [output, exitstatus]
              expect { subject }.to raise_error Puppet::Error, /returned 1: busted\!/
            end
          end
        end

        it 'should default to root user' do
          expect(Puppet::Util::SUIDManager).to receive(:run_and_capture)
            .with(anything(), 'root', anything())
            .and_return [nil, exitstatus]

          subject
        end

        it 'should default to root group' do
          expect(Puppet::Util::SUIDManager).to receive(:run_and_capture)
            .with(anything(), anything(), 'root')
            .and_return [nil, exitstatus]

          subject
        end

        it 'should use no timeout' do
          expect(Timeout).to receive(:timeout).with(0).and_call_original
          expect(Puppet::Util::SUIDManager).to receive(:run_and_capture).and_return [nil, exitstatus]

          subject
        end

        describe 'maven command line' do
          subject do
            command_line = nil

            expect(Puppet::Util::SUIDManager).to receive(:run_and_capture) { |command|
              command_line = command[0]
            }.and_return [nil, exitstatus]
            provider_class.new(type.new({ path: path }.merge params)).ensure = :present
            command_line
          end

          it 'should include path' do
            should match /-Ddest=\/tmp\/blah\.txt/
          end

          it 'should default to plugin version 2.4' do
            should match /mvn org\.apache\.maven\.plugins:maven-dependency-plugin:2\.4:get/
          end

          it 'should pass no repoId' do
            should_not match /-DrepoId=/
          end

          it 'should pass no artifact coordinates' do
            should_not match /-Dartifact=/
          end

          it 'should pass no packaging' do
            should_not match /-Dpackaging=/
          end

          it 'should pass no classifier' do
            should_not match /-Dclassifier=/
          end

          it 'should not pass -U' do
            should_not match /-U/
          end

          context 'given a SNAPSHOT version' do
            let(:params) do
              {
                groupid: 'groupid_test',
                artifactid: 'artifactid_test',
                version: '1.2.3-SNAPSHOT'
              }
            end

            it 'should not pass -U' do
              should_not match /-U/
            end
          end

          context 'and a groupId, artifactId, and version' do
            let(:params) do
              {
                groupid: 'groupid_test',
                artifactid: 'artifactid_test',
                version: 'version_test'
              }
            end

            it 'should pass the provided artifactid' do
              should match /-DartifactId=artifactid_test/
            end

            it 'should pass the provided groupid' do
              should match /-DgroupId=groupid_test/
            end

            it 'should pass the provided version' do
              should match /-Dversion=version_test/
            end

            it 'should pass no packaging' do
              should_not match /-Dpackaging=/
            end

            it 'should pass no classifier' do
              should_not match /-Dclassifier=/
            end

            context 'and a classifier' do
              let(:params) do
                {
                  groupid: 'groupid_test',
                  artifactid: 'artifactid_test',
                  version: 'version_test',
                  classifier: 'classifier_test'
                }
              end

              it 'should pass the provided classifier' do
                should match /-Dclassifier=classifier_test/
              end
            end

            context 'and a packaging' do
              let(:params) do
                {
                  groupid: 'groupid_test',
                  artifactid: 'artifactid_test',
                  version: 'version_test',
                  packaging: 'packaging_test'
                }
              end

              it 'should pass the provided packaging' do
                should match /-Dpackaging=packaging_test/
              end
            end
          end

          context 'and an id' do
            let(:params) { { id: 'artifact_test' } }

            it 'should pass the provided id' do
              should match /-Dartifact=artifact_test/
            end

            it 'should pass no groupid' do
              should_not match /-DgroupId=/
            end

            it 'should pass no artifactid' do
              should_not match /-DartifactId=/
            end

            it 'should pass no version' do
              should_not match /-Dversion=/
            end

            it 'should not pass -U' do
              should_not match /-U/
            end
          end

          context 'and an id with a SNAPSHOT version' do
            let(:params) { { id: 'groupid:artifactid:1.2.3-SNAPSHOT' } }

            it 'should not pass -U' do
              should_not match /-U/
            end
          end

          context 'and a repoid' do
            let(:params) { { repoid: 'repoid_test' } }

            it 'should pass the provided repoid' do
              should match /-DrepoId=repoid_test/
            end
          end

          context 'and an explicit pluginversion' do
            let(:params) { { pluginversion: '2.5' } }

            it 'should pass provided version' do
              should match /mvn org\.apache\.maven\.plugins:maven-dependency-plugin:2\.5:get/
            end
          end

          context 'and an empty repo list' do
            let(:params) { { repos: [] } }

            it 'should default to http://repos1.maven.apache.org/maven2' do
              should match /-DremoteRepositories=http:\/\/repo1.maven.apache.org\/maven2/
            end
          end

          context 'and a repo list' do
            let(:params) { { repos: ['http://repo1.com', 'http://repo2.com'] } }

            it 'should pass the provided repos' do
              should match /-DremoteRepositories=http:\/\/repo1.com,http:\/\/repo2.com/
            end
          end

          context 'and a repo string' do
            let(:params) { { repos: 'http://repo1.com' } }

            it 'should pass the provided repos' do
              should match /-DremoteRepositories=http:\/\/repo1.com/
            end
          end
        end


        context 'given a timeout' do
          let(:params) { { timeout: 1 } }

          it 'should use the given timeout' do
            expect(Timeout).to receive(:timeout).with(1).and_call_original
            expect(Puppet::Util::SUIDManager).to receive(:run_and_capture).and_return [nil, exitstatus]

            subject
          end

          it 'should timeout if mvn takes too long' do
            expect(Puppet::Util::SUIDManager).to receive(:run_and_capture) do 
              sleep 2
            end

            expect { subject }.to raise_error Puppet::Error, /^Command timed out/
          end
        end

        context 'given a user' do
          let(:params) { { user: 'user_test' } }

          it 'should use the given user' do
            expect(Puppet::Util::SUIDManager).to receive(:run_and_capture)
              .with(anything(), 'user_test', anything())
              .and_return [nil, exitstatus]

            subject
          end
        end

        context 'given a group' do
          let(:params) { { group: 'group_test' } }

          it 'should use the given group' do
            expect(Puppet::Util::SUIDManager).to receive(:run_and_capture)
              .with(anything(), anything(), 'group_test')
              .and_return [nil, exitstatus]

            subject
          end
        end
      end
    end
  end
end

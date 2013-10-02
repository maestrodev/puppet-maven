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
      expect { subject.destroy }.to raise_error NotImplementedError
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

  describe '#create' do
    subject { provider_class.new(type.new({ path: path }.merge params)).create }
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

        context 'with output' do
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

      it 'should pass that path to mvn' do
        expect(Puppet::Util::SUIDManager).to receive(:run_and_capture) { |command|
          expect(command[0]).to match /-Ddest=\/tmp\/blah\.txt/
        }.and_return [nil, exitstatus]

        subject
      end

      it 'should default to plugin version 2.4' do
        expect(Puppet::Util::SUIDManager).to receive(:run_and_capture) { |command|
          expect(command[0]).to match /mvn org\.apache\.maven\.plugins:maven-dependency-plugin:2\.4:get/
        }.and_return [nil, exitstatus]

        subject
      end

      it 'should use no repoId' do
        expect(Puppet::Util::SUIDManager).to receive(:run_and_capture) { |command|
          expect(command[0]).to_not match /-DrepoId=/
        }.and_return [nil, exitstatus]

        subject
      end

      it 'should use no id' do
        expect(Puppet::Util::SUIDManager).to receive(:run_and_capture) { |command|
          expect(command[0]).to_not match /-Dartifact=/
        }.and_return [nil, exitstatus]

        subject
      end

      it 'should use no packaging' do
        expect(Puppet::Util::SUIDManager).to receive(:run_and_capture) { |command|
          expect(command[0]).to_not match /-Dpackaging=/
        }.and_return [nil, exitstatus]

        subject
      end

      it 'should use no classifier' do
        expect(Puppet::Util::SUIDManager).to receive(:run_and_capture) { |command|
          expect(command[0]).to_not match /-Dclassifier=/
        }.and_return [nil, exitstatus]

        subject
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

      context 'and a groupId, artifactId, and version' do
        let(:params) do
          {
            groupid: 'groupid_test',
            artifactid: 'artifactid_test',
            version: 'version_test'
          }
        end

        it 'should use the provided artifactid' do
          expect(Puppet::Util::SUIDManager).to receive(:run_and_capture) { |command|
            expect(command[0]).to match /-DartifactId=artifactid_test/
          }.and_return [nil, exitstatus]

          subject
        end

        it 'should use the provided groupid' do
          expect(Puppet::Util::SUIDManager).to receive(:run_and_capture) { |command|
            expect(command[0]).to match /-DgroupId=groupid_test/
          }.and_return [nil, exitstatus]

          subject
        end

        it 'should use the provided version' do
          expect(Puppet::Util::SUIDManager).to receive(:run_and_capture) { |command|
            expect(command[0]).to match /-Dversion=version_test/
          }.and_return [nil, exitstatus]

          subject
        end

        it 'should use no packaging' do
          expect(Puppet::Util::SUIDManager).to receive(:run_and_capture) { |command|
            expect(command[0]).to_not match /-Dpackaging=/
          }.and_return [nil, exitstatus]

          subject
        end

        it 'should use no classifier' do
          expect(Puppet::Util::SUIDManager).to receive(:run_and_capture) { |command|
            expect(command[0]).to_not match /-Dclassifier=/
          }.and_return [nil, exitstatus]

          subject
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

          it 'should use the provided classifier' do
            expect(Puppet::Util::SUIDManager).to receive(:run_and_capture) { |command|
              expect(command[0]).to match /-Dclassifier=classifier_test/
            }.and_return [nil, exitstatus]

            subject
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

          it 'should use the provided packaging' do
            expect(Puppet::Util::SUIDManager).to receive(:run_and_capture) { |command|
              expect(command[0]).to match /-Dpackaging=packaging_test/
            }.and_return [nil, exitstatus]

            subject
          end
        end
      end

      context 'and an id' do
        let(:params) { { id: 'artifact_test' } }

        it 'should use the provided id' do
          expect(Puppet::Util::SUIDManager).to receive(:run_and_capture) { |command|
            expect(command[0]).to match /-Dartifact=artifact_test/
          }.and_return [nil, exitstatus]

          subject
        end

        it 'should use no groupid' do
          expect(Puppet::Util::SUIDManager).to receive(:run_and_capture) { |command|
            expect(command[0]).to_not match /-DgroupId=/
          }.and_return [nil, exitstatus]

          subject
        end

        it 'should use no artifactid' do
          expect(Puppet::Util::SUIDManager).to receive(:run_and_capture) { |command|
            expect(command[0]).to_not match /-DartifactId=/
          }.and_return [nil, exitstatus]

          subject
        end

        it 'should use no version' do
          expect(Puppet::Util::SUIDManager).to receive(:run_and_capture) { |command|
            expect(command[0]).to_not match /-Dversion=/
          }.and_return [nil, exitstatus]

          subject
        end
      end

      context 'and a repoid' do
        let(:params) { { repoid: 'repoid_test' } }

        it 'should use the provided repoid' do
          expect(Puppet::Util::SUIDManager).to receive(:run_and_capture) { |command|
            expect(command[0]).to match /-DrepoId=repoid_test/
          }.and_return [nil, exitstatus]

          subject
        end
      end

      context 'and an explicit pluginversion' do
        let(:params) { { pluginversion: '2.5' } }

        it 'should use provided version' do
          expect(Puppet::Util::SUIDManager).to receive(:run_and_capture) { |command|
            expect(command[0]).to match /mvn org\.apache\.maven\.plugins:maven-dependency-plugin:2\.5:get/
          }.and_return [nil, exitstatus]

          subject
        end
      end

      context 'and an empty repo list' do
        let(:params) { { repos: [] } }

        it 'should use http://repos1.maven.apache.org/maven2' do
          expect(Puppet::Util::SUIDManager).to receive(:run_and_capture) { |command|
            expect(command[0]).to match /-DremoteRepositories=http:\/\/repo1.maven.apache.org\/maven2/
          }.and_return [nil, exitstatus]

          subject
        end
      end

      context 'and a repo list' do
        let(:params) { { repos: ['http://repo1.com', 'http://repo2.com'] } }

        it 'should use the provided repos' do
          expect(Puppet::Util::SUIDManager).to receive(:run_and_capture) { |command|
            expect(command[0]).to match /-DremoteRepositories=http:\/\/repo1.com,http:\/\/repo2.com/
          }.and_return [nil, exitstatus]

          subject
        end
      end

      context 'and a repo string' do
        let(:params) { { repos: 'http://repo1.com' } }

        it 'should use the provided repos' do
          expect(Puppet::Util::SUIDManager).to receive(:run_and_capture) { |command|
            expect(command[0]).to match /-DremoteRepositories=http:\/\/repo1.com/
          }.and_return [nil, exitstatus]

          subject
        end
      end
    end
  end
end

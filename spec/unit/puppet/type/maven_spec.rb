require 'spec_helper'

type = Puppet::Type.type(:maven)

describe type do
  subject { type.new({name: name}.merge params)}
  let(:params) { { } }

  let(:name) { 'test' }

  context 'given a valid id' do
    let(:params) { {id: 'test_id'}.merge extra_params }
    let(:extra_params) { { } }

    example do
      expect { subject }.to_not raise_error
    end

    context 'and an artifactid' do
      let(:extra_params) { { artifactid: 'artifactid_test' } }

      example do
        expect { subject }.to raise_error Puppet::Error, /Can't define id and other groupid, artifactid, version, packaging, classifier parameters at the same time/
      end
    end

    context 'and a groupid' do
      let(:extra_params) { { groupid: 'groupid_test' } }

      example do
        expect { subject }.to raise_error Puppet::Error, /Can't define id and other groupid, artifactid, version, packaging, classifier parameters at the same time/
      end
    end

    context 'and a version' do
      let(:extra_params) { { version: 'version_test' } }

      example do
        expect { subject }.to raise_error Puppet::Error, /Can't define id and other groupid, artifactid, version, packaging, classifier parameters at the same time/
      end
    end

    context 'and a packaging' do
      let(:extra_params) { { packaging: 'packaging_test' } }

      example do
        expect { subject }.to raise_error Puppet::Error, /Can't define id and other groupid, artifactid, version, packaging, classifier parameters at the same time/
      end
    end

    context 'and a packaging' do
      let(:extra_params) { { classifier: 'classifier_test' } }

      example do
        expect { subject }.to raise_error Puppet::Error, /Can't define id and other groupid, artifactid, version, packaging, classifier parameters at the same time/
      end
    end
  end

  context 'given only an artifactid' do
    let(:params) { { artifactid: 'artifactid_test' } }
    example do
      expect { subject }.to raise_error Puppet::Error, /Missing required groupid, artifactid or version parameters/
    end
  end

  context 'given only a groupid' do
    let(:params) { { groupid: 'groupid_test' } }
    example do
      expect { subject }.to raise_error Puppet::Error, /Missing required groupid, artifactid or version parameters/
    end
  end

  context 'given only a version' do
    let(:params) { { version: 'version_test' } }
    example do
      expect { subject }.to raise_error Puppet::Error, /Missing required groupid, artifactid or version parameters/
    end
  end

  context 'given an artifactid, groupid, and version' do
    let(:params) do
      {
        artifactid: 'artifactid_test',
        groupid: 'groupid_test',
        version: 'version_test',
      }
    end

    example do
      expect { subject }.to_not raise_error
    end

  end
end



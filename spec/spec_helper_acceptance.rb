require 'puppet'
require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  c.before(:each) do
    Puppet::Util::Log.level = :warning
    Puppet::Util::Log.newdestination(:console)
  end

  c.before :suite do
    # Install module and dependencies
    # on host, "mkdir -p #{host['distmoduledir']}"
    install_puppet

    hosts.each do |host|
      on host, puppet('module','install','maestrodev-wget','-v 1.0.0'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','puppetlabs-java','-v 1.0.1'), { :acceptable_exit_codes => [0,1] }
    end
    puppet_module_install(:source => proj_root, :module_name => 'maven')
  end
end

def fixture_rcp(host, src, dest)
  scp_to(host, "#{proj_dir}/spec/fixtures/#{src}", dest)
end

def proj_dir
  File.absolute_path File.join File.dirname(__FILE__), '..'
end

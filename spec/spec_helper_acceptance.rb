require 'puppet'
require 'beaker-rspec'

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

    begin
      on hosts.first, "puppet --version"
    rescue
      install_puppet
    end

    hosts.each do |host|
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

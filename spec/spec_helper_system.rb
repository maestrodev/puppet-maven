require 'puppet'
require 'rspec-system/spec_helper'
require 'rspec-system-puppet/helpers'
require 'rspec-system-serverspec/helpers'

include RSpecSystemPuppet::Helpers

RSpec.configure do |c|
  # Enable color in Jenkins
  c.tty = true

  c.before(:each) do
    Puppet::Util::Log.level = :warning
    Puppet::Util::Log.newdestination(:console)
  end

  c.before :suite do
    #Install puppet
    puppet_install

    #Clean out modules from last run
    shell('rm -rf /etc/puppet/modules/*').exit_code.should be_zero

    shell('puppet module install maestrodev/wget -v 1.0.0').exit_code.should be_zero
    shell('puppet module install puppetlabs/java -v 1.0.1').exit_code.should be_zero

    puppet_module_install source: proj_dir, module_name: 'maven'

    #geezes
    shell('puppet module install spiette/selinux -v 0.5.3').exit_code.should be_zero
    [0,2].should include(puppet_apply("class{'selinux': mode => 'disabled'}").exit_code)
  end
end

def fixture_rcp(src, dest)
  rcp sp: "#{proj_dir}/spec/fixtures/#{src}", dp: dest
end

def proj_dir
  File.absolute_path File.join File.dirname(__FILE__), '..'
end

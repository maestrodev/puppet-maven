require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |c|

  c.before(:each) do
    Puppet::Util::Log.level = :warning
    Puppet::Util::Log.newdestination(:console)
  end

end

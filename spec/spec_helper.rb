require 'rspec-puppet'

RSpec.configure do |c|
   c.module_path = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
   c.manifest_dir = File.expand_path(File.join(File.dirname(__FILE__), '..','spec','fixtures','manifests'))
end

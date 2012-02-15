require 'puppet-lint/tasks/puppet-lint'
require 'rspec/core/rake_task'

desc "Run module RSpec tests."
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = ["--format", "doc", "--color"]
  t.pattern = 'spec/*/*_spec.rb'
end

desc "Create a Puppet module."
task :build do
  sh 'puppet-module build'
end

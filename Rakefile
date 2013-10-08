require 'bundler'
Bundler.require(:rake)
require 'rake/clean'

CLEAN.include('spec/fixtures/', 'doc', 'pkg')
CLOBBER.include('.tmp', '.librarian')

require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet_blacksmith/rake_tasks'
require 'rspec-system/rake_task'

PuppetLint.configuration.send("disable_80chars")

# use librarian-puppet to manage fixtures instead of .fixtures.yml
# offers more possibilities like explicit version management, forge
# downloads,...
task :librarian_spec_prep do
 sh "librarian-puppet install --path=spec/fixtures/modules/"
end
task :spec_prep => :librarian_spec_prep

desc "Integration test with Vagrant"
task :integration do
  # sh %{vagrant destroy --force}
  failed = []
  ["centos64", "centos63"].each do |vm|
    sh %{vagrant up #{vm}} do |ok|
      if ok
        # sh %{vagrant destroy --force #{vm}}
      else
        failed << vm
      end
    end
  end
  fail("Machines failed to start: #{failed.join(', ')}") unless failed.empty?
end

task :default => [:clean, :spec]

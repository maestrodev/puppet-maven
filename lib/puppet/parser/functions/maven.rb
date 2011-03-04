require 'rubygems'
require 'buildr'

# Hack to make buildr think there is a rakefile in the directory
class << Buildr.application
  def rakefile; __FILE__; end
end

# usage maven(id, repository = "http://repo1.maven.org/maven2" )
# ie.
# maven('org.apache.maven:maven-core:jar:2.2.1')
# maven('org.apache.maven:maven-core:jar:2.2.1', 'http://repo1.maven.org/maven2')
module Puppet::Parser::Functions
  newfunction(:maven, :type => :rvalue, :doc => "Get a file from a Maven repository using its Maven coordinates") do |args|

    # Remote repositories to use
    Buildr.repositories.remote << (args.size <= 1 ? "http://repo1.maven.org/maven2" : args[1])

    full_id = args[0]
    
    # Download the artifact fom the repo
    artifact = Buildr.artifact(full_id)
    artifact.invoke
    artifact.to_s
  end
end

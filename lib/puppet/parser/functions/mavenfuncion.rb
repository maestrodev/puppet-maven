# Copyright 2011 MaestroDev
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'rubygems'
require 'buildr'

# Hack to make buildr think there is a rakefile in the directory
class << Buildr.application
  def rakefile; __FILE__; end
end

# NOTE Functions are executed in the SERVER
# so this is quite USELESS and just kept as an example
#
# usage maven(id, repository = "http://repo1.maven.org/maven2" )
# ie.
# maven('org.apache.maven:maven-core:jar:2.2.1')
# maven('org.apache.maven:maven-core:jar:sources:2.2.1', 'http://repo1.maven.org/maven2')
module Puppet::Parser::Functions
  newfunction(:mavenfunction, :type => :rvalue, :doc => "Get a file from a Maven repository using its Maven coordinates") do |args|

    # Remote repositories to use
    Buildr.repositories.remote << (args.size <= 1 ? "http://repo1.maven.org/maven2" : args[1])

    full_id = args[0]

    # Download the artifact fom the repo
    artifact = Buildr.artifact(full_id)
    artifact.invoke
    artifact.to_s
  end
end
